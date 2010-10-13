--
-- tshark -q -X lua_script:wlan_list_ap_sta.lua -r wlan.pcap
--

do
   rssi = Field.new("radiotap.dbm_antsignal")
   wlan_sa = Field.new("wlan.sa")
   wlan_da = Field.new("wlan.da")
   wlan_bssid = Field.new("wlan.bssid")
   beacon_ssid = Field.new("wlan_mgt.tag.interpretation")
   channel = Field.new("radiotap.channel.freq")

   local function get_channel()
      local i = 0
      local c = tonumber(tostring(channel()))
      while i < 13 do
         local ch = 2412 + i*5
         if ch == c then
            return tostring(i+1)
         end
         i = i + 1
      end
      return "("..n..")"
   end

   local ap_t = {}
   local function init_ap_listener()
      local tap = Listener.new("frame", "(wlan.fc.type_subtype == 0x08) && (wlan_mgt.fixed.capabilities.ess == 1)")
   
      function tap.packet(pinfo,tvb,ip) 
         --wlan_mgt.tag.interpretation == "SignalHill"
         local key = tostring(wlan_sa())
         if not ap_t[key] then
            ap_t[key] = {}
            ap_t[key]["count"] = 1
            ap_t[key]["rssi"] = tostring(rssi())
            ap_t[key]["ssid"] = tostring(beacon_ssid())
            ap_t[key]["channel"] = get_channel()
         else
            ap_t[key]["count"] = ap_t[key]["count"] + 1
         end
      end

      function tap.draw()
         io.write(string.format("mac addr of AP's  % 6s  % 4s channel ssid\n" ..
                                "-------------------------------------------\n",
                                "count","rssi", "ssid"))
         for ap_mac,prop in pairs(ap_t) do
            local count = prop["count"]
            io.write(string.format("%s % 6d % 5s  % 6s %s\n",
                     ap_mac,
                     prop["count"],
                     prop["rssi"],
                     prop["channel"],
                     prop["ssid"]))
         end
         io.write(string.format("\n"))
      end
    end

   -- .... ..01 = DS status: Frame from STA to DS via an AP (To DS: 1 From DS: 0) (0x01)
   local ap_sta_t = {}

   local function init_ap_sta_listener()
      local tap = Listener.new("frame", "(wlan.fc.ds == 0x01)")
   
      function tap.packet(pinfo,tvb,ip)
         local sta_mac = tostring(wlan_sa())
         local ap_mac  = tostring(wlan_bssid())
         --print("--miwi--")

         if not ap_sta_t[ap_mac] then
            ap_sta_t[ap_mac] = {}
         end

         if not ap_sta_t[ap_mac][sta_mac] then
            ap_sta_t[ap_mac][sta_mac] = {}
            ap_sta_t[ap_mac][sta_mac]["rssi"] = tostring(rssi())
            ap_sta_t[ap_mac][sta_mac]["count"] = 1
         else
            ap_sta_t[ap_mac][sta_mac]["count"] = ap_sta_t[ap_mac][sta_mac]["count"] + 1
         end

         if ap_sta_t[ap_mac][sta_mac]["rssi"] == 0 then
            ap_sta_t[ap_mac][sta_mac]["rssi"] = tostring(rssi())
         end
      end

      function tap.draw()
         io.write(string.format("AP's and associated STA's (mac addr, packet count, rssi)\n" ..
                                "--------------------------------------------------------\n"))
         for ap_mac,sta_t in pairs(ap_sta_t) do
            local key = ap_mac;
            io.write(string.format("AP: %s channel %s rssi %s ssid \"%s\" beacon_count %s\n", 
                  ap_mac,
                  ap_t[key]["channel"],
                  ap_t[key]["rssi"],
                  ap_t[key]["ssid"],
                  ap_t[key]["count"]
                  ))

            for sta_mac,prop in pairs(sta_t) do
               io.write(string.format("\tsta: %s % 6d % 4s\n",
                      sta_mac,
                      prop["count"],
                      prop["rssi"]))
            end
         end
         io.write(string.format("\n"))
      end
   end


    -- .... ..10 = DS status: Frame from DS to a STA via AP(To DS: 0 From DS: 1) (0x02)
   local function init_ap_sta2_listener()
      local tap = Listener.new("frame", "(wlan.fc.ds == 0x02)")
   
      function tap.packet(pinfo,tvb,ip)
         local sta_mac = tostring(wlan_da())
         local ap_mac  = tostring(wlan_bssid())

         if sta_mac == "ff:ff:ff:ff:ff:ff" then
            return
         end
         if ap_mac == "ff:ff:ff:ff:ff:ff" then
            return
         end

         if not ap_sta_t[ap_mac] then
            ap_sta_t[ap_mac] = {}
         end

         if not ap_sta_t[ap_mac][sta_mac] then
            ap_sta_t[ap_mac][sta_mac] = {}
            ap_sta_t[ap_mac][sta_mac]["rssi"] = 0
            ap_sta_t[ap_mac][sta_mac]["ap_rssi"] = tostring(rssi())
            ap_sta_t[ap_mac][sta_mac]["count"] = 1
         else
            ap_sta_t[ap_mac][sta_mac]["count"] = ap_sta_t[ap_mac][sta_mac]["count"] + 1
         end
      end
    end

   init_ap_listener()
   init_ap_sta_listener()
   init_ap_sta2_listener()

end
