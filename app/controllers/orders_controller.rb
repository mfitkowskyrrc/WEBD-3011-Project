class OrdersController < ApplicationController
  before_action :set_order, only: [ :show, :edit, :update, :destroy ]
  before_action :authorize_admin, only: [ :new, :create ]

  def index
    if current_customer.admin?
      @orders = Order.all
    else
      @orders = current_customer.orders
    end
  end

  def show
    @order = Order.find(params[:id])

    if current_customer != @order.customer && !current_customer.admin?
      redirect_to orders_path, alert: "You are not authorized to view this order."
    end
  end

  def new
    @order = Order.new
    @order.customer = current_customer
  end

  def edit
    @order = Order.find(params[:id])
  end

  def create
    @order = Order.new(order_params)
    @order.customer = current_customer
    @order.province = current_customer.province
    @order.postal_code = current_customer.postal_code
    @order.status = "processing"

    respond_to do |format|
      if @order.save
        format.html { redirect_to @order, notice: "Order was successfully created." }
        format.json { render :show, status: :created, location: @order }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @order.update(order_params)
        format.html { redirect_to @order, notice: "Order was successfully updated." }
        format.json { render :show, status: :ok, location: @order }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @order.destroy!

    respond_to do |format|
      format.html { redirect_to orders_path, status: :see_other, notice: "Order was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def set_order
    @order = Order.find(params[:id])
  end

  def order_params
    params.require(:order).permit(:customer_id, :order_date, :total_amount, :province, :postal_code, :status)
  end

  def authorize_admin
    redirect_to root_path, alert: "You are not authorized to perform this action." unless current_customer.admin?
  end
end
