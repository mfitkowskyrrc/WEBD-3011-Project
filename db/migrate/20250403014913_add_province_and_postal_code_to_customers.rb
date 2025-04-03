class AddProvinceAndPostalCodeToCustomers < ActiveRecord::Migration[7.2]
  def change
    add_column :customers, :province, :string
    add_column :customers, :postal_code, :string
  end
end
