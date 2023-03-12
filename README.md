# EnviroPi Dashboard

An R and [shiny](https://shiny.rstudio.com) based dashboard for data logged from
the Pimoroni [EnviroPi](https://shop.pimoroni.com/products/enviro).

There are 2 components:

* logger.py - prints the current state of all the sensors
* enviropi_app.R - The dashboard application


## logger.py

Add `logger.py` to your crontab using the template provided in `crontab.txt`.
This will write data from all sensors to a daily log file once per minute.

You will need to install and configure Pimoroni's 
[enviroplus](https://github.com/pimoroni/enviroplus-python) Python package.


## enviropi_app.R

This is the shiny dashboard that displays the data to the end user.

You can launch the app from the command line:

```R
R -e 'shiny::runApp("enviropi_app.R", host="0.0.0.0", port=8000)'
```

