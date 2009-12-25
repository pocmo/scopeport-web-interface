class Topgraph < ActiveRecord::Base
  validates_presence_of :graph_type, :target_id, :name, :minutes
  validates_numericality_of :graph_type, :target_id, :minutes

  validates_length_of :name, :maximum => 5
end
