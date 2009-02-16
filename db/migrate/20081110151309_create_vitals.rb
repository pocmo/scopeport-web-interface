class CreateVitals < ActiveRecord::Migration
  def self.up
    create_table :vitals, :primary_key => :pid do |t|
			t.integer :threads, :timestamp
			t.boolean :clienthandler
			t.string :vmem, :packetsOK, :packetsERR, :dbtotalsize, :dbsensorsize, :dbservicesize
    end
  end

  def self.down
    drop_table :vitals
  end
end
