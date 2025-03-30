class AddForeignKeys < ActiveRecord::Migration[7.2]
  def change
    add_foreign_key :products, :categories, column: :category_id, primary_key: :id
    add_foreign_key :order_items, :products, column: :product_id, primary_key: :id
    add_foreign_key :order_items, :orders, column: :order_id, primary_key: :id
    add_foreign_key :orders, :customers, column: :customer_id, primary_key: :id
  end
end
