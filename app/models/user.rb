class User
  include Mongoid::Document
  include UserConcern

  field :registry, type: Integer
  field :password, type: String
  field :salt_number, type: String
  field :status, type: String
  field :status_note, type: String
  field :last_login, type: Time
  field :version_visited, type: String
  field :roles, type: Array

  validates :registry, presence: true, uniqueness: true
  validates :password, presence: true, length: { minimum: 5, maximum: 100 }
  validates :salt_number, presence: true
  validates :status, presence: true, inclusion: { in: %w(ACTIVE INACTIVE BLOCKED) }
  validate :validate_roles

  def ==(obj)
    return false if obj.nil?
    return false unless self.class == obj.class
    
    (self.registry == obj.registry)
  end
end