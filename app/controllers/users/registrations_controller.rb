class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_permitted_parameters, if: :devise_controller?

  def create
    super do |user|
      if user.persisted?
        user.update_column(:terms_accepted_at, Time.current)
      end
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :avatar, :accept_terms])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :avatar])
  end
end
