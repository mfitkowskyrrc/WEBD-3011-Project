class Content < ApplicationRecord
  validates :section, presence: true, uniqueness: true
  validates :content, presence: true

  def self.ransackable_attributes(auth_object = nil)
    ["content", "created_at", "id", "id_value", "section", "updated_at"]
  end
end
