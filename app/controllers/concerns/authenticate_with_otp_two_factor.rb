module AuthenticateWithOtpTwoFactor
  extend ActiveSupport::Concern

  def authenticate_with_otp_two_factor
    user = self.resource = find_user

    return prompt_for_two_factor(user) if session[:otp_admin_id].blank?

    authenticate_user_with_backup_code_two_factor(user) if params[:code_type] == "backup_code"
    authenticate_user_with_otp_two_factor(user) unless params[:code_type] == "backup_code"
  end

  private

  def prompt_for_two_factor user
    return unless session[:otp_admin_id] || user&.valid_password?(user_params[:password])

    @user = user
    session[:otp_admin_id] = user.id
    render "devise/sessions/two_factor"
  end

  def authenticate_user_with_otp_two_factor user
    if user_params[:otp_attempt].blank?
      flash.now[:danger] = "OTP Code not blank"
      prompt_for_two_factor user
      return
    end

    if user.current_otp == user_params[:otp_attempt] && user&.validate_and_consume_otp!(user_params[:otp_attempt])
      session.delete :otp_admin_id
      sign_in user
    else
      flash.now[:danger] = "OTP Code invalid. Please try again"
      prompt_for_two_factor user
    end
  rescue StandardError => e
    flash.now[:danger] = e.message
    prompt_for_two_factor user
  end

  def authenticate_user_with_backup_code_two_factor user
    if user_params[:backup_code_attempt].blank?
      flash.now[:danger] = "Backup Code not blank. Please try again"
      prompt_for_two_factor user
      return
    end

    if user&.invalidate_otp_backup_code!(user_params[:backup_code_attempt])
      session.delete :otp_admin_id
      sign_in user
    else
      flash.now[:danger] = "Backup code invalid"
      prompt_for_two_factor user
    end
  rescue StandardError => e
    flash.now[:danger] = e.message
    prompt_for_two_factor admin
  end

  def user_params
    params.require(:user).permit(:email, :password, :otp_attempt, :backup_code_attempt)
  end

  def find_user
    if user_params[:email]
      User.find_by email: user_params[:email]
    elsif session[:otp_admin_id]
      User.find_by id: session[:otp_admin_id]
    end
  end

  def otp_two_factor_enabled?
    find_user&.otp_required_for_login?
  end
end
