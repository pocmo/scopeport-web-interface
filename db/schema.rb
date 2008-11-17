# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20081115152126) do

  create_table "alarms", :force => true do |t|
    t.integer "type"
    t.integer "timestamp"
    t.integer "hostid"
    t.integer "st"
    t.integer "checkid"
    t.float   "sv"
    t.boolean "status"
  end

  create_table "blacklist", :force => true do |t|
    t.string   "host"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "downtimes", :force => true do |t|
    t.boolean  "scheduled"
    t.integer  "hostid"
    t.integer  "serviceid"
    t.integer  "from"
    t.integer  "to"
    t.integer  "type"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "emergencies", :force => true do |t|
    t.integer "timestamp"
    t.integer "reportedby"
    t.integer "severity"
    t.string  "name"
    t.text    "description"
    t.boolean "active"
  end

  create_table "emergencynotifications", :force => true do |t|
    t.integer "emergencyid"
    t.integer "notifiedon"
    t.string  "email"
    t.string  "jid"
    t.string  "numberc"
  end

  create_table "hostgroups", :force => true do |t|
    t.string "name"
  end

  create_table "hosts", :force => true do |t|
    t.integer "hostid"
    t.integer "hostgroup"
    t.string  "name"
    t.string  "password"
    t.string  "clientversion"
    t.string  "ip4addr"
    t.string  "tz1_name"
    t.string  "tz2_name"
    t.string  "tz3_name"
    t.string  "tz4_name"
    t.string  "os"
    t.string  "hostname"
    t.string  "linux_kernelversion"
    t.string  "domainname"
    t.string  "hda_model"
    t.string  "hdb_model"
    t.string  "hdc_model"
    t.string  "hdd_model"
    t.string  "total_memory"
    t.string  "total_swap"
    t.string  "cpu_vendor"
    t.string  "cpu_modelname"
    t.string  "cpu_mhz"
    t.string  "cpu_cachesize"
    t.string  "swaps"
    t.string  "scsi"
    t.text    "description"
    t.boolean "public"
    t.boolean "disabled"
  end

  create_table "lastsensordata", :force => true do |t|
    t.string  "sv"
    t.integer "st"
    t.integer "host"
    t.integer "timestamp"
  end

  create_table "logmessages", :id => false, :force => true do |t|
    t.integer "logtime"
    t.integer "severity"
    t.string  "errorcode"
    t.string  "logmsg"
  end

  create_table "notificationgroupdetails", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notificationgroups", :force => true do |t|
    t.integer "warninggroup"
    t.integer "sevborder"
    t.string  "mail"
    t.string  "jid"
    t.string  "numberc"
    t.boolean "email"
    t.boolean "xmpp"
    t.boolean "mobilec"
    t.boolean "deleted"
  end

  create_table "sensor_conditions", :force => true do |t|
    t.integer "hostid"
    t.integer "st"
    t.integer "lastwarn"
    t.integer "warninggroup"
    t.integer "severity"
    t.string  "type"
    t.float   "value"
    t.boolean "disabled"
  end

  create_table "sensordata", :force => true do |t|
    t.string  "sv"
    t.integer "st"
    t.integer "host"
    t.integer "timestamp"
  end

  add_index "sensordata", ["st"], :name => "index_sensordata_on_st"
  add_index "sensordata", ["host"], :name => "index_sensordata_on_host"

  create_table "sensors", :force => true do |t|
    t.integer "st"
    t.integer "standard_condition_value"
    t.string  "name"
    t.string  "standard_condition_type"
    t.text    "description"
    t.boolean "overview"
    t.boolean "needscondition"
    t.boolean "hide"
  end

  create_table "servicedata", :force => true do |t|
    t.integer "timestamp"
    t.integer "serviceid"
    t.integer "type"
    t.integer "ms"
  end

  create_table "services", :force => true do |t|
    t.string   "name"
    t.string   "host"
    t.string   "service_type"
    t.integer  "port"
    t.integer  "responsetime"
    t.integer  "maxres"
    t.integer  "timeout"
    t.integer  "warninggroup"
    t.integer  "linkedhost"
    t.integer  "lastwarn"
    t.integer  "lastcheck"
    t.integer  "state"
    t.boolean  "disabled",     :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "settings", :force => true do |t|
    t.string  "spserver"
    t.string  "mail_server"
    t.string  "mail_user"
    t.string  "mail_pass"
    t.string  "mail_hostname"
    t.string  "mail_from"
    t.string  "xmpp_server"
    t.string  "xmpp_user"
    t.string  "xmpp_pass"
    t.string  "xmpp_resource"
    t.string  "mobilecUsername"
    t.string  "mobilecPassword"
    t.string  "mobilecAPIID"
    t.integer "spport"
    t.integer "mail_port"
    t.integer "xmpp_port"
    t.integer "gnotigroup"
    t.integer "eg1"
    t.integer "eg2"
    t.integer "eg3"
    t.boolean "mail_enabled"
    t.boolean "mail_useauth"
    t.boolean "mail_usetls"
    t.boolean "xmpp_enabled"
    t.boolean "doMobileClickatell"
  end

  create_table "vitals", :primary_key => "pid", :force => true do |t|
    t.integer "threads"
    t.integer "timestamp"
    t.boolean "clienthandler"
    t.string  "vmem"
    t.string  "packetsOK"
    t.string  "packetsERR"
    t.string  "dbtotalsize"
    t.string  "dbsensorsize"
    t.string  "dbservicesize"
  end

end
