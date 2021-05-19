class User < ApplicationRecord
  attr_accessor :backup_code_attempt

  devise :two_factor_authenticatable, :two_factor_backupable, otp_backup_code_length: 10, otp_number_of_backup_codes: 10,
         :otp_secret_encryption_key => ENV["OTP_SECRET_KEY"]

  devise :registerable, :recoverable, :rememberable, :validatable

  def two_factor_qr_code_uri
   issuer = ENV["OTP_2FA_ISSUER_NAME"]
   label = [issuer, email].join(":")

   otp_provisioning_uri label, issuer: issuer
  end
end
