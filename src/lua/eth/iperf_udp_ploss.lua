-- tshark -q -X lua_script:wlan_cw.lua -r wlan.pcap

do
    -- additional filter (not recommended, use pre-processing or capture filter if possible)
    -- filter only data frames from DUT
    -- exclude Null function frames
    --filter = '(wlan.fc.type_subtype == 0x08) && (wlan.sa == 00:0b:c0:02:38:71)'
    --filter = '(wlan.fc.type_subtype == 0x08) && (wlan.sa == 0a:0b:c0:02:38:71)'
    --filter = '(wlan.fc.type_subtype == 0x08) && (wlan.sa == 0e:0b:c0:02:38:71)'
    udp_data = Field.new("data.data");

    --sa = Field.new("wlan.sa");
    -- radiotap specific
    --rt_rate = Field.new("radiotap.datarate")
    --rt_db_antsignal = Field.new("radiotap.db_antsignal")
    --rt_dbm_antsignal = Field.new("radiotap.dbm_antsignal")
--    rssi = Field.new("radiotap.dbm_antsignal")
    

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

    local prev_seq = 0
    local prev_ts = 0
    
    local function init_rssi()
        local tap = Listener.new("frame","udp && frame.len > 1400" )


        function tap.packet(pinfo,tvb,ip)
           local d_o = 42
           local seq = tvb(d_o,4):uint()

           if not( prev_seq == 0) then

              --local seq = tvb(d_o,4):le_uint()
              local diff = seq - prev_seq

              if not( diff == 4 ) then
                 io.write(string.format("%u: %f %x->%x diff %u t: %f ms\n", pinfo.number, pinfo.rel_ts, prev_seq, seq, diff, 1000*(pinfo.rel_ts - prev_ts) ))
              end
           end 

           prev_seq = seq
           prev_ts = pinfo.rel_ts
        end

        function tap.draw()
           io.write(string.format("done: %x\n", 0))
        end
    end

    init_rssi()
end
