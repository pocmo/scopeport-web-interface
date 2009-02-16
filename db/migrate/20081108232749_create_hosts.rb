class CreateHosts < ActiveRecord::Migration
  def self.up
		create_table :hosts do |t|
			t.integer :hostid, :hostgroup
			t.string :name, :password, :clientversion, :ip4addr, :tz1_name, :tz2_name, :tz3_name, :tz4_name
			t.string :os, :hostname, :linux_kernelversion, :domainname, :hda_model, :hdb_model, :hdc_model, :hdd_model
			t.string :total_memory, :total_swap, :cpu_vendor, :cpu_modelname, :cpu_mhz, :cpu_cachesize, :swaps, :scsi
			t.text :description
			t.boolean :public, :disabled
		end
  end

  def self.down
		drop_table :hosts
  end
end
