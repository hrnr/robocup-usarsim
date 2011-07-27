# DISCLAIMER:
# This software was produced in part by the National Institute of Standards
# and Technology (NIST), an agency of the U.S. government, and by statute is
# not subject to copyright in the United States.  Recipients of this software
# assume all responsibility associated with its operation, modification,
# maintenance, and subsequent redistribution.

module USAR
	class Actuator
		attr_reader :conf, :name, :gripper

		def initialize(bot, name)
			@conf, @joints, @gripper, @name, @bot = nil, [], 0, name, bot
			@bot.register(self)
			@bot.send("GETCONF {Type Actuator} {Name #{@name}}")
		end

		# Get a joint position
		def [](link)
			@joints[link] || 0
		end

		# Set a joint position (do NOT use to_usar and Hash, order not guaranteed!!!)
		def []=(link, value)
			@bot.send("ACT {Name #{@name}} {Link #{link.to_i}} {Value #{value.to_f}}")
		end

		# Iterates through joint indices
		def each_index
			@joints.each_index { |x| yield x }
		end

		# Iterates through joint values
		def each
			@joints.each { |x| yield x }
		end

		# Waits for configuration data to arrive (sent when object is created)
		def getconf
			sleep(0.01) while @conf.nil?
		end

		# Opens or closes the gripper on the arm
		def gripper=(closed)
			values = { :Name => @name, :Gripper => closed ? 1 : 0 }
			@bot.send("ACT #{values.to_usar}")
		end

		# Handles incoming ACTSTA and configuration packets
		def handle_packet(packet)
			# Unlike Java, null pointer == won't raise error
			if packet[:Name] == @name
				if packet.type == 'ASTA'
					# Status message
					link, value = 0, packet[:Value]
					begin
						@joints[link] = value
						# Bizarre but true: how USARPacket encodes duplicate names
						value, link = packet["Value_#{link}"], link + 1
					end while !packet["Link_#{link - 1}"].nil?
				elsif packet.type == 'CONF' && packet[:Type] == 'Actuator'
					@conf = @conf || packet.to_h
				end
			end
		end

		# Runs the specified "sequence" (meaning varies from actuator to actuator)
		def run_sequence(value)
			values = { :Name => @name, :Sequence => value.to_i }
			@bot.send("ACT #{values.to_usar}")
		end

		# Intuitive representation of this object
		def to_s
			@name
		end

		# Allow enumeration of joints using each method
		include Enumerable
	end
end