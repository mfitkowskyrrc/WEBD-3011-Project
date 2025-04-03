class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product

  def self.ransackable_attributes(auth_object = nil)
    ["id", "cart_id", "product_id", "quantity", "created_at", "updated_at"]
  end
end
