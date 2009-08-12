class Sensorcondition < ActiveRecord::Base
  validates_presence_of :host_id
  validates_presence_of :sensor
  validates_presence_of :operator
  validates_presence_of :value
end
