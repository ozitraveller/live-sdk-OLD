#! /bin/bash

# script to return the battery time remaining, if not on AC power.
# [b]Requires: acpi package[/b]

# get the battery line if it contains the 'discharge' word
batt=`acpi -b | grep "Discharging"`

# if the line is not empty
if [[ $batt != "" ]]; 
then 

    # cut out the time portion
    batt=`echo $batt | awk '{print $5}' | cut -c 1-5`

    # echo inside tags for your viewing pleasure
    echo ""$batt""
else
    echo "Full"
fi
