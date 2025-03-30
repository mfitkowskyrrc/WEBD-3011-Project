class CreateOrderItems < ActiveRecord::Migration[7.2]
  def change
    create_table :order_items do |t|
      t.string :order_id, null: false
      t.string :product_id, null: false
      t.integer :quantity, null: false, default: 1

      t.timestamps
    end
  end
end
