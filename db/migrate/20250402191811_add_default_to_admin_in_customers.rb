class AddDefaultToAdminInCustomers < ActiveRecord::Migration[6.0]
  def change
    change_column_default :customers, :admin, false
  end
end
