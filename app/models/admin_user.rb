class AdminUser < ApplicationRecord
  validates :email, presence: true, uniqueness: true

  def self.ransackable_attributes(auth_object = nil)
    [ "created_at", "email", "encrypted_password", "id", "id_value", "remember_created_at", "reset_password_sent_at", "reset_password_token", "updated_at" ]
  end

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable
end
