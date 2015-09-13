strand = require("strand")

function startConfig()
     print('Config -> start webserver')
     print(node.heap())
     file.remove("init.lua")
     file.open("init.lua", "a+")
     file.writeline('dofile("config.lc")')
     file.close()
     tmr.delay(100000)
     node.restart()
end

function parseInput(sck, input)
    if input~=nil then
	print(input)
    cmd, key = input:match("([^,]+)_([^,]+):")
    end
    if cmd~=nil and key~=nil then
        if cmd=="set" then
		
            if key=="TCH" then
                color,delay=input:match(":(%d+),(%d+)")
                if color~=nil and delay~=nil then
					strand.theaterChase(tonumber(color),tonumber(delay))
                    print("Theater Chase")
                end
            end
            
            if key=="TCR" then
                delay=input:match(":(%d+)")
                if delay~=nil then
					strand.theaterChaseRainbow(tonumber(delay))
                    print("Theater Chase Rainbow")
                end
            end
            
            if key=="RCL" then
                state,delay=input:match(":(%d+),(%d+)")
                if state~=nil and delay~=nil then
					if state~=0 then
						strand.rainbowCycle(tonumber(delay))
						print("Rainbow Cycle")
					else
						strand.stop()
					end
                end
            end
            
            if key=="CYC" then
                state, delay=input:match(":(%d+),(%d+)")
                if delay~=nil and state~=0 then
					if state~=0 then
						strand.rainbowCycle(tonumber(delay))
						print("Rainbow Cycle")
					else
						strand.stop()
					end
                end
            end
            
        end
        
        if cmd=="get" then
            if key=="rgb" then
                -- Do stuff to reply to "get" command
            end
            if key=="btn" then
                -- Do stuff to reply to "get" command
            end
        end
    end
end

function runClient()
     node.output(function(str) if str=="DNS Fail!\n" then runClient() blink(255,0,0, 2, 250) end end, 1)
     sk=net.createConnection(net.TCP, 0)
     print("Resolving '"..host.."'")
     sk:dns(host, function(conn, ip) 
								if ip~=nil then
									print("Connecting to "..ip)
									sk:connect(port, ip)
								end
							end)                       
     sk:on("receive", parseInput)
     sk:on("disconnection", runClient)
     sk:on("connection", function(sck) print("Connected.") blink(0,255,0,3, 250) end)
end

function blink(r,g,b, times, delay)	
	local lighton=0
	local count=0
	tmr.alarm(0,delay,1,
		function()
			if lighton==0 then 
				lighton=1 
				strand.color(r,g,b)
			else 
				lighton=0
				strand.color(0,0,0)
			end
			if count==(times*2-1) then 
				tmr.stop(0) 
			else		
				count=count+1
			end
		end)
end

function checkLongPress()
    gpio.mode(pin_reset,gpio.OUTPUT)
	gpio.write(pin_reset,gpio.HIGH)
	tmr.alarm(1,500,0,function()
		if gpio.read(pin_reset)~=gpio.HIGH then
			startConfig()
		else
			gpio.mode(pin_reset,gpio.INT,gpio.PULLUP)
			gpio.trig(pin_reset,"low",checkLongPress)
		end
	end)
end

if file.open('settings.lua', 'r') then 
     dofile('settings.lua')
	 
	 wifi.setmode(wifi.STATION)
	 wifi.sta.config(network, password)
	 wifi.sta.autoconnect(1)
	 tmr.delay(100000)
	 
     runClient()
else
     startConfig()
end
