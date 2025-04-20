ActiveAdmin.register Content do
  permit_params :section, :content

  index do
    selectable_column
    id_column
    column :section
    column :content
    column :created_at
    actions
  end

  filter :section
  filter :created_at

  form do |f|
    f.inputs "Content Details" do
      f.input :section
      f.input :content
    end
    f.actions
  end

  show do
    attributes_table do
      row :section
      row :content
      row :created_at
      row :updated_at
    end
  end
end
