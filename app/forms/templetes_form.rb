class TempletesForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  # Locationの属性
  attribute :location_name, :string

  # Stock及びHistoryをまとめて扱うフォーム
  attribute :stock_forms

  # コントローラから受け取るモデルオブジェクト用
  attribute :our_locations
  attribute :current_user

  # コントローラ側でlocationを読み取れるようにする
  attr_reader :location

  validates :location_name, presence: { message: "入力してください" }
  validate :validate_stock_forms

  def initialize(attributes = {}, our_locations: nil, current_user: nil)
    super(attributes)
    @our_locations = our_locations
    @current_user = current_user
    self.stock_forms ||= []
  end

  # fields_forはaccepts_nested_attributes_forで定義したattributesから値のみを取り出してくれる
  # FormObjectでは自動で取り出してくれないので、オーバーライドして自前で定義している
  def stock_forms_attributes=(attrs)
    self.stock_forms = attrs.values.map { |row| TempletesStockForm.new(row) }
  end

  def save
    return false unless valid?

    @location = @our_locations.find_by(name: location_name) || @current_user.locations.create!(name: location_name)

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

  private

  def validate_stock_forms
    stock_forms.each_with_index do |form, i|
      next if form.valid?

      form.errors.each do |attr, message|
        errors.add("stock_forms[#{i}].#{attr}", message)
      end
    end
  end
end
