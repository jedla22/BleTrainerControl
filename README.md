# BleTrainerControl
## What is BleTrainerControl
This repo is a complete demo project to interact with Tacx trainers over Bluetooth Smart (Neo, Vortex Smart,...).
The idea is to send and receive ANT payloads (FE-C profile) over a BLE tunnel.

## Screens
### Discovery screen
This screen allows you to search for Bluetooth Smart devices around that corresponds to the 2 services:
6E40FEC1-B5A3-F393-E0A9-E50E24DCCA9E
669AA305-0C08-969E-E211-86AD5062675F
You can also search all Bluetooth smart devices around by checking the lower right option "Search all devices"

### Main screen
FE-C pages displayed:
* Page 16: FE capabilities
* Page 17: General settings
* Page 25: Specific trainer
* Page 54: FE capabilities (you need to request this page with the button on top)
* Page 55: User configuration (you need to request this page with the button on top)
* Page 71: Command status
* Page 80: Manufacturer's identification
* Page 81: Product information

4 buttons to set one of the mode with its options:
* Basic resistance, opening a slider from 0 to 100% 
* Target power, opening a slider from 0 Watts to 1000 Watts
* Wind resistance, opening 3 sliders to set the coefficient of wind resistance, the wind speed and the drafting factor
* Track resistance, or simulation mode, to set the grade and coefficient of rolling resistance

1 button to open calibration

### Calibration screen
After initiating the process with the "SPIN-DOWN" button, pedal up to the Trainer expected speed (32km/h on a Vortex as of Oct 2015). The Page 2 (Calibration in progress) will show you what is going on.
Then stop pedalling until the wheel comes to a halt and expect the Page 1 Calibration Success information


## About
Written by Kinomap for Tacx under GNU GPL 2.0 licence.
To learn more about the FE-C ANT+ profile: 
https://www.thisisant.com/developer/resources/downloads
