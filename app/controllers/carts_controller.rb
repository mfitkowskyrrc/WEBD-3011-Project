class CartsController < ApplicationController
  before_action :set_cart, only: [:show, :add_product, :remove_product, :update_quantity, :checkout, :complete_purchase]
  before_action :authenticate_customer!, only: [:checkout, :complete_purchase]

  def show
    @cart_items = @cart.cart_items.includes(:product)
  end

  def add_product
    product = Product.find(params[:product_id])
    cart_item = @cart.cart_items.find_by(product_id: product.id)

    if cart_item
      cart_item.increment(:quantity).save
    else
      @cart.cart_items.create(product: product)
    end

    redirect_to cart_path(@cart)
  end

  def remove_product
    product = Product.find(params[:product_id])
    cart_item = @cart.cart_items.find_by(product_id: product.id)

    cart_item&.destroy
    redirect_to cart_path(@cart)
  end

  def update_quantity
    cart_item = @cart.cart_items.find(params[:cart_item_id])
    new_quantity = params[:quantity].to_i
    cart_item.update(quantity: new_quantity)
    redirect_to cart_path(@cart)
  end

  def checkout
    @cart_items = @cart.cart_items.includes(:product)
  end

  def complete_purchase
    if @cart.cart_items.empty?
      redirect_to cart_path, alert: "Your cart is empty!"
      return
    end

    begin
      ActiveRecord::Base.transaction do
        order = Order.create!(
          order_date: Date.today,
          total_amount: @cart.cart_items.sum { |cart_item| cart_item.product.price * cart_item.quantity },
          customer_id: current_customer.id
        )
        @cart.cart_items.each do |cart_item|
          product = cart_item.product

          if product.stock_quantity < cart_item.quantity
            Rails.logger.error "Insufficient stock for #{product.name}: requested #{cart_item.quantity}, available #{product.stock_quantity}"
            raise ActiveRecord::Rollback, "Insufficient stock for #{product.name}"
          end
          order.order_items.create!(
            product_id: product.id,
            quantity: cart_item.quantity
          )
          product.update!(stock_quantity: product.stock_quantity - cart_item.quantity)
        end
        @cart.cart_items.destroy_all
        @cart.update!(status: 'completed', total_amount: 0)
        session.delete(:cart_id)

        redirect_to order_path(order), notice: "Your order has been successfully placed!"
      end
    end
  end

  private

  def set_cart
    if customer_signed_in?
      @cart = current_customer.cart || current_customer.create_cart(status: 'active', total_amount: 0)
    else
      @cart = Cart.find_by(id: session[:cart_id]) || Cart.create!(status: 'active', total_amount: 0)
    end
    session[:cart_id] = @cart.id
  end
end
