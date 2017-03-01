class Promotion
  include Mongoid::Document
  
  MIN_YEAR = 2009
  MAX_YEAR = Time.now.year

  field :year, type: Integer
  field :type, type: String
  field :external_staff, type: Mongoid::Boolean

  belongs_to :employee

  validates :year, presence: true, numericality: {
  	only_integer: true, greater_than_or_equal_to: MIN_YEAR,
  	less_than_or_equal_to: MAX_YEAR
  }
  validates :type, presence: true, format: { with: /(PM|PTS)+/ }
  validates :external_staff, presence: true
end