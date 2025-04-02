class AddDeviseToCustomers < ActiveRecord::Migration[7.2]
  def change
    change_table :customers do |t|
      t.string :encrypted_password, default: "", null: false
      t.string :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at

      t.index :reset_password_token, unique: true
    end
  end
end
