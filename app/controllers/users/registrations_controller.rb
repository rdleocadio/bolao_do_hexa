class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_permitted_parameters, if: :devise_controller?

  def create
    super do |user|
      if user.persisted?
        user.update_column(:terms_accepted_at, Time.current)
      end
    end
  end

  def destroy
    unless current_user.valid_password?(params[:current_password])
      flash[:alert] = "Senha incorreta."

      redirect_back fallback_location: edit_user_registration_path
      return
    end

    super
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :avatar, :accept_terms])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :avatar])
  end
end
