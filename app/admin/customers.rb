ActiveAdmin.register Customer do
   permit_params :name, :email, :password, :address

   form do |f|
    f.inputs "Customer Details" do
      f.input :name
      f.input :email
      f.input :password
      f.input :address
    end
    f.actions  # Adds 'Create' and 'Cancel' buttons
  end

end
