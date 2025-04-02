class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :quantity, :price, presence: true

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "id", "order_id", "product_id", "quantity", "updated_at"]
  end
end