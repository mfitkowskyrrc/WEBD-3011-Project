class Order < ApplicationRecord
  belongs_to :customer
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items

  validates :status, inclusion: { in: [ "processing", "processed", "shipped" ] }
  validates :province, presence: true
  validates :postal_code, presence: true

  def self.ransackable_attributes(auth_object = nil)
    [ "created_at", "customer_id", "id", "order_date", "total_amount", "updated_at" ]
  end

  PROVINCES = {
    "Alberta" => 0.05,
    "British Columbia" => 0.12,
    "Manitoba" => 0.13,
    "New Brunswick" => 0.15,
    "Newfoundland and Labrador" => 0.15,
    "Nova Scotia" => 0.15,
    "Ontario" => 0.13,
    "Prince Edward Island" => 0.15,
    "Quebec" => 0.15,
    "Saskatchewan" => 0.11
  }

  def calculate_tax_rate
    PROVINCES[province]
  end

  def tax_amount
    subtotal * calculate_tax_rate
  end

  def subtotal
    order_items.sum { |item| item.price * item.quantity }
  end
end
