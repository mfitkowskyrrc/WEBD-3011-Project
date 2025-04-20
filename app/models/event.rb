class Event < ApplicationRecord
  validates :title, :start_time, :description, presence: true

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "start_time", "end_time", "description", "id", "title", "updated_at"]
  end

  def start
    start_time.iso8601
  end

  def end
    end_time&.iso8601
  end
end

