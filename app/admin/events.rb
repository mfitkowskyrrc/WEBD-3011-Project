ActiveAdmin.register Event do
  permit_params :title, :start_time, :end_time, :description

  index do
    column :title
    column :start_time
    column :end_time
    column :description
    actions
  end

  form do |f|
    f.inputs 'Event Details' do
      f.input :title
      f.input :start_time, as: :datetime_picker
      f.input :end_time, as: :datetime_picker
      f.input :description
    end
    f.actions
  end
end