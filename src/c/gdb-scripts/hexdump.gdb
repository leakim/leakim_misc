
define showptr
	set $kgm_addr = (unsigned char *)$arg0
	printf "%08x", ($kgm_addr)
end

define hexdump
	set $kgm_addr = (unsigned char *)$arg0
	set $kgm_len = $arg1
	while $kgm_len > 0
                showptr $kgm_addr
		printf ": "
		set $kgm_i = 0
		while $kgm_i < 16
			printf "%02x ", *($kgm_addr+$kgm_i)
			set $kgm_i += 1
		end
		printf " |"
		set $kgm_i = 0
		while $kgm_i < 16
			set $kgm_temp = *($kgm_addr+$kgm_i)
			if $kgm_temp < 32 || $kgm_temp >= 127
				printf "."
			else
				printf "%c", $kgm_temp
			end
			set $kgm_i += 1
		end
		printf "|\n"
		set $kgm_addr += 16
		set $kgm_len -= 16
	end
end
document hexdump
| Show the contents of memory as a hex/ASCII dump
| The following is the syntax:
| (gdb) hexdump <address> <length>
end
