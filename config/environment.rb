# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!

ActionMailer::Base.smtp_settings = {
  user_name: ENV['EMAIL_USER_NAME'],
  password: ENV['EMAIL_PASSWORD'],
  address: ENV['EMAIL_SMTP_ADDRESS'],
  port: 587,
  authentication: :plain,
  enable_starttls_auto: true
}