# cc2531-home-automation-stack

## Status:
This is a work in progress project. Functions like `remove` are not even implemented yet. But if you like the idea of this script and want to contribute feel free to contact me or to open up a merge request.

## TODO:
+ Test: Do testing!
+ Add CC2531 Flashing: Add functionality to help building an flashing CC2531.
+ Add Build Tools: Add functionality to install build tools to build openwrt. https://oldwiki.archive.openwrt.org/doc/howto/buildroot.exigence
+ Split Script: Split this one big script into smaller sub scripts
+ Add Version and Changelog: Add version and changelog info including an option (-v|--version) to check the version.
+ Arch and Target as Option: Add options for arch and target instead of hardcoded in the script.
+ Implement Remove: Implemnet remove functionality.
+ Mosquitto-nossl: Add mosquitto-nossl to known packages.

## Script Help Text:
```
util.sh by mabachel
Utility to help you with a home automation setup on your openwrt router with a cc2531.

Usage: ./util.sh [OPTION] [ARGUMENT] [PACKAGE]

OPTIONS:
    -h, --help            Print this help text.

ARGUMENTS (only one at time):
    help                  Print this help text.
    initialize, init      Initialize OR pull repositories to start building hereafter.
    collect PACKAGE       Copy compiled PACKAGE to stack2install folder.
    install PACKAGE       Install local PACKAGE on router.
    remove PACKAGE        Remove installed PACKAGE on router.

PACKAGES (one or more):
    cc2531                        kmods in order to use cc2531 via /dev/ttyACM
    make                          make which is required by zigbee2mqtt for the 'npm ci' command
    gcc                           gcc which is required by zigbee2mqtt for the 'npm ci' command
    mosquitto-ssl                 Mosquitto (a common MQTT Broker) with SSL support
    mosquitto-nossl               Mosquitto (a common MQTT Broker) without SSL support
    node                          Node.js is used to run javascript code like zigbee2mqtt
    node-npm                      Node.js package manger to install packages like zigbee2mqtt
    node-zigbee2mqtt              zigbee2mqtt precompiled package by openwrt
    python3-light                 small python3 package required by Domoticz Plugins
    python3-multiprocessing       package required by zigbee2mqtt for the 'npm ci' command
    python3                       full python3
    zigbee2mqtt                   zigbee2mqtt directly from koenkk's git repository
    domoticz                      Domoticz is a lightweight home automation software
    domoticz-zigbee2mqtt-plugin   Domoticz Zigbee2MQTT Plugin which requires zigbee2mqtt or node-zigbee2mqtt
    domoticz-plugins-manager      Domoticz Plugin Manager

EXAMPLES:
    # Initialize OR pull repositories to start building hereafter with e.g.:
    # 'make menuconfig' followed by 'make -j$(nproc)'
    ./util.sh init
    # Copy packages for node-zigbee2mqtt mosquitto-ssl domoticz-zigbee2mqtt-plugin
    # including respective dependencies to stack2install folder.
    ./util.sh collect node-zigbee2mqtt mosquitto-ssl domoticz-zigbee2mqtt-plugin
    # Install packages for node-zigbee2mqtt mosquitto-ssl domoticz-zigbee2mqtt-plugin
    # including respective dependencies via opkg from local files.
    ./util.sh install node-zigbee2mqtt mosquitto-ssl domoticz-zigbee2mqtt-plugin

CAUTION:
    This script may break sooner or later due to upstream changes. Please open an issue on github
    if you have experienced any problems with ths script here:
    https://github.com/mabachel/cc2531-home-automation-stack/issues
```

## Contributions
| Project                     | Maintainer         | License | Repository                                                              |
|-----------------------------|--------------------|---------|-------------------------------------------------------------------------|
| openwrt                     | OpenWrt Community  | GPL-2.0 | https://git.openwrt.org/openwrt/openwrt.git                             |
| openwrt-node-packages       | Hirokazu Morikawa  | GPL-2.0 | https://github.com/nxhack/openwrt-node-packages                         |
| zigbee2mqtt                 | Koen Kanters       | GPL-3.0 | https://github.com/Koenkk/zigbee2mqtt                                   |
| domoticz-zigbee2mqtt-plugin | Stanislav Demydiuk | MIT     | https://github.com/stas-demydiuk/domoticz-zigbee2mqtt-plugin            |
| domoticz-plugins-manager    | Stanislav Demydiuk | MIT     | https://github.com/stas-demydiuk/domoticz-plugins-manager               |
| cc-tool                     | Ehsan Azar         | GPL-2.0 | https://github.com/dashesy/cc-tool                                      |
| inital guide                | Stephen Krywenko   |         | https://forum.openwrt.org/t/howto-setup-zigbee2mqtt-on-openwrt/31856/1  |
