class ChangeDateToDatetimeInEvents < ActiveRecord::Migration[6.0]
  def change
    change_column :events, :date, :datetime, null: false
  end
end

