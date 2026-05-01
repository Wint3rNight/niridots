import json
import requests
import sys

def get_weather():
    try:
        # Use wttr.in with JSON format
        # j1 is for detailed JSON, but we keep it simple
        res = requests.get("https://wttr.in/?format=j1")
        res.raise_for_status()
        data = res.json()
        
        current = data['current_condition'][0]
        temp = current['temp_C']
        desc = current['weatherDesc'][0]['value']
        
        # Simple icon mapping
        icons = {
            "Cloudy": "󰖐",
            "Partly cloudy": "󰖕",
            "Sunny": "󰖙",
            "Clear": "󰖙",
            "Rain": "󰖗",
            "Snow": "󰼶",
            "Mist": "󰖑",
            "Fog": "󰖑",
            "Haze": "󰖑",
            "Thunder": "󰖓",
        }
        
        icon = icons.get(desc, "󰖐")
        
        output = {
            "text": f"{icon} {temp}°C",
            "tooltip": f"{desc}\nFeels like: {current['FeelsLikeC']}°C\nHumidity: {current['humidity']}%"
        }
        return json.dumps(output)
    except Exception as e:
        return json.dumps({"text": f"󰖙 Err", "tooltip": str(e)})

if __name__ == "__main__":
    print(get_weather())
