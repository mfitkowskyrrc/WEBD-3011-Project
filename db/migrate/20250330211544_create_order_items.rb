class CreateOrderItems < ActiveRecord::Migration[7.2]
  def change
    create_table :order_items do |t|
      t.string :order_id
      t.string :product_id
      t.integer :quantity

      t.timestamps
    end
  end
end
