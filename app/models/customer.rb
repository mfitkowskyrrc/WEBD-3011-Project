class Customer < ApplicationRecord
  has_many :orders, dependent: :destroy

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