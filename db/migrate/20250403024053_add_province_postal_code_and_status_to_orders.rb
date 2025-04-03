class AddProvincePostalCodeAndStatusToOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :province, :string
    add_column :orders, :postal_code, :string
    add_column :orders, :status, :string, default: "processing"
  end
end
