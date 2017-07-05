settings = {}
settings[:version] = '0.1.0'
settings[:scm_url] = 'https://github.com/radarpgcs/radar-pgcs'

last_year = 0
last_act = nil
GfeTable.only(:act).distinct(:act).each do |act|
  year = /\A\d+-(\d+)\z/.match(act).captures.first.to_i
  last_act = act if year > last_year
end

settings[:current_act] = last_act

Rails.configuration.radarpgcs = settings