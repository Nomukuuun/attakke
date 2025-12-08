class TempletesForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  # Locationの属性
  attribute :location_name, :string

  # Stock及びHistoryをまとめて扱うフォーム
  attribute :stock_forms

  # createアクションでコントローラから受け取るモデルオブジェクト
  attribute :current_user

  # saveメソッドで保存したlocationをコントローラで読み取れるようにする
  attr_reader :location

  validates :location_name, length: { maximum: 50, message: "%{count}字以内で入力してください" }, presence: { message: "入力してください" }
  validate :validate_stock_forms

  def initialize(attributes = {}, user: nil)
    super(attributes)
    @current_user = user
    self.stock_forms ||= []
  end

  # fields_forはaccepts_nested_attributes_forで定義したモデルのattributesから値のみを自動で取り出してくれる
  # FormObjectでは自動で取り出してくれないので、値のみ取り出す処理をオーバーライドして定義している
  def stock_forms_attributes=(attrs)
    self.stock_forms = attrs.values.map { |row| TempletesStockForm.new(row) }
  end

  def save
    return false unless valid?

    # 世帯の保管場所にない場合は、操作したユーザーの保管場所として作成する必要があるため、find_or_create_byが使えない
    @location = @current_user.household_locations.find_by(name: location_name) || @current_user.locations.create!(name: location_name)

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
        )
      end
    end

    true
  end

  # NOTE: 以下privateメソッド
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
