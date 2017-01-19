class Auditing
  include Mongoid::Document

  field :ip, type: String
  field :event, type: String
  field :event_date, type: Time
  field :url, type: String

  belongs_to :user, :class_name => 'User'

  validates :event, presence: true, inclusion: { in: %w(LOGIN LOGOUT EMPLOYEE_VIEW) }
  validates :event_date, presence: true
end