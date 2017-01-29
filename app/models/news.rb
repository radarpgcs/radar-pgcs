class News
  include Mongoid::Document
  field :version, type: String
  field :message, type: String

  validates :version, presence: true, format: { with: /\A\d{1,3}\.\d{1,3}\.\d{1,3}\z/ }
  validates :message, presence: true, length: { minimum: 3, maximum: 300 }

  def ==(obj)
    return false if obj.nil?
    return false unless self.class == obj.class
    
    (self.message == obj.message) && (self.version == obj.version)
  end
end