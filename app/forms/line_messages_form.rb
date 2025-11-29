class LineMessagesForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :message, :string

  validates :message, presence: true
end
