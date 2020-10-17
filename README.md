# openwrt-auto-channel-select
Automatic Wi-Fi channel selection script for OpenWRT and supported systems

## Overview

This little script will scan wireless networks around you and pick the best (least congested) frequency channel (1, 6 or 11).
It relies on ```iw [device] scan``` and it makes several scans with delays between them for increased accuracy.

## Usage

0 -> 5ghz radio
1 -> 2.4ghz radio
```bash
$ ./setAutoChannel.sh [interface index]
```

Where interface index is the index number of the wireless interface you are insterested in (eg. if you want to pick a channel for wlan0, pass 0 here)

After the best channel is found, this script will commit a config change using UCI, assuming that your radio interface has the same index (wlan0 -> radio0).

You can execute this script from your crontab to make it run regularly, or to `/etc/rc.local` to launch it on startup.

## Default settings

By default this script makes 3 scans with 5 second delay between them. You can change this at the top of the script.

