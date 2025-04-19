class CartsController < ApplicationController
  before_action :set_cart, only: [:show, :add_product, :remove_product, :update_quantity, :checkout, :create_checkout_session, :checkout_success]
  before_action :authenticate_customer!, only: [:checkout, :create_checkout_session, :checkout_success]

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
    cart_item.update(quantity: params[:quantity].to_i)
    redirect_to cart_path(@cart)
  end

  def checkout
    @cart_items = @cart.cart_items.includes(:product)
    @stripe_publishable_key = ENV['STRIPE_PUBLIC_KEY']
  end

  def create_checkout_session
    begin
      session = Stripe::Checkout::Session.create(
        payment_method_types: ['card'],
        customer_email: current_customer.email,
        line_items: @cart.cart_items.map do |item|
          {
            price_data: {
              currency: 'cad',
              product_data: { name: item.product.name },
              unit_amount: (item.product.price * 100).to_i
            },
            quantity: item.quantity
          }
        end,
        mode: 'payment',
        success_url: checkout_success_cart_url,
        cancel_url: checkout_cancel_cart_url,
      )

      render json: { sessionId: session.id }
    rescue Stripe::StripeError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end

  def checkout_success
    if @cart.cart_items.empty?
      redirect_to cart_path, alert: 'Your cart is already empty or the order was already processed.'
      return
    end

    subtotal     = @cart.cart_items.sum { |ci| ci.product.price * ci.quantity }
    tax_rate     = Order::PROVINCES[current_customer.province]
    tax_amount   = subtotal * tax_rate
    total_amount = (subtotal + tax_amount).round(2)

    ActiveRecord::Base.transaction do
      order = Order.create!(
        order_date: Date.today,
        total_amount: total_amount,
        customer_id: current_customer.id,
        province: current_customer.province,
        postal_code: current_customer.postal_code,
        status: 'processing'
      )

      @cart.cart_items.each do |ci|
        product = ci.product
        raise ActiveRecord::Rollback, "Insufficient stock for #{product.name}" if product.stock_quantity < ci.quantity

        order.order_items.create!(product_id: product.id, quantity: ci.quantity, price: product.price)
        product.decrement!(:stock_quantity, ci.quantity)
      end

      @cart.cart_items.destroy_all
      @cart.update!(status: 'completed', total_amount: 0)
      session.delete(:cart_id)

      redirect_to order_path(order), notice: 'Your order has been successfully placed!'
    end
  rescue => e
    logger.error "Order creation failed: #{e.message}"
    redirect_to cart_path(@cart), alert: 'There was an issue creating your order.'
  end

  def checkout_cancel
    redirect_to cart_path, alert: 'Your payment was canceled.'
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
