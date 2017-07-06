class ApplicationMailer < ActionMailer::Base
  admin_email = Rails.configuration.radarpgcs[:admin_email]
  default from: admin_email
  layout 'mailer'

  def send_contact_email(params)
    @params = params
    mail to: admin_email, subject: params[:subject]
  end
end