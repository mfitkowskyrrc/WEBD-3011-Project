ActiveAdmin.register Product do
  permit_params :name, :description, :price, :stock_quantity, :category_id

  form do |f|
    f.inputs "Product Details" do
      f.input :name
      f.input :description
      f.input :price
      f.input :stock_quantity
      f.input :category, as: :select, collection: Category.all.map { |c| [ c.name, c.id ] }  # Dropdown for categories
    end
    f.actions  # Adds 'Create' and 'Cancel' buttons
  end
end
