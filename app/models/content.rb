class Content < ApplicationRecord
  validates :section, presence: true, uniqueness: true
  validates :content, presence: true
end

