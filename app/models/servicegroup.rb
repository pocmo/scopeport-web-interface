class Servicegroup < ActiveRecord::Base
  validates_presence_of :name
  has_many :services
end
