class AddAdminToCustomers < ActiveRecord::Migration[7.2]
  def change
    add_column :customers, :admin, :boolean
  end
end
