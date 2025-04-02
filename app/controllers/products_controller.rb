class ProductsController < ApplicationController
  before_action :authenticate_customer!, except: [:index, :show]
  before_action :authorize_admin, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_product, only: [:show, :edit, :update, :destroy]

  def index
    @categories = Category.all

    @products = if params[:category].present?
                  Product.where(category_id: params[:category])
                else
                  Product.all
                end

    @products = @products.page(params[:page]).per(15)
  end

  def show
  end

  def new
    @product = Product.new
  end

  def edit
  end

  def create
    @product = Product.new(product_params)

    respond_to do |format|
      if @product.save
        format.html { redirect_to @product, notice: "Product was successfully created." }
        format.json { render :show, status: :created, location: @product }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to @product, notice: "Product was successfully updated." }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @product.destroy!

    respond_to do |format|
      format.html { redirect_to products_path, status: :see_other, notice: "Product was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :description, :price, :stock_quantity, :category_id, :image)
  end

  def authorize_admin
    redirect_to root_path, alert: "You are not authorized to perform this action." unless current_customer.admin?
  end
end
