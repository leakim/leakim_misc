-- tshark -q -X lua_script:wlan_rssi.lua -r wlan.pcap

do
    -- additional filter (not recommended, use pre-processing or capture filter if possible)
    -- filter only data frames from DUT
    -- exclude Null function frames
    --filter = '(wlan.fc.type_subtype == 0x08) && (wlan.sa == 00:0b:c0:02:38:71)'
    filter = '(wlan.fc.type_subtype == 0x08) && (wlan.sa == 0a:0b:c0:02:38:71)'
    --filter = '(wlan.fc.type_subtype == 0x08) && (wlan.sa == 0e:0b:c0:02:38:71)'

    --sa = Field.new("wlan.sa");
    -- radiotap specific
    --rt_rate = Field.new("radiotap.datarate")
    --rt_db_antsignal = Field.new("radiotap.db_antsignal")
    --rt_dbm_antsignal = Field.new("radiotap.dbm_antsignal")
    rssi = Field.new("radiotap.dbm_antsignal")

    -- prism
    --prism_rssi = Field.new("prism.rssi.data")
    --prism_signal = Field.new("prism.signal.data")
    --prism_noise = Field.new("prism.noise.data")
    --prism_sq = Field.new("prism.sq.data")
    --prism_rate = Field.new("prism.rate.data")

    local stats_max = -100
    local stats_min = 100
    local stats_sum = 0
    local stats_count = 0
    
    local function init_rssi()
        local tap = Listener.new("frame","" .. filter)

        function tap.packet(pinfo,tvb,ip) 
            local s = tonumber(tostring(rssi()))
            --local r = tonumber(ostring(rate()))/2

            if s > stats_max then
               stats_max = s
            end
            if s < stats_min then
               stats_min = s
            end
            stats_sum = stats_sum + s
            stats_count = stats_count + 1

           io.write(string.format("rssi: %d\n", s))
        end

        function tap.draw()
           io.write(string.format("filter was: %s\n", filter))
           io.write(string.format("min: %d\n", stats_min))
           io.write(string.format("max: %d\n", stats_max))
           io.write(string.format("avg: %d\n", stats_sum/stats_count))
        end
    end

    init_rssi()
end
