module Colored

	module Core

		class RRDGraph
			#TODO: get this from a global config file.
			@@rrdtool_bin = "/usr/bin/rrdtool"

			@@rrd_name = ""

			public

			# Constructor.
			def initialize rrd_name
				@@rrd_name = rrd_name
			end

			# Returns the timestamp of the last update of the RRD.
			def get_last_rrd_update
				command = "#{@@rrdtool_bin} last #{get_path_of_rrd}"
				return `#{command}`
			end

			# Build a PNG graph image out of the RRD.
			def update_image from, to, lines, title, width, height, colors, options
				command = @@rrdtool_bin + " graph #{get_path_of_png} --start #{from.to_s} --end #{to.to_s} "

				lines.each do |line|
					command << line + " "
				end				

				command << "-t '" + title + "' "
				command << "-w #{width} -h #{height} "
				
				# Build the colors string.
				colors.each do |a,c|
					command << "-c #{a}#{c} "
				end

				command << options + " "

				return false if !system command

				return true

			end

			# Insert data into the RRD.
			def insert data
				return false if data.blank?

				# Get the full path to the RRD.
				rrd = get_path_of_rrd
				return false if rrd == false

				# Build the command.
				update_command = @@rrdtool_bin + " update " + rrd + " " + data
				# Execute the command.
				return false if !system update_command

				return true
			end
			
			#TODO: Set options via single objects, not one big string.
			# Creates a RRD.
			def create_rrd options
				# Check if we can use the rrdtool binary.
				return false if !check_for_rrdtool
				
				# Get the full path to the RRD.
				rrd = get_path_of_rrd
				return false if rrd == false

				# Check if there is already a RRD with that name.
				return false if check_for_rrd_file rrd

				# Build the command.
				command = @@rrdtool_bin + " create #{rrd} "
				command << options

				# Try to execute the command.
				return false if !system command

				return true
			end

			def get_name_of_graph
				return @@rrd_name
			end

			# Get the full path to a RRD.
			def get_path_of_rrd
				# The location of the rrd.
				rrd_dir = File.dirname(__FILE__) + "/../../../../../db/colored-rrds/"

				# Check if the RRD directory exists.
				return false if !check_for_rrd_dir rrd_dir

				# rrd is now the full path to the RRD.
				rrd = rrd_dir + @@rrd_name + ".rrd"

				return rrd
			end

			# Get the full path to the PNG file of a graph.
			def get_path_of_png
				img_dir = File.dirname(__FILE__) + "/../../../../../public/images/colored-graphs/"
				
				# Check if the graph directory exists.
				return false if !File.directory? img_dir

				png = img_dir + @@rrd_name + ".png"

				return png				
			end

			private
			
			# Find out if the rrdtool binary is installed and executable.
			def check_for_rrdtool
				return false if !File.executable? @@rrdtool_bin
				return true;
			end

			# Checks if the specified directory is a RRD file.
			def check_for_rrd_dir rrd_dir
				return false if !File.directory? rrd_dir
				return true
			end

			# Checks if the specified file is a RRD file.
			def check_for_rrd_file rrd_file
				return false if !File.exists? rrd_file
				#TODO: check with rrd command - rrdtool info - ERROR:
				return true
			end

		end

	end

end
