class CartsController < ApplicationController
  def show
    @cart_items = @cart.cart_items.includes(:product)
  end

  def add_product
    product = Product.find(params[:product_id])
    cart_item = @cart.cart_items.find_by(product: product)

    if cart_item
      cart_item.update(quantity: cart_item.quantity + 1)
    else
      @cart.cart_items.create(product: product, quantity: 1)
    end
  end
end
