class CartsController < ApplicationController
  before_action :set_cart, only: [:show, :add_product, :remove_product, :checkout, :complete_purchase]

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

  def checkout
    @cart_items = @cart.cart_items.includes(:product)
  end

  def complete_purchase
    if @cart.nil?
      redirect_to cart_path, alert: "No active cart found. Please add items to your cart before proceeding."
      return
    end

    if @cart.cart_items.empty?
      redirect_to cart_path, alert: "Your cart is empty!"
      return
    end

    begin
      ActiveRecord::Base.transaction do
        order = Order.create!(
          order_date: Date.today,
          total_amount: @cart.cart_items.sum { |item| item.product.price * item.quantity }
        )

        @cart.cart_items.each do |cart_item|
          product = cart_item.product

          if product.stock_quantity < cart_item.quantity
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
    rescue => e
      redirect_to cart_path, alert: "An error occurred while processing your order. Please try again."
    end
  end


  private

  def set_cart
    @cart = Cart.find_by(id: session[:cart_id]) || Cart.create!(status: 'active', total_amount: 0)
    session[:cart_id] = @cart.id
  end
end
