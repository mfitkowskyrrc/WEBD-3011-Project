class Order < ApplicationRecord
  belongs_to :customer
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items

  validates :order_date, :total_amount, presence: true

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "customer_id", "id", "order_date", "total_amount", "updated_at"]
  end
end