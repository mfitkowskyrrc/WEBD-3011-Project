class Cart < ApplicationRecord
  belongs_to :customer
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items
end
