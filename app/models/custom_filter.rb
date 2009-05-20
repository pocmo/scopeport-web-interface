class CustomFilter < ActiveRecord::Base
	belongs_to :users
	serialize :filters
	validates_presence_of :name
	validates_uniqueness_of :name
	
end
