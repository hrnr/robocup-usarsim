# DISCLAIMER:
# This software was produced in part by the National Institute of Standards
# and Technology (NIST), an agency of the U.S. government, and by statute is
# not subject to copyright in the United States.  Recipients of this software
# assume all responsibility associated with its operation, modification,
# maintenance, and subsequent redistribution.

# Visible classes are contained inside the USAR module
module USAR
	# Represents a sensor on the robot. Meant for subclassing to obtain sensor specific data.
	class Sensor
		attr_reader :name, :type, :conf

		# Creates a new sensor on the specified robot with the given name
		def initialize(bot, type, name = nil)
			@conf, @name, @type = nil, name, type
			bot.register(self)
			values = { :Type => type }
			values[:Name] = name if not name.nil?
			bot.send("GETCONF #{values.to_usar}")
		end

		# Waits for configuration data to arrive (sent when object is created)
		def get_conf
			sleep(0.01) while @conf.nil?
		end

		# Packet handler for this sensor
		def handle_packet(packet)
			if packet[:Type] == @type && (@name.nil? || packet[:Name] == @name)
				sensor_data(packet) if packet.type == 'SEN'
				@conf = @conf || packet.to_h if packet.type == 'CONF'
			end
		end

		# Unintelligent data handler dumps data to the screen
		def sensor_data(packet)
			puts packet
		end

		# Intuitive representation of this object
		def to_s
			out = "#{@type} Sensor"
			out << " (#{@name})" if !@name.nil?
			out << " #{@conf}" if !@conf.nil?
		end
	end

	# Retrieves data from location sensors (the INS and GroundTruth types)
	class LocationSensor < Sensor
		attr_reader :position, :direction

		def initialize(bot, type, name = nil)
			super
			@position = @direction = [0, 0, 0]
		end

		# Store the location and orientation into fields
		def sensor_data(packet)
			pos, rot = packet[:Location], packet[:Orientation]
			if !pos.nil? && !rot.nil?
				@position = pos.to_v
				@direction = rot.to_v
			end
		end

		# Intuitive representation of this object
		def to_s
			"#{@type} Sensor, At (#{@position.comstr}), Facing (#{@direction.comstr})"
		end
	end

	# Represents sensors that can be reset
	class ResettableSensor < Sensor
		def initialize(bot, type, name = nil)
			super
		end

		# Resets the sensor
		def reset
			values = { :Type => @type, :Name => @name, :Opcode => 'RESET', :Value => 0.0 }
			@bot.send("SET #{values.to_usar}")
		end
	end

	# Represents an acceleration or proper acceleration sensor
	class AccelerationSensor < Sensor
		attr_reader :acceleration

		def initialize(bot, type = 'Acceleration', name = nil)
			super
			@acceleration = [0, 0, 0]
		end

		# Store the acceleration or proper acceleration into field
		def sensor_data(packet)
			accel = packet[:Acceleration] || packet[:ProperAcceleration]
			@acceleration = accel.to_v if !accel.nil?
		end

		# Intuitive representation of this object
		def to_s
			out = "#{@type} Sensor"
			out << " (#{@name})" if !@name.nil?
			out << ", Acceleration (#{@acceleration.comstr})"
		end
	end

	# Represents a rotating sonar sensor that scans an area
	class CloudScanner < Sensor
		attr_reader :range

		def initialize(bot, name = nil)
			super(bot, 'RotatingPointCloudScanner', name)
			@range = []
		end

		# Store the range into field
		def sensor_data(packet)
			range = packet['']
			@range = range.split(';').map! { |x| x.to_f } if !range.nil?
		end

		# Intuitive representation of this object
		def to_s
			out = "#{@type} Sensor"
			out << " (#{@name})" if !@name.nil?
			out << ", Range #{@range.comstr}"
		end
	end

	# Represents a wheel encoder (since most robots have more than one, this must be named!)
	class EncoderSensor < ResettableSensor
		attr_reader :counts

		def initialize(bot, name)
			super(bot, 'Encoder', name)
			@counts = 0
		end

		# Override packet handler since encoders do not report their actual names
		def handle_packet(packet)
			if packet[:Type] == @type && name.include?(packet[:Name])
				@counts = packet[:Tick].to_i if !packet[:Tick].nil? && packet.type == 'SEN'
				@conf = @conf || packet.to_h if packet.type == 'CONF'
			end
		end

		# Intuitive representation of this object
		def to_s
			"#{@type} Sensor (#{@name}), Count #{@counts}"
		end
	end

	# Represents the GPS sensor (lat and long will be arrays: int, float, string where
	# [0] is degree, [1] is minute (+second), [2] is N/S/W/E
	class GPSSensor < Sensor
		attr_reader :lat, :long, :satellites, :fix

		def initialize(bot, name = nil)
			super(bot, 'GPSSensor', name = nil)
			@fix, @satellites, @lat, @long = false, 0, [0, 0.0, 'E'], [0, 0.0, 'W']
		end

		# Store the GPS status into field
		def sensor_data(packet)
			@fix = packet[:Fix].to_i == 1 if !packet[:Fix].nil?
			@satellites = packet[:Satellites].to_i if !packet[:Satellites].nil?
			lat, long = packet[:Latitude], packet[:Longitude]
			if !lat.nil?
				lat = lat.split(',')
				@lat[0] = lat[0].to_i
				@lat[1] = lat[1].to_f
				@lat[2] = lat[2]
			end
			if !long.nil?
				long = long.split(',')
				@long[0] = long[0].to_i
				@long[1] = long[1].to_f
				@long[2] = long[2]
			end
		end

		# Intuitive representation of this object
		def to_s
			out = "#{@type} Sensor"
			out << " (#{@name})" if !@name.nil?
			if @fix
				out << ", Fix (#{@satellites}),"
				out << "Latitude #{@lat.join(' ')}, Longitude #{@long.join(' ')}"
			else
				out << ", Loss (#{@satellites})"
			end
		end
	end

	# There should be only one ground-truth sensor per robot, so here is a shortcut
	class GroundTruthSensor < LocationSensor
		def initialize(bot, name = nil)
			super(bot, 'GroundTruth', name)
		end
	end

	# Represents an odometer (there should be only one)
	class OdometrySensor < ResettableSensor
		attr_reader :x, :y, :theta

		def initialize(bot, name = nil)
			super(bot, 'Odometry', name = nil)
			@x = @y = @theta = 0.0
		end

		# Store the odometer status into field
		def sensor_data(packet)
			pose = packet[:Pose]
			if !pose.nil?
				pose = pose.to_v
				@x, @y, @theta = pose[0], pose[1], pose[2]
			end
		end

		# Intuitive representation of this object
		def to_s
			out = "#{@type} Sensor"
			out << " (#{@name})" if !@name.nil?
			out << ", Pose #{@x}, #{@y}, #{@theta}"
		end
	end

	# Represents a range scanner (most such sensors report as RangeScanner)
	class RangeScanner < Sensor
		attr_reader :range, :resolution, :fov

		def initialize(bot, type = 'RangeScanner', name = nil)
			super
			@range, @resolution, @fov = [], 0.1, 0.0
		end

		# Returns the scanned distance in the specified direction (where 0 is straight ahead),
		# or nil if it is outside the field of view
		def range_at(heading)
			index = ((@heading + @fov) / @resolution + 0.5).to_i
			return nil if index < 0 || index >= @range.length
			@range[index]
		end

		# Manually order the range scanner to scan
		def scan
			values = { :Type => @type, :Name => @name, :Opcode => 'SCAN', :Value => 0.0 }
			@bot.send("SET #{values.to_usar}")
		end

		# Store the range into field
		def sensor_data(packet)
			range = packet[:Range]
			@range = range.to_v if !range.nil?
			@resolution = packet[:Resolution].to_f if !packet[:Resolution].nil?
			@fov = packet[:FOV].to_f if !packet[:FOV].nil?
		end

		# Intuitive representation of this object
		def to_s
			out = "#{@type} Sensor"
			out << " (#{@name})" if !@name.nil?
			out << ", Range #{@range.comstr}"
		end
	end

	# Represents a range sensor (since RangeSensor is abstract, must specify type)
	class RangeSensor < Sensor
		attr_reader :range

		def initialize(bot, type, name = nil)
			super
			@range = 0
		end

		# Store the range into field
		def sensor_data(packet)
			range = packet[:Range]
			@range = range.to_f if !range.nil?
		end

		# Intuitive representation of this object
		def to_s
			out = "#{@type} Sensor"
			out << " (#{@name})" if !@name.nil?
			out << ", Range #{@range}"
		end
	end

	# Represents a tachometer sensor (there should be only one)
	class TachometerSensor < ResettableSensor
		attr_reader :vel, :pos

		def initialize(bot, name = nil)
			super(bot, 'Tachometer', name)
			@vel = @pos = []
		end

		# Store the spin speed and position into field
		def sensor_data(packet)
			pos, vel = packet[:Pos], packet[:Vel]
			@pos = pos.to_v if !pos.nil?
			@vel = vel.to_v if !vel.nil?
		end

		# Intuitive representation of this object
		def to_s
			out = "#{@type} Sensor"
			out << " (#{@name})" if !@name.nil?
			out << ", Position (#{@pos.comstr}), Velocity (#{@vel.comstr})"
		end
	end

	# Represents a touch or touch array sensor
	class TouchSensor < Sensor
		attr_reader :touch

		def initialize(bot, type = 'Touch', name = nil)
			super
			@touch = false
		end

		# Store the touch sensor status into field
		def sensor_data(packet)
			touch = packet[:Touch]
			@touch = touch ? true : false if !touch.nil?
		end

		# Intuitive representation of this object
		def to_s
			out = "#{@type} Sensor"
			out << " (#{@name})" if !@name.nil?
			out << " [Pressed]" if @touch
		end
	end
end