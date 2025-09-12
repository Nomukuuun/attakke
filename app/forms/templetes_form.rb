class TempletesForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  # Locationの属性
  attribute :location_name, :string

  # 複数フォーム用の属性
  attribute :stock_forms

  def initialize(location_name:)
    super()
    self.location_name = location_name
    self.stock_forms = []
  end

  def stock_forms_attributes=(attrs)
    self.stock_forms = attrs.values.map { |row| TempletesStockForm.new(row) }
  end

  def save
    return false unless valid?

    stock = Stock.create!(
      name: name,
      model: model,
      location_id: location_id,
      user_id: user_id
    )
    stock.histories.create!(
      exist_quantity: exist_quantity,
      num_quantity: num_quantity,
      status: :templete
    )
  end
end
