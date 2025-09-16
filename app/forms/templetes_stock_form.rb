class TempletesStockForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  # Stock の属性
  attribute :name, :string
  attribute :model, :integer

  # History の属性
  attribute :exist_quantity, :integer
  attribute :num_quantity, :integer

  validates :name, presence: true

  validate :validate_quantities_by_model

  private

  # モデル種別ごとの必須条件
  def validate_quantities_by_model
    case model.to_i
    when 0
      errors.add(:exist_quantity, "を入力してください") if exist_quantity.blank?
    when 1
      errors.add(:num_quantity, "を入力してください") if num_quantity.blank?
    end
  end
end
