class Product < ApplicationRecord
  belongs_to :category
  has_many :order_items, dependent: :destroy
  has_many :orders, through: :order_items

  has_one_attached :image

  validates :name, :description, :price, :stock_quantity, presence: true

  def self.ransackable_associations(auth_object = nil)
    ["category", "order_items", "orders"]
  end

  def self.ransackable_attributes(auth_object = nil)
    ["category_id", "created_at", "description", "id", "id_value", "name", "price", "stock_quantity", "updated_at"]
  end
end