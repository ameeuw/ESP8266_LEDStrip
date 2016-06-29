-- StripControl.lua module
-- Author: Arne Meeuw
-- github.com/ameeuw
--
--
-- Initialize:
-- StripControl = require('StripControl').new()
--

local StripControl = {}
StripControl.__index = StripControl

function StripControl.new()
	-- TODO: add timer variable to change timer number
	local self = setmetatable({}, StripControl)
	local relayPin = 6
	local buttonPin = 3

	self.strand = require("strand")

	-- Instantiate new MQTT client
	self.MqttClient = mqtt.Client(name, 120, "", "")

	tmr.alarm(5,1000, 1, function()
		print("Connecting MQTT")
		self.MqttClient:connect("app.b0x.it", 3001)
	end)

	-- Add listeners
	self.MqttClient:on("connect", function()
		self.MqttClient:subscribe("strip/set", 0)
		tmr.stop(5)
	end)

	-- Add on("message") function to forward incoming topic changes to existing hooks
	self.MqttClient:on("message", function(client, topic, message)
		print(message)
		if (topic == "strip/set") then

			local cmdTable = pcall(cjson.decode, message)

			if (cmdTable.mode ~= nil) then

				if (cmdTable.mode == "theaterChase") and (cmdTable.color ~= nil) and (cmdTable.delay ~= nil) then
					self.strand.theaterChase(tonumber(color),tonumber(delay))

				else if (cmdTable.mode == "theaterChaseRainbow") and (cmdTable.delay ~= nil) then
						self.strand.theaterChaseRainbow(tonumber(delay))

				else if (cmdTable.mode == "rainbowCycle") and (cmdTable.delay ~= nil) then
						self.strand.rainbowCycle(tonumber(delay))

				else if (cmdTable.mode == "cycle") and (cmdTable.delay ~= nil) then
						self.strand.cycle(tonumber(delay))
					end
				end
			end
			self.MqttClient:publish("strip/status", message, 0, 1)
		end
	end)

	-- Add reconnection on disconnect
	self.MqttClient:on("offline", function(client)
		print("Connection lost - reconnecting.")
		tmr.alarm(5,1000, 1, function()
			print("...")
			self.MqttClient:connect("app.b0x.it", 3001)
		end)
	end)

	return self
end

function StripControl.telnetHook(self, conn, commandTable)
	if commandTable.telnet~=nil then
		if type(tonumber(commandTable.telnet))=="number" then

			local ok, json = pcall(cjson.encode, commandTable)
					if ok and json~="null" then
							--print('Sending JSON:',json)
							conn:send(json)
					else
							--print("failed to encode!")
							conn:send("{'error':'cjson encode fail'}")
			end

			print("Starting telnet remote.")
			self.RestAPI:stopServer()
			dofile("telnet.lc")
		end
	end
end

return StripControl
