ActiveAdmin.register Customer do
  permit_params :name, :email, :address, :password, :password_confirmation

  form do |f|
    f.inputs "Customer Details" do
      f.input :name
      f.input :email
      f.input :password
      f.input :password_confirmation
      f.input :address
    end
    f.actions
  end

  show do
    attributes_table do
      row :name
      row :email
      row :address
      row :created_at
      row :updated_at
    end
  end
end
