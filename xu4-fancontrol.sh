#!/bin/bash
get_disk_dev_info() {
	fdisk -l > disks.txt 2>/dev/null
	SATA=($(awk '/^\/dev\/sd/ {printf "%s ", $1}' disks.txt))
	rm disks.txt
}

get_disk_temperature() {
	for i in "${!SATA[@]}"
	do
		# declare and assign variable seperately to avoid masking return value
		DISK_TEMP[$i]=" (IDLE)"
        local t
        t=$(smartctl -a "${SATA[$i]}" -d sat | grep "Temp")
        if (( $? == 0 ))
        then
            local temp=$(echo $t | awk '{print $10}')
            DISK_TEMP[$i]="$temp"
        else
            DISK_TEMP[$i]=""
        fi
	done
}

get_cpu_temperature() {
    for i in {0..4} 
    do
        _t=$(($(</sys/class/thermal/thermal_zone${i}/temp) / 1000))
        CPU_TEMP[$i]="$_t"
    done
}

# Pull disk info from /dev/sd*
get_disk_dev_info
get_disk_temperature
get_cpu_temperature

echo ${DISK_TEMP[@]}
echo ${CPU_TEMP[@]}