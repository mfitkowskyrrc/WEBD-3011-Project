ActiveAdmin.register Customer do
  permit_params :name, :email, :address, :password, :password_confirmation, :admin

  index do
    selectable_column
    id_column
    column :name
    column :email
    column :address
    column :admin
    column :created_at
    actions
  end

  filter :name
  filter :email
  filter :admin
  filter :created_at

  form do |f|
    f.inputs "Customer Details" do
      f.input :name
      f.input :email
      f.input :password
      f.input :password_confirmation
      f.input :address
      f.input :admin, as: :boolean
    end
    f.actions
  end

  show do
    attributes_table do
      row :name
      row :email
      row :address
      row :admin
      row :created_at
      row :updated_at
    end
  end
end
