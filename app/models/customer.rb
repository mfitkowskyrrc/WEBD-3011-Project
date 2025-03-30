class Customer < ApplicationRecord
  has_many :orders, dependent: :destroy

  validates :name, :email, :password, :address, presence: true
end