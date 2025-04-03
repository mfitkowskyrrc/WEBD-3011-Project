class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  def authenticate_admin!
    redirect_to root_path, alert: "You are not authorized to access this page." unless current_customer&.admin?
  end
end
