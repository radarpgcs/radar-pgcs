module UserConcern
  extend ActiveSupport::Concern

  MAX_SIZE_PASSWORD = 20
  VALID_ROLES = %w(ADMINISTRATOR COLLABORATOR MEMBER)

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

  protected
  def set_credentials
    if self.password.to_s.size <= MAX_SIZE_PASSWORD
      self.salt_number ||= Services::Security.generate_salt_number
      self.password = Services::Security.generate_hash self.password, self.salt_number
    end
  end
end