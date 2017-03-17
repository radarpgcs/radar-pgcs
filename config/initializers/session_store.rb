# Be sure to restart your server when you modify this file.

session_timeout = case Rails.env
  when 'development' then 3.hours
  when 'test' then 10.minutes
  when 'production' then 10.minutes
end

Rails.application.config.session_store :cookie_store, key: '_radar-pgcs_session',
  expire_after: session_timeout