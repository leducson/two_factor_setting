class TwoFactorSettingsController < ApplicationController
  before_action :required_password, only: [:new, :edit]

  def show
    return redirect_to new_two_factor_settings_path unless session[:codes] && current_user.otp_backup_codes?
    return redirect_to edit_two_factor_settings_path if current_user.otp_required_for_login?

    @backup_codes = session[:codes]
  end

  def new
    return redirect_to edit_two_factor_settings_path if current_user.otp_required_for_login?

    session.delete :password_token
    current_user.update! otp_secret: User.generate_otp_secret unless current_user.otp_secret?
  rescue StandardError => e
    flash[:danger] = e.message
  end

  def edit
    if current_user.otp_required_for_login?
      session.delete :password_token
      return
    end

    flash[:danger] = "Please enable two factor setting first"
    redirect_to new_two_factor_settings_path
  end

  def update
    if current_user.update otp_required_for_login: true
      flash[:success] = "Enable two factor setting is success"
      session.delete :codes
      session[:password_token] = current_user.encrypted_password
      redirect_to edit_two_factor_settings_path
    else
      flash[:danger] = "Enable two factor setting is failed"
      redirect_to new_two_factor_settings_path
    end
  end

  def destroy
    if current_user.update disable_two_factor_params
      flash[:success] = "Disable two factor success"
      session.delete :password_token
      redirect_to root_path
    else
      flash[:danger] = "Disable two factor is failed"
      render :edit
    end
  end

  def verify_otp
    if enable_2fa_params_code[:code].blank?
      flash.now[:danger] = "OTP Code not blank"
      render :new and return
    end

    if current_user.validate_and_consume_otp! enable_2fa_params_code[:code]
      backup_codes = current_user.generate_otp_backup_codes!
      current_user.save!
      session[:codes] = backup_codes
      redirect_to two_factor_settings_path(current_user)
    else
      flash.now[:danger] = "OTP Code not valid. Please try again"
      render :new
    end
  rescue StandardError => e
    flash.now[:danger] = e.message
    render :new
  end

  def generate_backup_code
    return unless current_user.otp_required_for_login?

    @backup_codes = current_user.generate_otp_backup_codes!
    current_user.save!
  rescue StandardError
    flash[:danger] = "Something went wrong"
    redirect_to edit_two_factor_settings_path
  end

  def download
    send_data params[:two_fa][:codes], filename: "backup_codes.txt"
  end

  def confirm_password
    unless current_user.valid_password? enable_2fa_params_password[:password]
      flash.now[:danger] = "Current password not valid. Please try again"
      return render "two_factor_settings/required_password"
    end

    session[:password_token] = current_user.encrypted_password
    redirect_to new_two_factor_settings_path
  end

  private

  def required_password
    return if session[:password_token] == current_user.encrypted_password

    render "two_factor_settings/required_password"
  end

  def enable_2fa_params_code
    params.require(:two_fa).permit(:code)
  end

  def enable_2fa_params_password
    params.require(:two_fa).permit(:password)
  end

  def disable_two_factor_params
    {
      otp_required_for_login: false,
      otp_secret: nil,
      otp_backup_codes: nil
    }
  end
end
