class CustomFilter < ActiveRecord::Base
	belongs_to :users
	serialize :filters
	validates_presence_of :name
		
	#Override the to_json method, so anything goes to json and to the JS layer
	def to_json
		result = {}
		self.filters.collect { |c| result[c[0].to_sym] = c[1] }
		return result.to_json
	end
	
end
