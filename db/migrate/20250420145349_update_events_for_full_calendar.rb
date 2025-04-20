class UpdateEventsForFullCalendar < ActiveRecord::Migration[7.0]
  def change
    rename_column :events, :name, :title
    rename_column :events, :date, :start_time
    add_column :events, :end_time, :datetime
  end
end