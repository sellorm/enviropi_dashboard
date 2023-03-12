#!/usr/bin/env python3
from  datetime import datetime
timestamp = datetime.utcnow().isoformat()

import sensor

data = sensor.read_all()

message = "{},{:.2f},{:.2f},{:.2f},{:.2f},{:.2f},{:.2f},{:.2f},{:.2f}".format(
        timestamp,
        data["proximity"],
        data["temperature"],
        data["pressure"],
        data["humidity"],
        data["light"],
        data["oxidised"],
        data["reducing"],
        data["nh3"],
        )

print(message)
