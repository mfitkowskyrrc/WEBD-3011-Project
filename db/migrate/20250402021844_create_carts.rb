class CreateCarts < ActiveRecord::Migration[7.2]
  def change
    create_table :carts do |t|
      t.references :customer, null: false, foreign_key: true
      t.string :status, default: 'active'
      t.decimal :total_amount, precision: 10, scale: 2, default: 0.0

      t.timestamps
    end
  end
end

