class TempletesForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  # Locationの属性
  attribute :location_name, :string

  # 複数フォーム用の属性
  attribute :stock_forms

  # コントローラから受け取るモデルオブジェクト用
  attribute :current_user
  attribute :our_locations

  # コントローラ側でlocationを読み取れるようにする
  attr_reader :location

  validates :location_name, presence: true

  def initialize(attributes = {}, our_locations: nil, current_user: nil)
    super(attributes)
    @our_locations = our_locations
    @current_user = current_user
    self.stock_forms ||= []
  end

  def stock_forms_attributes=(attrs)
    self.stock_forms = attrs.values.map { |row| TempletesStockForm.new(row) }
  end

  # FIXME: 画面更新時のlocationをどう与えるか検討
  def save
    return false unless valid?

    @location = @our_locations.find_by(name: location_name) || Location.create!(user_id: @current_user.id, name: location_name)

    ActiveRecord::Base.transaction do
      stock_forms.each do |form|
        stock = @current_user.stocks.create!(
          name: form.name,
          model: form.model,
          location_id: @location.id,
        )
        stock.histories.create!(
          exist_quantity: form.exist_quantity,
          num_quantity: form.num_quantity,
          status: :templete
        )
      end
    end

    true
  end
end
