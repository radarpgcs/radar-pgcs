class User
  include Mongoid::Document

  VALID_ROLES = %w(ADMINISTRATOR COLLABORATOR MEMBER)

  field :registry, type: Integer
  field :password, type: String
  field :salt_number, type: String
  field :status, type: String
  field :status_note, type: String
  field :last_login, type: Time
  field :version_visited, type: String
  field :roles, type: Array

  validates :registry, presence: true, uniqueness: true
  validates :password, presence: true, length: { minimum: 5, maximum: 20 }
  validates :salt_number, presence: true
  validates :status, presence: true, inclusion: { in: %w(ACTIVE INACTIVE BLOCKED) }
  validate :validate_roles

  def ==(obj)
    return false if obj.nil?
    return false unless self.class == obj.class
    
    (self.registry == obj.registry)
  end

  def validate_roles
    if self.roles.nil?
      errors.add(:roles, I18n.translate('errors.messages.blank'))
    elsif !self.roles.is_a?(Array) || self.roles.empty?
      message = I18n.translate('errors.messages.array_not_empty')
      errors.add(:roles, message)
    elsif self.roles.size > VALID_ROLES.size
      message = I18n.translate('errors.messages.array_with_max_size', max_size: VALID_ROLES.size)
      errors.add(:roles, message)
    elsif (self.roles & VALID_ROLES) != self.roles
      message = I18n.translate('errors.messages.array_inclusion', expected_values: VALID_ROLES.join(' '))
      errors.add(:roles, message)
    end
  end
end