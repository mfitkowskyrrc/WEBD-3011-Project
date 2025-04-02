class Customer < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

  has_many :carts
  has_many :orders
  has_many :cart_items, through: :carts

  validates :name, :email, :password, :address, presence: true

  def self.ransackable_associations(auth_object = nil)
    ["orders"]
  end
  def self.ransackable_attributes(auth_object = nil)
    ["address", "created_at", "email", "id", "name", "password", "updated_at"]
  end
  ActiveAdmin.register Customer do
    permit_params :name, :email, :password, :role
  end
end