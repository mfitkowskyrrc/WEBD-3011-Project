class ChangeCustomerIdInCarts < ActiveRecord::Migration[6.0]
  def change
    change_column_null :carts, :customer_id, true
  end
end
