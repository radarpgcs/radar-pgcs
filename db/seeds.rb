init = Time.now
raise 'Could not find environment variable ADMIN_ID' if ENV['ADMIN_ID'].nil?

User.new do |u|
  u.registry = ENV['ADMIN_ID']
  u.password = 'changeit'
  u.status = 'INACTIVE'
  u.roles = %w(ADMINISTRATOR COLLABORATOR MEMBER)
end.save! unless User.where(registry: ENV['ADMIN_ID']).exists?

changelog_dir = Rails.root.join 'metadata', 'changelog'
News.delete_all
puts 'Rewriting news collection'

Dir.entries(changelog_dir).each do |changelog|
  next if changelog.match(/\A\.{1,2}\z/)
  File.readlines(File.join changelog_dir, changelog).each do |line|
    News.new(version: changelog, message: line.strip).save!
  end
end

puts
puts 'Seeding finished!'
puts Time.now - init