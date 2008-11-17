class CreateLogmessages < ActiveRecord::Migration
  def self.up
		create_table :logmessages, :id => false do |t|
			t.integer :logtime, :severity
			t.string :errorcode, :logmsg
		end
  end

  def self.down
		drop_table :logmessages
  end
end
