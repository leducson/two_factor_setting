class Users::SessionsController < Devise::SessionsController
  include AuthenticateWithOtpTwoFactor

  prepend_before_action :authenticate_with_otp_two_factor, if: -> {action_name == "create" && otp_two_factor_enabled?}

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  def create
    super
  end

  # DELETE /resource/sign_out
  def destroy
    super
    session.delete :password_token
    session.delete :codes
  end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
