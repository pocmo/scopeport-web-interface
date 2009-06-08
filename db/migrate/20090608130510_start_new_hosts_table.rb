class StartNewHostsTable < ActiveRecord::Migration
  def self.up
    remove_column :hosts, :hostid
    rename_column :hosts, :hostgroup, :hostgroup_id
    remove_column :hosts, :tz1_name
    remove_column :hosts, :tz2_name
    remove_column :hosts, :tz3_name
    remove_column :hosts, :tz4_name
    remove_column :hosts, :hda_model
    remove_column :hosts, :hdb_model
    remove_column :hosts, :hdc_model
    remove_column :hosts, :hdd_model
    remove_column :hosts, :cpu_vendor
    remove_column :hosts, :cpu_modelname
    remove_column :hosts, :cpu_mhz
    remove_column :hosts, :cpu_cachesize
    remove_column :hosts, :swaps
    remove_column :hosts, :scsi
    remove_column :hosts, :public
    remove_column :hosts, :disabled
  end

  def self.down
    add_column :hosts, :hostid, :integer
    rename_column :hosts, :hostgroup_id, :hostgroup
    add_column :hosts, :tz1_name, :string
    add_column :hosts, :tz2_name, :string
    add_column :hosts, :tz3_name, :string
    add_column :hosts, :tz4_name, :string
    add_column :hosts, :hda_model, :string
    add_column :hosts, :hdb_model, :string
    add_column :hosts, :hdc_model, :string
    add_column :hosts, :hdd_model, :string
    add_column :hosts, :cpu_vendor, :string
    add_column :hosts, :cpu_modelname, :string
    add_column :hosts, :cpu_mhz, :string
    add_column :hosts, :cpu_cachesize, :string
    add_column :hosts, :swaps, :string
    add_column :hosts, :scsi, :string
    add_column :hosts, :public, :boolean
    add_column :hosts, :disabled, :boolean
  end
end
