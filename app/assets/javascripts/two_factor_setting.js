
$(document).ready(function() {
  $(document).on('click', '.btn-two-factor-copy', function() {
    $('.list-backup-codes').val(getOtpBackupCodes());
    $('.list-backup-codes').removeClass('hide');
    $('.list-backup-codes').select();
    document.execCommand('copy');
    $('.list-backup-codes').addClass('hide');
    $('.copy_message').removeClass('hide');
    $('.btn-enable-two-factor').removeAttr('disabled');
  });

  $(document).on('click', '.btn-two-factor-download', function() {
    $('.list-backup-codes').val(getOtpBackupCodes());
    $('.download-two-factor').submit();
    $('.btn-enable-two-factor').removeAttr('disabled');
  });

  function getOtpBackupCodes() {
    var thelist = $('.otp-backup-codes').html();
    thelist = thelist.replace(/\s+<div class="col-md-6"><code>/g, '');
    thelist = thelist.replace(/<\/?code><\/div>/g, '\r');
    return thelist;
  }

  $(document).on('click', '.recover_code_link', function() {
    $('.otp_code').addClass('hide');
    $('.backup_code').removeClass('hide');
    $('#admin_code_type').val('backup_code');
    $('#admin_backup_code_attempt').focus();
  });

  $(document).on('click', '.otp_code_link', function() {
    $('.backup_code').addClass('hide');
    $('.otp_code').removeClass('hide');
    $('#admin_code_type').val('otp_code');
    $('#admin_otp_attempt').focus();
  });

  setTimeout(function() {
    $(".login_content .alert").fadeOut(3000);
  }, 3000);
});
