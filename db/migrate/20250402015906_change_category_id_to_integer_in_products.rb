class ChangeCategoryIdToIntegerInProducts < ActiveRecord::Migration[7.2]
  def change
    change_column :products, :category_id, :integer
  end
end