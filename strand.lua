LPD8806 = require('LPD8806')

local strand = {}

numLEDs = 32
lpd = LPD8806.new(32, 3, 4)
lpd:show()

function strand.color(r, g, b)
  for i = 0, numLEDs-1 do
    lpd:setPixelColor(i, r, g, b)
  end
  lpd:show()
end

function Wheel(WheelPos)
	local comp = WheelPos/128
	if comp==0 then
	  r = 127 - WheelPos % 128
	  g = WheelPos % 128
	  b = 0
	elseif comp==1 then
	  g = 127 - WheelPos % 128
	  b = WheelPos % 128
	  r = 0
	elseif comp==2 then
	  b = 127 - WheelPos % 128
	  r = WheelPos % 128
	  g = 0
	end
	return tonumber(r),tonumber(g),tonumber(b)
end

function strand.theaterChase(c, delay)
  for j=0,9 do
    for q=0,2 do
      for i=0,numLEDs-1,3 do
		lpd:setPixelColor(i+q, Wheel(c))
	  end
	  
	  lpd:show()
      tmr.delay(delay)
	  
      for i=0,numLEDs-1,3 do
        lpd:setPixelColor(i+q, Wheel(c))
	  end
	  
	end
  end
end

function strand.theaterChaseRainbow(delay)
	for j=0,383 do -- cycle all 384 colors in the wheel
		for q=0,2 do
			for i=0,numLEDs-1,3 do
				lpd:setPixelColor(i+q, Wheel((i+j)%384))
			end
			
			lpd:show()
			tmr.delay(delay)
		   
			for i=0,numLEDs-1,3 do
				lpd:setPixelColor(i+q, 0,0,0)
			end
		end
	end
end

function strand.rainbowCycle(delay)
	j=0
	tmr.alarm(2,delay,1,function()
		for i=0,numLEDs-1 do
		  lpd:setPixelColor(i, Wheel( ((i * 384 / numLEDs) + j) % 384) )
		end
		
		lpd:show()
		
		if j<383*5 then
			j=j+1
		else
			j=0
		end
	end)
end

function strand.cycle(delay)
	POS = 0
	tmr.alarm(2,delay,1,function()
		strand.color(Wheel(POS))
		
		if POS<384 then
			POS=POS+1
		else
			POS=0
		end
	end)
end

function strand.stop()
  tmr.stop(2)
end

return strand