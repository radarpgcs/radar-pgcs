raise 'Could not find environment variable ADMIN_ID' if ENV['ADMIN_ID'].nil?

User.new do |u|
  u.registry = ENV['ADMIN_ID']
  u.password = 'changeit'
  u.status = 'INACTIVE'
  u.roles = %w(ADMINISTRATOR COLLABORATOR MEMBER)
end.save! unless User.where(registry: ENV['ADMIN_ID']).exists?