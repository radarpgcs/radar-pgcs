def _load_fixtures
  models = _get_models
  fixtures_path = Rails.root.join 'test', 'fixtures'

  Dir.entries(fixtures_path).each do |file|
    next unless file.end_with? '.yml'

    model = models[file.sub('.yml', '')]
    model.delete_all
    
    YAML.load_file(File.join fixtures_path, file).each do |key, values|
      model.create values
    end
  end
end

def _get_models
  colls = {}

  Dir.entries(Rails.root.join 'app', 'models').each do |name|
    next unless name.end_with? '.rb'
    clazz = name.sub('.rb', '').split('_').collect { |piece| piece.capitalize }.join
    model = Object.const_get(clazz)

    colls[model.model_name.plural] = model
  end

  colls
end