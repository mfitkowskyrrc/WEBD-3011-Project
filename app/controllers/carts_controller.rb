class CartsController < ApplicationController
  before_action :set_cart, only: [:show, :add_product, :remove_product]

  def show
    @cart_items = @cart.cart_items.includes(:product)
  end

  def add_product
    product = Product.find(params[:product_id])
    if @cart.cart_items.find_by(product_id: product.id).present?
      @cart.cart_items.find_by(product_id: product.id).increment(:quantity).save
    else
      @cart.cart_items.create(product: product)
    end
    redirect_to cart_path(@cart)
  end

  def remove_product
    product = Product.find(params[:product_id])
    @cart.cart_items.find_by(product_id: product.id).destroy
    redirect_to cart_path(@cart)
  end

  def checkout
  end

  private

  def set_cart
    @cart = current_customer.cart
  end
end
