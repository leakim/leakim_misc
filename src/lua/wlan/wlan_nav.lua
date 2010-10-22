--
-- usage: tshark -q -X lua_script:wlan_nav.lua -r file.dump 
--

do
   -- assumes infrastructure mode and that STA sends probe requests
   mactime_first=-1
   --prism_mactime = Field.new("prism.mactime.data") -- if using wireshark with atheros based card/madwifi driver
   prism_mactime = Field.new("frame.time_relative")  -- if using airopeek with cisco or atheros based card
   --prism_msglen = Field.new("prism.msglen")
   
   type_subtype = Field.new("wlan.fc.type_subtype")

   sa = Field.new("wlan.sa")
   ra = Field.new("wlan.ra")
   ta = Field.new("wlan.ta")
   duration = Field.new("wlan.duration")

   wlan_rate = Field.new("radiotap.datarate")
   is_rate_present_h = Field.new("radiotap.present.rate")
   radio_header_len = Field.new("radiotap.length")
   frame_len = Field.new("frame.len")

   -- very much simplifyed as it does not calc time correctly and does not take all sifs+BO+... into account
   -- also does not handle retransmissions correctly
   -- it's just to give a very rough estimate
   function calc_frame_time()
      local len = tonumber(tostring(frame_len())) - tonumber(tostring(radio_header_len()))

      -- rate is in multiple of 0.5Mbit => mult len with 2 to compensate
      if wlan_rate() then
         -- T_preample + T_sig + T_ex + sifs + difs
         local time = 16 + 4 + 6 + 28
         time = time + 8*2*(4+len) / tonumber(tostring(wlan_rate()))
         return time
      end

      return 0
   end

   function mactime() 
      local ts = 1000000*tonumber(tostring(prism_mactime()))
      if mactime_first < 0 then
          mactime_first = ts
      end
      return ts-mactime_first
   end

   time_total = 0
   time_last = 0
   local function init_listener()
      local tap = Listener.new("frame", "!(wlan.fc.type_subtype==29) && (wlan.fc.retry == 0)") -- no ack's

      function tap.packet(pinfo,tvb,ip)
         --local ts = mactime()
         ts = pinfo.rel_ts
   
         local time = calc_frame_time()
         time = time + 68 -- 9us*CW=9*15/2
         if time > 0 then
            time_total = time_total + time
            time_last = ts
--            io.write(string.format("%f %d: r:%d len:%d\n",
--               ts, 
--               time, 
--               tonumber(tostring(wlan_rate()))/2, 
--               (tonumber(tostring(frame_len())) - tonumber(tostring(radio_header_len()))) 
--               ))
         end
      end

      function tap.draw()
         io.write(string.format("nav: %f/%f = %f%%\n", time_total/1000000, time_last, 100*(time_total/(time_last*1000000))))
      end
   end

   local function init_listener2()
      local tap = Listener.new("frame", "!(wlan.fc.type_subtype==29) && (wlan.fc.retry == 1)") -- no ack's

      function tap.packet(pinfo,tvb,ip)
         --local ts = mactime()
         ts = pinfo.rel_ts
   
         local time = calc_frame_time()
         time = time + 2*68 -- 9us*CW=9*15/2
         if time > 0 then
            time_total = time_total + time
            time_last = ts
         end
      end
   end

    -- Acknowledgment Listener
   local function init_listener3()
      local tap = Listener.new("frame","(wlan.fc.type_subtype==29)");

      function tap.packet(pinfo,tvb,ip) 
         -- padd with 10us
         -- 32us for 24-54
         -- 36us for 18
         -- 44us for 9
         -- 52us for 6
         time_total = time_total + 10 + 40 -- sifs + ack
      end
   end

   init_listener()
   init_listener2()
   init_listener3()
end
