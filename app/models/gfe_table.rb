class GfeTable
  include Mongoid::Document

  field :act, type: String
  field :employment, type: String
  field :level, type: Integer
  field :value, type: Float
end