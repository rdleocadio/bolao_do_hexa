class ApplicationController < ActionController::Base
  before_action :normalize_locale
  before_action :set_locale
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :avatar, :accept_terms])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :avatar])
  end

  private

  def normalize_locale
    return unless params[:locale] == "pt-br"

    redirect_to url_for(locale: "pt-BR"), status: :moved_permanently
  end

  def set_locale
    I18n.locale =
      if params[:locale].present?
        params[:locale].to_s.gsub("pt-br", "pt-BR")
      else
        I18n.default_locale
      end
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
