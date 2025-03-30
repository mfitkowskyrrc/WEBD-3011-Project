class Event < ApplicationRecord
  validates :name, :date, :description, presence: true
end