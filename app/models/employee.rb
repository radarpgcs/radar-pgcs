class Employee
  include Mongoid::Document
  include EmployeeConcern

  field :registry, type: Integer
  field :cpf, type: String
  field :name, type: String
  field :employment, type: String
  field :category, type: String
  field :reference, type: String
  field :department, type: String
  field :regional, type: String
  field :hiring_date, type: Date
  field :active, type: Boolean
  field :eventual_gfe, type: Float
  field :views, type: Integer
  field :tags, type: Array

  has_many :payment

  validates :registry, presence: true, uniqueness: true
  validates :name, presence: true, length: { minimum: 5, maximum: 80 }
  validates :active, presence: true

  before_save :prepare_tags_field

  def ==(obj)
    return false if obj.nil?
    return false unless self.class == obj.class
    
    (self.registry == obj.registry)
  end
end