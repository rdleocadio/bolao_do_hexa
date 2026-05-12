class ApplicationController < ActionController::Base
  before_action :set_locale
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :avatar, :accept_terms])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :avatar])
  end

  private

  def set_locale
    I18n.locale = params[:locale].presence || I18n.default_locale
  end

  def default_url_options
    { locale: I18n.locale }
  end

  def require_admin!
    unless current_user&.admin?
      redirect_to root_path, alert: t("errors.unauthorized")
    end
  end
end
