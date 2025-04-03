class Cart < ApplicationRecord
  belongs_to :customer, optional: true
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  def self.create_for_customer(customer)
    create!(customer: customer, status: "pending")
  end
end
