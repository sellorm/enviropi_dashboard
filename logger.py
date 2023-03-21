#!/usr/bin/env python3
from  datetime import datetime
timestamp = datetime.utcnow().isoformat()

import sensor

def temp_calibrated(sensor_temp, adjustment):
    # The first read is discarded as it's unreliable
    with open("/sys/class/thermal/thermal_zone0/temp", "r") as f:
        temp = f.read()
    with open("/sys/class/thermal/thermal_zone0/temp", "r") as f:
        temp = f.read()
        cpu_temp = int(temp) / 1000.0
    # output_temp = sensor_temp - ((cpu_temp - sensor_temp) / adjustment)
    output_temp = sensor_temp - (cpu_temp / 35)
    return float(output_temp)

data = sensor.read_all()

message = "{},{:.2f},{:.2f},{:.2f},{:.2f},{:.2f},{:.2f},{:.2f},{:.2f}".format(
        timestamp,
        data["proximity"],
        temp_calibrated(data["temperature"], 2.25),
        # data["temperature"],
        data["pressure"],
        data["humidity"],
        data["light"],
        data["oxidised"],
        data["reducing"],
        data["nh3"],
        )

print(message)
