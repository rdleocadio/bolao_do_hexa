class PagesController < ApplicationController
  def home
    redirect_to leagues_path if user_signed_in?
  end

  def rules
  end
end
