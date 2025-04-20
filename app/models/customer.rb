class Customer < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

  has_one :cart, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :cart_items, through: :carts

  validates :name, :email, :address, :province, :postal_code, presence: true
  validates :email, uniqueness: true

  after_create :create_cart

  def admin?
    admin
  end

  def self.ransackable_associations(auth_object = nil)
    [ "orders" ]
  end

  def self.ransackable_attributes(auth_object = nil)
    ["name", "email", "address", "province", "postal_code", "created_at", "updated_at", "encrypted_password", "reset_password_token", "reset_password_sent_at", "remember_created_at", "admin"]
  end


  private

  def create_cart
    Cart.create(customer_id: self.id)
  end

  def set_address_details
    self.province = customer.province
    self.postal_code = customer.postal_code
  end
end
