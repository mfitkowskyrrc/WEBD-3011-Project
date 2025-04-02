class Customers::SessionsController < Devise::SessionsController
  def create
    super do |customer|
      if customer.present?
        session[:customer_name] = customer.name
        flash[:notice] = "Welcome back, #{customer.name}! Glad to see you again."
      end
    end
  end

  def destroy
    if session[:customer_name].present?
      flash[:notice] = "Goodbye, #{session[:customer_name]}! See you next time."
    end
    session[:customer_name] = nil
    super do
      flash[:notice] = flash[:notice] if flash[:notice].empty?
    end
  end
end
