class SalaryScale
  include Mongoid::Document

  field :act, type: String
  field :scale, type: String
  field :step_a, type: Float
  field :step_b, type: Float
end