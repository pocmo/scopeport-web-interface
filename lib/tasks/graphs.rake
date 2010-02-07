namespace :graphfactory do
  desc "Generate all service graphs"
  task :services => :environment do
    services = Service.find :all
    services.each do |service|
      begin
        puts "=== Service '#{service.name}' ==="
        rrd_filename = RAILS_ROOT + "/db/colored-rrds/service-#{service.id.to_i}.rrd"
        rrd = File.open rrd_filename
        last_value = `#{RRDTOOL_PATH} last #{rrd_filename} 2>/dev/null`
        puts "Last stored value is from #{Time.at last_value.to_i}"

        records = Servicerecord.find_all_by_serviceid service.id, :group => "timestamp", :order => "timestamp ASC", :conditions => [ "timestamp > ?",  last_value.to_i ]
        puts "Inserting #{records.count} values into RRD..."
        records.each do |record|
          `#{RRDTOOL_PATH} update #{rrd_filename} #{record.timestamp.to_i}:#{record.ms.to_i} 2>/dev/null`
        end
      rescue => e
        puts "Error: #{e}"
        next
      end
    end
  end

  desc "Generate all host graphs"
  task :hosts => :environment do
    graphs = [
      { :name => "cpuload", :type => "float", :representing => [ "cpu_load_average_1", "cpu_load_average_5", "cpu_load_average_15" ] },
      { :name => "disk-read-ops", :type => "integer", :representing => [ "read_operations" ] },
      { :name => "disk-write-ops", :type => "integer", :representing => [ "write_operations" ] },
      { :name => "free-memory", :type => "integer", :representing => [ "free_memory" ] },
      { :name => "open-files", :type => "integer", :representing => [ "open_files" ] },
      { :name => "processes", :type => "integer", :representing => [ "running_processes" ] },
      { :name => "total-processes", :type => "integer", :representing => [ "total_processes" ] }
    ]

    hosts = Host.find :all
    hosts.each do |host|
      puts "=== Host '#{host.name}' ==="
      graphs.each do |graph|
        begin
          puts " \t== Graph: #{graph[:name]} =="
          rrd_filename = RAILS_ROOT + "/db/colored-rrds/host-#{graph[:name]}-#{host.id.to_i}.rrd"
          rrd = File.open rrd_filename
          last_value = `#{RRDTOOL_PATH} last #{rrd_filename} 2>/dev/null`
          puts "\tLast stored value is from #{Time.at last_value.to_i}"

          sensors = Array.new
          graph[:representing].each do |represents|
            sensors << Sensorvalue.find_all_by_host_id(host.id, :group => "created_at", :order => "created_at ASC", :conditions => [ "name = ? AND created_at > ?", represents, Time.at(last_value.to_i) ])
          end
          
          puts "\tInserting #{sensors.inject(0){ |sum,records| sum + records.count }} values into RRD..."

          ready_sensors = Hash.new

          i = 0
          sensors.each do |sensor|
            valuestring = String.new
            j = 0
            sensor.each do |record|
              ready_sensors[j] = Array.new if ready_sensors[j].blank?
              ready_sensors[j][i] = { :timestamp => record.created_at.to_i, :value => record.value }
              j += 1;
            end
            i+=1
          end

          ready_sensors_sorted = ready_sensors.sort

          ready_sensors_sorted.each do |ready_sensor|
            valuestring = String.new
            timestamp_set = false
            ready_sensor[1].each do |record|
              value = 0
              case graph[:type]
                when "float":
                  value = record[:value].to_f
                when "integer":
                  value = record[:value].to_i
              end

              unless timestamp_set
                valuestring << record[:timestamp].to_s 
                timestamp_set = true
              end
              valuestring << ":#{record[:value]}"

              i += 1
            end
            `#{RRDTOOL_PATH} update #{rrd_filename} #{valuestring} 2>/dev/null`
          end
        rescue => e
          puts "\tError: #{e}"
          puts "\tSkipping"
          next
        end
      end
    end
  end

  desc "Create both service and host graphs"
  task :all => [:services, :hosts]
end
