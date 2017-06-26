class Payment
  include Mongoid::Document

  MIN_YEAR = 2016
  MAX_YEAR = Time.now.year
  MIN_MONTH = 1
  MAX_MONTH = 12

  field :year, type: Integer
  field :month, type: Integer
  field :total, type: Float
  field :eventual, type: Float
  field :net_salary, type: Float

  belongs_to :employee

  validates :year, presence: true, numericality: {
  	only_integer: true, greater_than_or_equal_to: MIN_YEAR,
  	less_than_or_equal_to: MAX_YEAR
  }
  validates :month, presence: true, numericality: {
  	only_integer: true, greater_than_or_equal_to: MIN_MONTH,
  	less_than_or_equal_to: MAX_MONTH
  }
  validates :total, presence: true, numericality: {
  	only_integer: false
  }

  def ==(obj)
    return false if obj.nil?
    return false unless self.class == obj.class
    
    (
      (self.total == obj.total) &&
      (self.eventual == obj.eventual) &&
      (self.month == obj.month) &&
      (self.year == obj.year)
    )
  end
end