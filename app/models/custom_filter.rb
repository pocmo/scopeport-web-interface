class CustomFilter < ActiveRecord::Base
	belongs_to :users
	serialize :filters
	validates_presence_of :name
	
end
