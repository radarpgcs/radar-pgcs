module EmployeeConcern
  extend ActiveSupport::Concern

  SPECIAL_CHARACTERS = YAML.load_file(Rails.root.join('metadata', 'latin_chars.yaml'))
  STOPWORDS = File.read(Rails.root.join 'metadata', 'stopwords').split("\n")

  def prepare_tags_field
    tokens = [self.format_registry, self.name]
    tokens << self.employment if self.employment
    tokens << self.department if self.department
    tokens << self.regional if self.regional
    tokens << self.hiring_date.strftime('%d/%m/%Y') if self.hiring_date

    self.tags = _create_tags tokens
  end

  def format_registry
    return nil unless self.registry

    formatted = self.registry.to_s
    while formatted.size < 8 do
      formatted = '0' + formatted
    end

    return formatted
  end

  private

  def _create_tags(fields)
    tags = []
    
    fields.each do |field|
      tokens = _get_tags_without_stopwords(field)
      tokens.delete_if {|t| tags.include? t }
      tags.concat tokens
    end
    
    tags
  end

  def _get_tags_without_stopwords(text)
    txt = _replace_special_characters text
    return txt if txt.nil?
    
    tags = txt.downcase.split(/[\s\/]/)
    tags.delete_if {|t| STOPWORDS.include? t }
    tags
  end

  def _replace_special_characters(text)
    return text if text.nil?

    txt = text.dup
    SPECIAL_CHARACTERS.each {|k, v| txt.gsub! /#{k}/, v }
    txt.gsub! /[()]/, ''
    txt
  end
end