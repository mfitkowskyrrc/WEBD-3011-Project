class CreateEvents < ActiveRecord::Migration[7.2]
  def change
    create_table :events do |t|
      t.string :name, null: false
      t.date :date, null: false
      t.text :description

      t.timestamps
    end
  end
end
