class Emergencychatmessage < ActiveRecord::Base
  validates_presence_of :message
  belongs_to :user
end
