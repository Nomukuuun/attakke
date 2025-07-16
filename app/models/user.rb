class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable

  validates :name, presence: true, length: { maximum: 255 }
  validates :email, presence: true, uniqueness: true
end
