# DISCLAIMER:
# This software was produced in part by the National Institute of Standards
# and Technology (NIST), an agency of the U.S. government, and by statute is
# not subject to copyright in the United States.  Recipients of this software
# assume all responsibility associated with its operation, modification,
# maintenance, and subsequent redistribution.

# Visible classes are contained inside the USAR module
module USAR
	# Represents an object spawned by the world controller
	class WCObject
		attr_reader :name, :type, :location, :rotation, :size

		def initialize(control, type, name, location, rotation, size)
			@control, @type, @name, @size = control, type, name, size
			@location, @rotation, @waypoints = location, rotation, []
		end

		# Adds the specified waypoint coordinates (vectors); use *array to pass many of them
		def add_waypoint(*coords)
			@waypoints += coords
			wp = coords.map { |x| x.comstr }
			@control.send("CONTROL {Type AddWP} {Name #{@name}} {WP #{wp.join(';')}}")
		end

		# Clears all waypoints from the object
		def clear_waypoints
			@control.send("CONTROL {Type ClearWP} {Name #{@name}}")
			waypoints.clear
		end

		# Removes this object from the simulation
		def kill!(cleanup = true)
			@control.send("CONTROL {Type Kill} {Name #{@name}}")
			@control.objects.delete(@name) if cleanup
		end

		# Turns looping of path on or off
		def loop=(loop)
			setup_waypoints(:Loop => loop ? 'true' : 'false')
		end

		# Moves the object by the specified relative amount
		def move(dloc, drot = [0, 0, 0])
			values = { :Type => 'RelMove', :Name => @name }
			values[:Location], values[:Rotation] = dloc.comstr, drot.comstr
			@control.send("CONTROL #{values.to_usar}")
			update
		end

		# Starts or stops the motion path feature
		def moving=(run)
			setup_waypoints(:Moving => run ? 'true' : 'false')
		end

		# Updates the object's position and rotation in the world
		def set_pose(location, rotation, send = true)
			if send
				values = { :Type => 'AbsMove', :Name => @name }
				values[:Location], values[:Rotation] = location.comstr, rotation.comstr
				@control.send("CONTROL #{values.to_usar}")
				update
			else
				@location, @rotation = location, rotation
			end
		end

		# Sets the object's waypoint travel speed to the specified value
		def speed=(speed)
			setup_waypoints(:Speed => speed.to_f)
		end

		private
		# Helper method to setup waypoint parameters
		def setup_waypoints(opts = { })
			@control.send("CONTROL {Type SetWP} {Name #{@name}} #{opts.to_usar}")
		end

		public
		# Changes the progress of this object on its motion path; e.g. time=0 moves it to start
		def time=(time)
			setup_waypoints(:Time => time.to_f)
		end

		# Returns this object's name and pose
		def to_s
			"#{@name} at (#{@location.comstr}), facing (#{@rotation.comstr})"
		end

		# Update the location and rotation of this object by sending a GetSTA
		def update
			@control.send("CONTROL {Type GetSTA} {Type #{@type}} {Name #{@name}}")
		end
	end

	# Represents the USAR world controller
	class WorldController
		attr_reader :objects

		# Creates a world controller (the start position does not matter!)
		def initialize(conn)
			@ind = 0
			# Connect to USAR
			@objects, @conn, @ind = Hash.new(nil), IridiumConnection.new, 0
			@conn.register(self)
			@conn.connect(conn)
			values = { :ClassName => 'USARBotAPI.WorldController', :Location => '0, 0, 0', \
				:Rotation => '0, 0, 0' }
			begin
				send("INIT #{values.to_usar}")
			rescue IOError => e
				# Clean up connection in case of IO error
				@conn.close
				raise e
			end
		end

		# Closes this world controllers's connection; closed controllers cannot be reused
		# All objects are killed automatically by the simulation
		def close
			@conn.close
		end

		# Creates and returns a new object controlled by this world controller
		def create(opts = { })
			values = { :Type => 'Create', :Name => opts[:Name] || "Object#{@ind += 1}" }
			values[:ClassName], start = opts[:Type] || 'USARPhysObj.WCCrate', opts[:Start]
			if !start.nil?
				loc, rot = start.location, start.rotation
			else
				loc = opts[:Location] || [0, 0, 0]
				rot = opts[:Rotation] || [0, 0, 0]
			end
			scale = opts[:Scale] || [1, 1, 1]
			values[:Location], values[:Rotation] = loc.comstr, rot.comstr
			values[:Physics] = opts[:Physics] ? 'RigidBody' : 'None'
			values[:Material] = opts[:Material] if !opts[:Material].nil?
			values[:Scale] = scale.comstr
			send("CONTROL #{values.to_usar}")
			obj = WCObject.new(self, values[:Type], values[:Name], loc, rot, scale)
			@objects[values[:Name]] = obj
		end

		# Process WC status packets
		def handle_packet(packet)
			if packet.type == 'STA'
				# Status message
				i, name, loc, rot = 0, packet[:Name], packet[:Location], packet[:Rotation]
				begin
					@objects[name].set_pose(loc.to_v, rot.to_v, false) if !name.nil?
					# Bizarre but true: how USARPacket encodes duplicate names
					loc, rot = packet["Location_#{i}"], packet["Rotation_#{i}"]
					name, i = packet["Name_#{i}"], i + 1
				end while !name.nil?
			end
		end

		# Kills the specified object name
		def kill!(name)
			object = @objects[name]
			if !object.nil?
				object.kill!(false)
				@objects.delete(name)
			end
		end

		# Kills all objects spawned by the world controller
		def killall!
			send("CONTROL {Type KillAll}")
			@objects.clear
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

		# Updates the location and rotation of all objects
		def update_all
			send("CONTROL {Type GetSTA}")
		end
	end
end