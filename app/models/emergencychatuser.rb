class Emergencychatuser < ActiveRecord::Base
  named_scope :active, lambda { |time|  { :conditions => ["updated_at > ?", time ] } }
end
