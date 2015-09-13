LPD8806 = require('LPD8806')

numLEDs = 32
lpd = LPD8806.new(32, 3, 4)
lpd:show()

function lpd_color(r, g, b)
  for i = 0, numLEDs-1 do
    lpd:setPixelColor(i, r, g, b)
  end
  lpd:show()
end

function lpd_fade()
  local n = 0
  local dir = 0

  tmr.alarm(0, 100, 1, function()
    n = n + dir
    if n > 10 then
      dir = -1
    elseif n < 1 then
      dir = 1
    end
    lpd_color(0, 0, n)
  end)
end

function lpd_cylon()
  local n = 0
  local dir = 0

  tmr.alarm(0, 50, 1, function()
    for i = 0, numLEDs-1 do
      if i == n then
        lpd:setPixelColor(i, 255, 0, 0)
      else
        lpd:setPixelColor(i, 0, 200, 200)
      end
    end
    n = n + dir
    if n >= numLEDs-1 then
      dir = -1
    elseif n <= 0 then
      dir = 1
    end
    lpd:show()
  end)
end

function lpd_stop()
  tmr.stop(0)
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

function theaterChase(c, delay)
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

function theaterChaseRainbow(delay)
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

function rainbowCycle(delay)
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

function lpd_cycle()
	POS = 0
	tmr.alarm(0,50,1,function()
		lpd_color(Wheel(POS))
		
		if POS<384 then
			POS=POS+1
		else
			POS=0
		end
	end)
end

--theaterChaseRainbow(50000)
rainbowCycle(50)