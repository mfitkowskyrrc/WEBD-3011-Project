ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: "Dashboard"

  content title: "Dashboard" do
    columns do
      column do
        panel "Recent Admin Users" do
          ul do
            AdminUser.order(created_at: :desc).limit(5).map do |admin_user|
              li link_to(admin_user.email, admin_admin_user_path(admin_user))
            end
          end
        end
      end

      column do
        panel "Categories" do
          ul do
            Category.order(created_at: :desc).map do |category|
              li link_to(category.name, admin_category_path(category))
            end
          end
        end
      end

      column do
        panel "Recent Customers" do
          ul do
            Customer.order(created_at: :desc).limit(5).map do |customer|
              li link_to(customer.name, admin_customer_path(customer))
            end
          end
        end
      end

      column do
        panel "Events" do
          ul do
            Event.order(created_at: :desc).map do |event|
              li link_to(event.title, admin_event_path(event))
            end
          end
        end
      end

      column do
        panel "Site Content" do
          ul do
            Content.order(created_at: :desc).limit(5).map do |content|
              li link_to(content.section, admin_content_path(content))
            end
          end
        end
      end
    end
  end
end
