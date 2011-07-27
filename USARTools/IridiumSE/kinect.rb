# DISCLAIMER:
# This software was produced in part by the National Institute of Standards
# and Technology (NIST), an agency of the U.S. government, and by statute is
# not subject to copyright in the United States.  Recipients of this software
# assume all responsibility associated with its operation, modification,
# maintenance, and subsequent redistribution.

# Yeah yeah yeah, on with the good stuff...

require 'usar'

# Represents a Kinect sensor
module USAR
	class Kinect < Sensor
		attr_reader :range, :bot

		def initialize(bot, name = nil)
			super(bot, 'Kinect', name)
			@bot = bot
			range = []
			480.times do |y|
				row = []
				640.times do |x|
					row << 0
				end
				range << row
			end
			@range = range
		end

		# Manually order the range scanner to scan
		def scan
			values = { :Type => @type, :Opcode => 'SCAN', :Value => 0.0 }
			@bot.send("SET #{values.to_usar}")
		end
		
		# Scan and wait
		def scan!
			@range[479][639] = 0
			scan
			while (@range[479][639] == 0)
				sleep 0.1
			end
		end

		# Store the range into field
		def sensor_data(packet)
			range = packet[:Range]
			start = 8 * packet[:Frame].to_i
			if !range.nil?
				range = range.to_v
				8.times do |y|
					640.times do |x|
						@range[start + y][x] = range[y * 640 + x]
					end
				end
			end
		end

		# Intuitive representation of this object
		def to_s
			out = "#{@type} Sensor"
			out << " (#{@name})" if !@name.nil?
		end
	end
end

distances = [0.3, 0.5, 0.7, 0.9, 1.1, 1.3, 1.5, 1.7, 1.9, 2.1, 2.3, 2.5, 2.7, 2.9, 3.1, 4.1, 5.1, 6.1]

puts 'Connecting to localhost:3000'
begin
	conn = USAR::Connection.new('localhost', 3000)
	distances.each do |dist|
		sleep 0.5
		puts 'Spawning robot at distance %.3f' % dist
		bot = USAR::Robot.new(conn, 'USARBot.KinectBot', :Location => [-dist, 0, 0], :Rotation => [0, 0, 0])
		gnd = USAR::GroundTruthSensor.new(bot)
		kinect = USAR::Kinect.new(bot)
		sleep 0.5
		puts 'Starting Kinect scan'
		kinect.scan!
		color = [255, 0, 255]
		puts 'Writing Kinect to file'
		File.open('kinect%02d.pcd' % (dist * 10).to_i, 'w') do |f|
			f.write("# .PCD v.7 - Point Cloud Data file format\n")
			f.write("VERSION .7\n")
			f.write("FIELDS x y z rgb\n")
			f.write("SIZE 4 4 4 4\n")
			f.write("TYPE F F F F\n")
			f.write("COUNT 1 1 1 1\n")
			f.write("WIDTH 640\n")
			f.write("HEIGHT 480\n")
			f.write("VIEWPOINT 0 0 0 1 0 0 0\n")
			f.write("POINTS %d\n" % (640 * 480))
			f.write("DATA ascii\n")
			480.times do |x|
				640.times do |y|
					icolor = (color[0] << 16) + (color[1] << 8) + color[2]
					f.write("%.1f %.1f %.2f %1.8g\n" % [y, x, kinect.range[x][y]/100.0, \
						java.lang.Float.intBitsToFloat(icolor)])
				end
			end
		end
		bot.close
	end
	puts 'Normal script termination'
rescue IOError => e
	$stderr.puts("Terminating, error message: #{e.message}")
end
