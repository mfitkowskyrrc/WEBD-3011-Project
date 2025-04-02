# frozen_string_literal: true
ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do
    div class: "blank_slate_container", id: "dashboard_default_message" do
      span class: "blank_slate" do
        span I18n.t("active_admin.dashboard_welcome.welcome")
        small I18n.t("active_admin.dashboard_welcome.call_to_action")
      end
    end
  end
  menu priority: 1, label: "Dashboard"

  content title: "Dashboard" do
    div do
      link_to "Back to Home", root_path, class: "button"
    end
    columns do
      column do
        panel "Recent Customers" do
          ul do
            Customer.last(10).map do |customer|
              li link_to(customer.name, admin_customer_path(customer))
            end
          end
        end
      end
    end
  end
end
