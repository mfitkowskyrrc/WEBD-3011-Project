class HomeController < ApplicationController
  before_action :set_content, only: [ :edit, :update ]

  def home
    @about_us_content = Content.find_by(section: "about_us")
    @contact_us_content = Content.find_by(section: "contact_us")
    @categories = Category.all
    @events = Event.all
  end

  def edit
  end

  def update
    if @content.update(content_params)
      flash[:notice] = "#{@content.section.titleize} content updated successfully."
      redirect_to home_path
    else
      render :edit
    end
  end

  private

  def set_content
    @content = Content.find_by(section: params[:section])
  end

  def content_params
    params.require(:content).permit(:content)
  end
end
