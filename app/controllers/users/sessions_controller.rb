class Users::SessionsController < Devise::SessionsController
  def create
    self.resource = warden.authenticate(auth_options)

    if resource
      set_flash_message!(:notice, :signed_in)
      sign_in(resource_name, resource)
      respond_with resource, location: after_sign_in_path_for(resource)
    else
      flash[:alert] = "E-mail ou senha inválidos."
      redirect_to root_path(user: { email: params.dig(:user, :email) }, anchor: "login")
    end
  end

  def new
    redirect_to root_path(anchor: "login")
  end
end
