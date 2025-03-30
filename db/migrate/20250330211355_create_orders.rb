class CreateOrders < ActiveRecord::Migration[7.2]
  def change
    create_table :orders do |t|
      t.string :customer_id, null: false
      t.date :order_date, null: false
      t.decimal :total_amount, null: false, precision: 10, scale: 2

      t.timestamps
    end
  end
end
