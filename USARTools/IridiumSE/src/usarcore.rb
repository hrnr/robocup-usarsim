# DISCLAIMER:
# This software was produced in part by the National Institute of Standards
# and Technology (NIST), an agency of the U.S. government, and by statute is
# not subject to copyright in the United States.  Recipients of this software
# assume all responsibility associated with its operation, modification,
# maintenance, and subsequent redistribution.

# Visible classes are contained inside the USAR module
module USAR
	# A simple placeholder class storing the name and port of a server
	class Connection
		attr_reader(:host, :port)

		# Creates a placeholder for connections to the specified location
		# Creates no real connections
		def initialize(host = 'localhost', port = 3000)
			@host, @port = host, port
		end

		# Intuitive representation of this object
		def to_s
			"#{host}:#{port}"
		end
	end

	# Creates a simple connection to retrieve information from the game (auto closed)
	class Info
		attr_reader(:level, :poses)

		# Create a connection (not optimal but it works)
		def initialize(conn)
			@level = @poses = nil
			@conn = IridiumConnection.new
			@conn.register(self)
			@conn.connect(conn)
		end

		# Waits until the information has been gathered and the info object closed
		def gather
			@conn.sit
			self
		end

		# Handle NFO packets
		def handle_packet(packet)
			if packet.type == 'NFO'
				level = packet[:Level]
				if !level.nil?
					@level = level
					@conn.send('GETSTARTPOSES')
				elsif !packet[:StartPoses].nil?
					@poses = []
					packet.each_pair do |key, value|
						# The key is actually part of the value
						value = (key + ' ' + value).split(' ')
						value.each_slice(3) do |name, loc, rot|
							poses << Pose.new(name, loc.to_v, rot.to_v)
						end if key != 'StartPoses'
					end
				end
			end
			if !@poses.nil? && !@level.nil?
				@conn.unregister(self)
				@conn.close
			end
		end
	end

	# Represents a packet recieved by the interface
	class Packet
		# Create a USAR packet from a Java message
		def initialize(packet)
			@packet = packet
		end

		# Access a parameter from the packet
		def [](key)
			@packet.get_param(key.to_s)
		end

		# Packets cannot be modified
		def []=(key, value)
			raise ArgumentError, 'Packets are immutable'
		end

		# Iterate through all keys of this packet
		def each
			iter = @packet.params.key_set.iterator
			while iter.has_next
				yield iter.next.to_s
			end
		end

		# Iterate through all key/value pairs of this packet
		def each_pair
			iter = @packet.params.entry_set.iterator
			while iter.has_next
				entry = iter.next
				yield entry.key.to_s, entry.value
			end
		end

		# Retrieves the packet's message
		def message
			@packet.message
		end

		# Retrieves the packet's command type
		def type
			@packet.type
		end

		# Convert packet to a frozen Hash object
		def to_h
			hash = Hash.new(nil)
			each_pair { |key, value| hash[key] = value }
			hash.freeze
		end

		# Return message when converted to string
		def to_s
			message
		end

		include Enumerable
	end

	# Parents all classes which can delegate packets to contained items via registration
	class PacketDelegator
		# Initialize the packet listener array
		def initialize
			@registered = []
		end

		# Passes the packet event to all listeners
		def handle_packet(packet)
			@registered.each { |listener| listener.handle_packet(packet) }
		end

		# Registers the object to accept events
		def register(object)
			raise TypeError, 'handle_packet not defined' if !object.respond_to?(:handle_packet)
			@registered << object
		end

		# Unregisters the specified object from events
		def unregister(object)
			@registered.delete(object)
		end
	end

	# Simple representation of a USAR PlayerStart object
	class Pose
		attr_reader :location, :rotation, :name

		def initialize(name, location, rotation)
			@name, @location, @rotation = name.to_s, location, rotation
		end

		# Return player start name
		def to_s
			@name
		end
	end

	# Represents a robot which can be instantiated into the world
	class Robot < PacketDelegator
		attr_reader :name, :time

		# Create a robot of the specified class at the given location (start position or
		# location+rotation)
		def initialize(conn, class_name = 'USARBot.P3AT', opts = { })
			super()
			start, loc, rot = opts[:Start], opts[:Location], opts[:Rotation]
			values = { :ClassName => class_name }
			if !start.nil?
				values[:Start] = start
			else
				loc = rot = [0, 0, 0] if loc.nil? || rot.nil?
				values[:Location], values[:Rotation] = loc.comstr, rot.comstr
			end
			@battery, @conn, @time = nil, IridiumConnection.new, 0
			# Connect to USAR
			@conn.register(self)
			@conn.connect(conn)
			begin
				send("INIT #{values.to_usar}")
			rescue IOError => e
				# Clean up connection in case of IO error
				@conn.close
				raise e
			end
			@name = class_name
		end

		# Checks to see if the robot battery is still alive
		def alive?
			@battery.nil? || @battery > 0
		end

		# Determines the remaining robot battery life in seconds if a battery is installed
		def battery_life
			return nil if @battery.nil?
			@battery
		end

		# Closes this robot's connection; closed robots cannot be reused
		def close
			@conn.close
		end

		# Drives the robot using the specified arguments and values
		def drive(opts = { })
			@conn.send("DRIVE #{opts.to_usar}")
		end

		# Process robot status packets
		alias :super_handle_packet :handle_packet
		def handle_packet(packet)
			if packet.type == 'STA'
				# Intercept and parse battery
				battery = packet[:Battery]
				if !battery.nil?
					battery = battery.to_i
					@battery = battery if battery < 99999
				end
			end
			@time = packet[:Time] if !packet[:Time].nil?
			super_handle_packet(packet)
		end

		# Enters loop until the connection is closed or script is stopped manually
		def listen_wait
			if block_given?
				@conn.sit { yield }
			else
				@conn.sit
			end
		end

		# Sends the specified line to the server
		def send(message)
			@conn.send(message)
		end

		# Return robot class name
		def to_s
			@name
		end
	end
end

# Low-level connection directly to the Java adapter for USARSim connections
class IridiumConnection < USAR::PacketDelegator
	def initialize
		super
		@conn = $__irid__.new_iridium_connector
		@conn.add_iridium_listener(self)
	end

	# Closes the connection to USARSim
	def close
		@conn.disconnect
	end

	# Connects to to the specified host and port
	def connect(conn)
		@host = conn.to_s
		begin
			@conn.connect(@host)
		rescue IOException
			raise IOError, "Cannot connect to #{@host}"
		end
	end

	# Checks to see whether the program is still connected to USARSim
	def connected?
		@conn.connected?
	end

	# Retrieves the specified config value from the iridium.properties file
	def get_config(key)
		@conn.config.get_property(key, '')
	end

	private
	# Processes the given event (from the java interface)
	def processEvent(eventName)
	end

	# Processes the given packet (from the java interface)
	def processPacket(packet)
		begin
			handle_packet(USAR::Packet.new(packet))
		rescue Exception => e
			# Must keep these out of the Iridium handler
			$stderr.puts("While dispatching events: #{e.message}")
			e.backtrace.each { |line| $stderr.puts("  at #{line}") }
		end
	end

	public
	# Sends the specified message
	def send(message)
		begin
			@conn.send_message(message)
		rescue IOException, NativeException
			raise IOError, 'Failed to send message to USAR server'
		end
	end

	# Waits to end the script until the connection is closed
	def sit
		while connected?
			if block_given?
				yield
			else
				sleep(0.1)
			end
		end
	end

	# Intuitive representation of this object
	def to_s
		"Iridium Connection to #{host}"
	end

	# Implement IridiumListener
	include org.nist.usarui.IridiumListener
end

class Array
	# Adds this array piecewise to another (ugly looking but fun!)
	def addto(other)
		zip(other).map! { |sum| sum.inject(0) { |total, x| x + total } }
	end

	# Adds this array piecewise to another in-place
	def addto!(other)
		replace(addto(other))
	end

	# Utility function to create , separated string from 3-array
	def comstr
		join(', ')
	end
end

class String
	# Utility function to create vector (3-array) from , separated string
	def to_v
		value = split(',')
		value.map! { |item| item.strip.to_f }
	end
end

class Hash
	# Converts hash of symbols => value to USAR string
	def to_usar
		val = ''
		each_pair do |key, value|
			val << " {#{key} #{value}}"
		end
		val.strip!
	end
end
