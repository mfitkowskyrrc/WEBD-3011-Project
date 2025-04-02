ActiveAdmin.register_page "Custom Navigation" do
  menu false  # This hides it from the sidebar

  content do
    div class: "custom-nav" do
      link_to "Back to Home", root_path, class: "button"
    end
  end
end