class Customer < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

  has_one :cart, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :cart_items, through: :carts

  validates :name, :email, :password, :address, :province, :postal_code, presence: true

  after_create :create_cart

  def admin?
    admin
  end

  def self.ransackable_associations(auth_object = nil)
    ["orders"]
  end

  def self.ransackable_attributes(auth_object = nil)
    ["address", "created_at", "email", "id", "name", "password", "updated_at", "province", "postal_code"]
  end

  private

  def create_cart
    Cart.create(customer_id: self.id)
  end
end
