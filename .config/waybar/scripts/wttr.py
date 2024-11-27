#!/usr/bin/env python3
import json
from datetime import datetime
from urllib import request, parse

WTTR_URL = "https://wttr.in/?format=j1"

condition_symbols = {
    "day_Overcast": " ",
    "night_Overcast": " ",
    "day_Partly cloudy": " ",
    "night_Partly cloudy": " ",
    "day_Cloudy": " ",
    "night_Cloudy": " ",
    "day_Light rain": " ",
    "night_Light rain": " ",
    "day_Light rain, mist": " ",
    "night_Light rain, mist": " ",
    "day_Fog": " ",
    "night_Fog": " ",
    "day_Mist": " ",
    "night_Mist": " ",
    "day_Sunny": " ",
    "night_Sunny": " ",
    "day_Clear": " ",
    "night_Clear": " ",
    # More to come as needed
}

req = request.Request(WTTR_URL)
with request.urlopen(req) as response:
    current_time = datetime.now()
    data = json.load(response)

    data_sunset = data["weather"][0]["astronomy"][0]["sunset"]
    sunset_time = datetime.strptime(data_sunset, "%I:%M %p")
    day_or_night = "night" if current_time > sunset_time else "day"
    
    temp = data["current_condition"][0]["temp_C"]
    feels_like = data["current_condition"][0]["FeelsLikeC"]
    weather_description = data["current_condition"][0]["weatherDesc"][0]["value"]
    
    condition_symbol = condition_symbols.get(f"{day_or_night}_{weather_description}", weather_description)
    print(f"<b>{condition_symbol}</b> {temp}° ({feels_like}°)")
