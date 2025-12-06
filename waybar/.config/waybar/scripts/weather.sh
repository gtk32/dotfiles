#!/bin/bash

# Configuration
LAT=52.1601
LON=4.4970
UNITS="celsius"

# Icons for weather codes
declare -A ICON_MAP=(
    [0]="☀"   # Clear sky
    [1]=""   # Mainly clear
    [2]=""   # Partly cloudy
    [3]=""   # Overcast
    [45]="🌫"  # Fog
    [48]="🌫"  # Depositing rime fog
    [51]="🌦"  # Drizzle: Light
    [53]="🌦"  # Drizzle: Moderate
    [55]="🌦"  # Drizzle: Dense
    [56]="🌧"  # Freezing Drizzle: Light
    [57]="🌧"  # Freezing Drizzle: Dense
    [61]="🌧"  # Rain: Slight
    [63]="🌧"  # Rain: Moderate
    [65]="🌧"  # Rain: Heavy
    [66]="❄"  # Freezing Rain: Light
    [67]="❄"  # Freezing Rain: Heavy
    [71]="❄"  # Snow fall: Slight
    [73]="❄"  # Snow fall: Moderate
    [75]="❄"  # Snow fall: Heavy
    [77]="❄"  # Snow grains
    [80]="🌦"  # Rain showers: Slight
    [81]="🌦"  # Rain showers: Moderate
    [82]="🌧"  # Rain showers: Violent
    [85]="❄"  # Snow showers slight
    [86]="❄"  # Snow showers heavy
    [95]="🌩"  # Thunderstorm
    [96]="🌩"  # Thunderstorm with slight hail
    [99]="🌩"  # Thunderstorm with heavy hail
)

# Fetch weather data
response=$(curl -s "https://api.open-meteo.com/v1/forecast?latitude=$LAT&longitude=$LON&current_weather=true&temperature_unit=$UNITS&daily=weathercode,temperature_2m_max,temperature_2m_min&timezone=Europe/Amsterdam")

temp=$(echo "$response" | jq '.current_weather.temperature' | xargs printf "%.1f")
code=$(echo "$response" | jq '.current_weather.weathercode')
current_icon="${ICON_MAP[$current_code]}"
[ -z "$current_icon" ] && current_icon="❓"

# 5-day forecast
forecast=""
for i in $(seq 0 4); do
    day=$(echo "$response" | jq -r ".daily.time[$i]")
    max=$(echo "$response" | jq ".daily.temperature_2m_max[$i]" | xargs printf "%.1f")
    min=$(echo "$response" | jq ".daily.temperature_2m_min[$i]" | xargs printf "%.1f")
    code=$(echo "$response" | jq ".daily.weathercode[$i]")
    icon="${ICON_MAP[$code]}"
    [ -z "$icon" ] && icon="❓"

    # Format date nicely
    if [ $i -eq 0 ]; then
        day_str="Today"
    elif [ $i -eq 1 ]; then
        day_str="Tomorrow"
    else
        day_str=$(date -d "$day" +"%d/%m")
    fi

    forecast+="$day_str: $icon $min°/$max° | "
done
# Remove trailing separator
forecast=${forecast::-3}

# Output for Waybar
echo "$icon $temp°"
echo "{\"Forcast\": \"$forecast\"}"
