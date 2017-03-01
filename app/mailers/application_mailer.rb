class ApplicationMailer < ActionMailer::Base
  default from: ENV['ADMIN_EMAIL']
  layout 'mailer'

  def send_contact_email(params)
    @params = params
    mail to: ENV['ADMIN_EMAIL'], subject: params[:subject]
  end
end