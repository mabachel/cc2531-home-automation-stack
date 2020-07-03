# run this script with bash or ash
# e.g. ./util.sh collect node-zigbee2mqtt mosquitto-ssl domoticz-zigbee2mqtt-plugin
#
# Specify your device specifics here:
TARGET="ipq806x"    # CONFIG_TARGET_BOARD
ARCH="arm_cortex-a15_neon-vfpv4"    # CONFIG_TARGET_ARCH_PACKAGES


### Define Functions
## print the script help text
function printHelp {
    echo "util.sh by mabachel"
    echo "Utility to help you with a home automation setup on your openwrt router with a cc2531."
    echo
    echo "Usage: ./util.sh [OPTION] [ARGUMENT] [PACKAGE]"
    echo
    echo "OPTIONS:"
    echo "    -h, --help            Print this help text."
    echo
    echo "ARGUMENTS (only one at time):"
    echo "    help                  Print this help text."
    echo "    initialize, init      Initialize OR pull repositories to start building hereafter."
    echo "    collect PACKAGE       Copy compiled PACKAGE to stack2install folder."
    echo "    install PACKAGE       Install local PACKAGE on router."
    echo "    remove PACKAGE        Remove installed PACKAGE on router."
    echo
    echo "PACKAGES (one or more):"
    echo "    cc2531                        kmods in order to use cc2531 via /dev/ttyACM"
    echo "    make                          make which is required by zigbee2mqtt for the 'npm ci' command"
    echo "    gcc                           gcc which is required by zigbee2mqtt for the 'npm ci' command"
    echo "    mosquitto-ssl                 Mosquitto (a common MQTT Broker) with SSL support"
    echo "    mosquitto-nossl               Mosquitto (a common MQTT Broker) without SSL support"
    echo "    node                          Node.js is used to run javascript code like zigbee2mqtt"
    echo "    node-npm                      Node.js package manger to install packages like zigbee2mqtt"
    echo "    node-zigbee2mqtt              zigbee2mqtt precompiled package by openwrt"
    echo "    python3-light                 small python3 package required by Domoticz Plugins"
    echo "    python3-multiprocessing       package required by zigbee2mqtt for the 'npm ci' command"
    echo "    python3                       full python3"
    echo "    python3-pip                   python3 preferred installer program"
    echo "    zigbee2mqtt                   zigbee2mqtt directly from koenkk's git repository"
    echo "    domoticz                      Domoticz is a lightweight home automation software"
    echo "    domoticz-zigbee2mqtt-plugin   Domoticz Zigbee2MQTT Plugin which requires zigbee2mqtt or node-zigbee2mqtt"
    echo "    domoticz-plugins-manager      Domoticz Plugin Manager"
    echo
    echo "EXAMPLES:"
    echo "    # Initialize OR pull repositories to start building hereafter with e.g.:"
    echo "    # 'make menuconfig' followed by 'make -j\$(nproc)'"
    echo "    ./util.sh init"
    echo "    # Copy packages for node-zigbee2mqtt mosquitto-ssl domoticz-zigbee2mqtt-plugin"
    echo "    # including respective dependencies to stack2install folder."
    echo "    ./util.sh collect node-zigbee2mqtt mosquitto-ssl domoticz-zigbee2mqtt-plugin"
    echo "    # Install packages for node-zigbee2mqtt mosquitto-ssl domoticz-zigbee2mqtt-plugin"
    echo "    # including respective dependencies via opkg from local files."
    echo "    ./util.sh install node-zigbee2mqtt mosquitto-ssl domoticz-zigbee2mqtt-plugin"
    echo
    echo "CAUTION:"
    echo "    This script may break sooner or later due to upstream changes. Please open an issue on github"
    echo "    if you have experienced any problems with ths script here:"
    echo "    https://github.com/mabachel/cc2531-home-automation-stack/issues"
    echo
    return 0
}

## download / update required files to build packages hereafter
function init {
    function feeds {
        cd ./modules/openwrt
        #git fetch --tags    # choose version you wish to use or comment out if you want current master / snapshot
        #git checkout v19.07.3
        ./scripts/feeds update -a
        ./scripts/feeds install -a
        cd ../..
    }
    if [ -f "./modules/openwrt/.git" ]; then
            git submodule update --remote   #git pull --recurse-submodules
            feeds
            if [ -d "./modules/openwrt/bin" ]; then
                : #rm -rf ./openwrt/bin
            fi
    else
        git submodule init
        git config submodule.cc-tool.update rebase
        git config submodule.domoticz-plugins-manager.update rebase
        git config submodule.domoticz-zigbee2mqtt-plugin.update rebase
        git config submodule.openwrt.update rebase
        git config submodule.zigbee2mqtt.update rebase
        git config submodule.cc-tool.ignore all
        git config submodule.domoticz-plugins-manager.ignore all
        git config submodule.domoticz-zigbee2mqtt-plugin.ignore all
        git config submodule.openwrt.ignore all
        git config submodule.zigbee2mqtt.ignore all
        git submodule update --remote
        feeds
        cd ./modules/openwrt
        echo "src-git node https://github.com/nxhack/openwrt-node-packages.git" >> ./feeds.conf.default
        git add ./feeds.conf.default
        git commit -m "add openwrt-node-packages to feeds.conf.default"
        ./scripts/feeds update node
        rm ./package/feeds/packages/node
        rm ./package/feeds/packages/node-*
        ./scripts/feeds install -a -p node
        cd ../..
    fi
    return
}

## copy all necassary packages to stack2install folder ready to transfer to your router via scp -r . root@192.168.1.1:/tmp/stack2install/
function collect {
    if [ ! -d "./stack2install" ]; then
        mkdir ./stack2install
    fi
    cd stack2install
    if [ $ARG_CC2531 == 1 ]; then
        cp ../modules/openwrt/bin/targets/$TARGET/generic/packages/$KMODUSBSERIALTIUSB ./
        cp ../modules/openwrt/bin/targets/$TARGET/generic/packages/$KMODUSBSERIAL ./
        cp ../modules/openwrt/bin/targets/$TARGET/generic/packages/$KMODUSBACM ./
    fi
    if [ $ARG_MAKE == 1 ]; then
        cp ../modules/openwrt/bin/packages/$ARCH/packages/$MAKE ./
    fi
    if [ $ARG_GCC == 1 ]; then
        cp ../modules/openwrt/bin/packages/$ARCH/packages/$GCC ./
        cp ../modules/openwrt/bin/packages/$ARCH/base/$BINUTILS ./
        cp ../modules/openwrt/bin/packages/$ARCH/base/$OBJDUMP ./
        cp ../modules/openwrt/bin/packages/$ARCH/base/$LIBOPCODES ./
        cp ../modules/openwrt/bin/packages/$ARCH/base/$LIBBFD ./
        cp ../modules/openwrt/bin/packages/$ARCH/base/$ZLIB ./
        cp ../modules/openwrt/bin/packages/$ARCH/base/$AR ./
        cp ../modules/openwrt/bin/targets/$TARGET/generic/packages/$LIBSTDCPP6 ./
    fi
    if [ $ARG_MOSQUITTOSSL == 1 ]; then
        cp ../modules/openwrt/bin/packages/$ARCH/packages/$MOSQUITTOSSL ./
        cp ../modules/openwrt/bin/targets/$TARGET/generic/packages/$LIBRT ./
        cp ../modules/openwrt/bin/targets/$TARGET/generic/packages/$LIBPTHREAD ./
        cp ../modules/openwrt/bin/targets/$TARGET/generic/packages/$LIBGCC1 ./
        cp ../modules/openwrt/bin/packages/$ARCH/base/$LIBOPENSSL11 ./
        cp ../modules/openwrt/bin/packages/$ARCH/packages/$LIBWEBSOCKETSOPENSSL ./
        cp ../modules/openwrt/bin/packages/$ARCH/base/$ZLIB ./
        cp ../modules/openwrt/bin/packages/$ARCH/packages/$LIBCAP ./
    fi
    if [ $ARG_MOSQUITTONOSSL == 1 ]; then
        : # TODO: add mosquitto-nossl and dependencies (libc, libssp, librt)
    fi
    if [ $ARG_NODE == 1 ]; then
        cp ../modules/openwrt/bin/targets/$TARGET/generic/packages/$LIBSTDCPP6 ./
        cp ../modules/openwrt/bin/packages/$ARCH/base/$LIBNGHTTP214 ./
        cp ../modules/openwrt/bin/packages/$ARCH/packages/$LIBUV1 ./
        cp ../modules/openwrt/bin/packages/$ARCH/packages/$LIBHTTPPARSER ./
        cp ../modules/openwrt/bin/packages/$ARCH/packages/$LIBCARES ./
        cp ../modules/openwrt/bin/targets/$TARGET/generic/packages/$LIBATROMIC1 ./
        cp ../modules/openwrt/bin/packages/$ARCH/node/$NODE ./
    fi
    if [ $ARG_NODENPM == 1 ]; then
        cp ../modules/openwrt/bin/packages/$ARCH/node/$NODENPM ./
    fi
    if [ $ARG_NODEZIGBEE2MQTT == 1 ]; then
        cp ../modules/openwrt/bin/packages/$ARCH/node/$NODEZIGBEE2MQTT ./
    fi
    if [ $ARG_PYTHON3LIGHT == 1 ]; then
        cp ../modules/openwrt/bin/packages/$ARCH/packages/$PYTHON3LIGHT ./
        cp ../modules/openwrt/bin/packages/$ARCH/packages/$PYTHON3BASE ./
        cp ../modules/openwrt/bin/packages/$ARCH/packages/$LIBFFI ./
        cp ../modules/openwrt/bin/packages/$ARCH/base/$LIBBZ210 ./
    fi
    if [ $ARG_PYTHON3MULTIPROCESSING == 1 ]; then
        cp ../modules/openwrt/bin/packages/$ARCH/packages/$PYTHON3MULTIPROCESSING ./
    fi
    if [ $ARG_PYTHON3 == 1 ]; then
        cp ../modules/openwrt/bin/packages/$ARCH/packages/$PYTHON3 ./
        cp ../modules/openwrt/bin/targets/$TARGET/generic/packages/$LIBPTHREAD ./
        cp ../modules/openwrt/bin/targets/$TARGET/generic/packages/$LIBGCC1 ./
        cp ../modules/openwrt/bin/packages/$ARCH/base/$ZLIB ./
        cp ../modules/openwrt/bin/packages/$ARCH/base/$LIBUUID1 ./
        cp ../modules/openwrt/bin/targets/$TARGET/generic/packages/$LIBRT ./
        cp ../modules/openwrt/bin/packages/$ARCH/packages/$PYTHON3UNITTEST ./
        cp ../modules/openwrt/bin/packages/$ARCH/packages/$PYTHON3NCRUSES ./
        cp ../modules/openwrt/bin/packages/$ARCH/base/$LIBNCURSES6 ./
        cp ../modules/openwrt/bin/packages/$ARCH/base/$TERMINFO ./
        cp ../modules/openwrt/bin/packages/$ARCH/packages/$PYTHON3CTYPES ./
        cp ../modules/openwrt/bin/packages/$ARCH/packages/$PYTHON3PYDOC ./
        cp ../modules/openwrt/bin/packages/$ARCH/packages/$PYTHON3LOGGING ./
        cp ../modules/openwrt/bin/packages/$ARCH/packages/$PYTHON3DECIMAL ./
        cp ../modules/openwrt/bin/packages/$ARCH/packages/$PYTHON3URLLIB ./
        cp ../modules/openwrt/bin/packages/$ARCH/packages/$PYTHON3EMAIL ./
        cp ../modules/openwrt/bin/packages/$ARCH/packages/$PYTHON3GDBM ./
        cp ../modules/openwrt/bin/packages/$ARCH/packages/$LIBGDBM ./
        cp ../modules/openwrt/bin/packages/$ARCH/packages/$PYTHON3SQLITE ./
        cp ../modules/openwrt/bin/packages/$ARCH/packages/$LIBSQLITE30 ./
        cp ../modules/openwrt/bin/packages/$ARCH/packages/$PYTHON3XML ./
        cp ../modules/openwrt/bin/packages/$ARCH/packages/$PYTHON3DISUTILS ./
        cp ../modules/openwrt/bin/packages/$ARCH/packages/$PYTHON3CODECS ./
        cp ../modules/openwrt/bin/packages/$ARCH/packages/$PYTHON3OPENSSL ./
        cp ../modules/openwrt/bin/packages/$ARCH/base/$LIBOPENSSL11 ./
        cp ../modules/openwrt/bin/packages/$ARCH/base/$CABUNDLE ./
        cp ../modules/openwrt/bin/packages/$ARCH/packages/$PYTHON3CGI ./
        cp ../modules/openwrt/bin/packages/$ARCH/packages/$PYTHON3CGITB ./
        cp ../modules/openwrt/bin/packages/$ARCH/packages/$PYTHON3DBM ./
        cp ../modules/openwrt/bin/packages/$ARCH/packages/$LIBDB47 ./
        cp ../modules/openwrt/bin/packages/$ARCH/packages/$LIBXML2 ./
        cp ../modules/openwrt/bin/packages/$ARCH/packages/$PYTHON3LZMA ./
        cp ../modules/openwrt/bin/packages/$ARCH/packages/$LIBLZMA ./
        cp ../modules/openwrt/bin/packages/$ARCH/packages/$PYTHON3ASYNCIO ./
    fi
    if [ $ARG_PYTHON3PIP == 1 ]; then
        cp ../modules/openwrt/bin/packages/$ARCH/packages/$PYTHON3PIP ./
        cp ../modules/openwrt/bin/packages/$ARCH/packages/$PYTHON3SETUPTOOLS ./
        cp ../modules/openwrt/bin/packages/$ARCH/packages/$PYTHON3PKGRESOURCES ./
        cp ../modules/openwrt/bin/packages/$ARCH/packages/$PYTHONPIPCONF ./
    fi
    
    if [ $ARG_ZIGBEE2MQTT == 1 ]; then
        cp -r ../zigbee2mqtt ./
        rm -rf ./zigbee2mqtt/.git* ./zigbee2mqtt/.vscode 
    fi
    if [ $ARG_DOMOTICZ == 1 ]; then
        cp ../modules/openwrt/bin/packages/$ARCH/packages/$DOMOTICZ ./
        cp ../modules/openwrt/bin/packages/$ARCH/packages/$BOOST ./
        cp ../modules/openwrt/bin/targets/$TARGET/generic/packages/$LIBSTDCPP6 ./
        cp ../modules/openwrt/bin/targets/$TARGET/generic/packages/$LIBPTHREAD ./
        cp ../modules/openwrt/bin/targets/$TARGET/generic/packages/$LIBGCC1 ./
        cp ../modules/openwrt/bin/targets/$TARGET/generic/packages/$LIBRT ./
        cp ../modules/openwrt/bin/packages/$ARCH/packages/$BOOSTDATETIME ./
        cp ../modules/openwrt/bin/packages/$ARCH/packages/$BOOSTSYSTEM ./
        cp ../modules/openwrt/bin/packages/$ARCH/packages/$BOOSTTHREAD ./
        cp ../modules/openwrt/bin/packages/$ARCH/packages/$BOOSTCHRONO ./
        cp ../modules/openwrt/bin/packages/$ARCH/packages/$BOOSTATOMIC ./
        cp ../modules/openwrt/bin/packages/$ARCH/packages/$JSONCPP ./
        cp ../modules/openwrt/bin/packages/$ARCH/base/$LIBCURL4 ./
        cp ../modules/openwrt/bin/packages/$ARCH/base/$LIBMEDBTLS12 ./
        cp ../modules/openwrt/bin/packages/$ARCH/base/$CABUNDLE ./
        cp ../modules/openwrt/bin/packages/$ARCH/packages/$MINIZIP ./
        cp ../modules/openwrt/bin/packages/$ARCH/base/$ZLIB ./
        cp ../modules/openwrt/bin/packages/$ARCH/base/$LUA53 ./
        cp ../modules/openwrt/bin/packages/$ARCH/base/$LIBLUA5353 ./
        cp ../modules/openwrt/bin/packages/$ARCH/packages/$LIBMOSQUITTOSSL ./
        cp ../modules/openwrt/bin/packages/$ARCH/packages/$LIBCARES ./
        cp ../modules/openwrt/bin/packages/$ARCH/base/$LIBOPENSSL11 ./
        cp ../modules/openwrt/bin/packages/$ARCH/packages/$LIBOPENZWAVE ./
        cp ../modules/openwrt/bin/packages/$ARCH/packages/$LIBSQLITE30 ./
        cp ../modules/openwrt/bin/packages/$ARCH/packages/$TELLDUSCORE ./
        cp ../modules/openwrt/bin/packages/$ARCH/packages/$CONFUSE ./
        cp ../modules/openwrt/bin/packages/$ARCH/packages/$LIBFTDI ./
        cp ../modules/openwrt/bin/packages/$ARCH/base/$LIBUSBCOMPAT4 ./
        cp ../modules/openwrt/bin/packages/$ARCH/base/$LIBUSB100 ./
    fi
    if [ $ARG_DOMOTICZZIGBE2MQTTPLUGIN == 1 ]; then
        cp -r ../modules/domoticz-zigbee2mqtt-plugin ./
        rm -rf ./domoticz-zigbee2mqtt-plugin/.git*
    fi
    if [ $ARG_DOMOTICZPLUGINMANGER == 1 ]; then
        cp -r ../modules/domoticz-plugins-manager ./
        rm -rf ./domoticz-plugins-manager/.git*
    fi
    cd ..
    return
    # templates
    #cp ../ ./
    #cp ../modules/openwrt/bin/packages/$ARCH/base/$ ./
    #cp ../modules/openwrt/bin/packages/$ARCH/packages/$ ./
    #cp ../modules/openwrt/bin/targets/$TARGET/generic/packages/$ ./
}

## install stack on router
function install {
    if [ $ARG_CC2531 == 1 ]; then
        opkg install $KMODUSBACM #$KMODUSBSERIALTIUSB $KMODUSBSERIAL
    fi
    if [ $ARG_MAKE == 1 ]; then
        opkg install $MAKE
    fi
    if [ $ARG_GCC == 1 ]; then
        opkg install $GCC $BINUTILS $OBJDUMP $LIBOPCODES $LIBBFD $ZLIB $AR $LIBSTDCPP6
    fi
    if [ $ARG_MOSQUITTOSSL == 1 ]; then
        opkg install $MOSQUITTOSSL $LIBRT $LIBPTHREAD $LIBGCC1 $LIBOPENSSL11 $LIBWEBSOCKETSOPENSSL $ZLIB $LIBCAP
    fi
    if [ $ARG_MOSQUITTONOSSL == 1 ]; then
        : # TODO: add mosquitto-nossl and dependencies (libc, libssp, librt)
    fi
    if [ $ARG_NODE == 1 ]; then
        opkg install $NODE $LIBSTDCPP6 $LIBNGHTTP214 $LIBUV1 $LIBHTTPPARSER $LIBCARES $LIBATROMIC1
    fi
    if [ $ARG_NODENPM == 1 ]; then
        opkg install $NPM
    fi
    if [ $ARG_NODEZIGBEE2MQTT == 1 ]; then
        opkg install $NODEZIGBEE2MQTT
    fi
    if [ $ARG_PYTHON3LIGHT == 1 ]; then
        opkg install $PYTHON3LIGHT $PYTHON3BASE $LIBFFI $LIBBZ210
    fi
    if [ $ARG_PYTHON3MULTIPROCESSING == 1 ]; then
        opkg install $PYTHON3MULTIPROCESSING
    fi
    if [ $ARG_PYTHON3 == 1 ]; then
        opkg install $PYTHON3 $PYTHON3UNITTEST $PYTHON3NCRUSES $LIBNCURSES6 $TERMINFO $PYTHON3CTYPES $PYTHON3PYDOC $PYTHON3LOGGING $PYTHON3DECIMAL $PYTHON3MULTIPROCESSING $PYTHON3CODECS $PYTHON3XML $PYTHON3SQLITE $LIBSQLITE30 $PYTHON3GDBM $LIBGDBM $PYTHON3DISUTILS $PYTHON3EMAIL $PYTHON3OPENSSL $LIBOPENSSL $CABUNDLE $PYTHON3URLLIB $PYTHON3CGI $PYTHON3CGITB $PYTHON3DBM $LIBDB47 $LIBXML2 $PYTHON3LZMA $LIBLZMA $PYTHON3ASYNCIO
    fi
    if [ $ARG_PYTHON3PIP == 1 ]; then
        opkg install $PYTHON3PIP $PYTHON3SETUPTOOLS $PYTHON3PKGRESOURCES $PYTHONPIPCONF
    fi
    if [ $ARG_ZIGBEE2MQTT == 1 ]; then
        cp -r ./zigbee2mqtt /opt/
        ar -rc /usr/lib/libpthread.a
        cd /opt/zigbee2mqtt
        npm ci
    fi
    if [ $ARG_DOMOTICZ == 1 ]; then
        opkg install $DOMOTICZ $BOOST $BOOSTDATETIME $BOOSTSYSTEM $BOOSTTHREAD $BOOSTCHRONO $BOOSTATOMIC $JSONCPP $LIBCURL4 $LIBMEDBTLS12 $CABUNDLE $MINIZIP $LUA53 $LIBLUA5353 $LIBMOSQUITTOSSL $LIBOPENZWAVE $LIBSQLITE30 $TELLDUSCORE $CONFUSE $LIBFTDI $LIBUSBCOMPAT4 $LIBUSB100 
    fi
    if [ $ARG_DOMOTICZZIGBE2MQTTPLUGIN == 1 ]; then
        cp -r ./domoticz-zigbee2mqtt-plugin/* /etc/domoticz/plugins/zigbee2mqtt/
    fi
    if [ $ARG_DOMOTICZPLUGINMANGER == 1 ]; then
        cp -r ./domoticz-plugins-manager/* /etc/domoticz/plugins/plugins-manager/
    fi
    return
}

## remove stack from router
function remove {
    : # TODO
    echo "remove is not yet implemented"
    return 1
}

### Script Starts Here ###
## Defaults
ARG_HELP=0
ARG_INIT=0
ARG_COLLECT=0
ARG_INSTALL=0
ARG_REMOVE=0
ARG_UNKNOWN=0

## Evaluate Script Arguments
case $1 in
    --help|help|-h)
    ARG_HELP=1
    ;;
    initialize|init)
    ARG_INIT=1
    ;;
    collect)
    ARG_COLLECT=1
    ;;
    install)
    ARG_INSTALL=1
    ;;
    remove)
    ARG_REMOVE=1
    ;;
    *)
    ARG_UNKNOWN=1
esac

## Call Functions without Package Context
if [ $ARG_UNKNOWN == 1 ]; then
    echo -e "#\e[31m Unknown argument: $1\e[0m"
    echo
    printHelp
    exit 1
fi
if [ $ARG_HELP == 1 ]; then
    printHelp
    exit 0
fi
if [ $ARG_INIT == 1 ]; then
    init
    exit 0
fi

shift # Remove $1 from processing

## Package Defaults
ARG_CC2531=0
ARG_MAKE=0
ARG_GCC=0
ARG_MOSQUITTOSSL=0
ARG_MOSQUITTONOSSL=0
ARG_NODE=0
ARG_NODENPM=0
ARG_NODEZIGBEE2MQTT=0
ARG_PYTHON3LIGHT=0
ARG_PYTHON3MULTIPROCESSING=0
ARG_PYTHON3=0
ARG_PYTHON3PIP=0
ARG_ZIGBEE2MQTT=0
ARG_DOMOTICZ=0
ARG_DOMOTICZZIGBE2MQTTPLUGIN=0
ARG_DOMOTICZPLUGINMANGER=0

## Evaluate Package Arguments
for arg in "$@"
do
    case $arg in
        cc2531)
        ARG_CC2531=1
        shift # Remove from processing
        ;;
        make)
        ARG_MAKE=1
        shift # Remove from processing
        ;;
        gcc)
        ARG_GCC=1
        shift # Remove from processing
        ;;
        mosquitto-ssl)
        ARG_MOSQUITTOSSL=1
        shift # Remove from processing
        ;;
        mosquitto-nossl)
        ARG_MOSQUITTONOSSL=1
        shift # Remove from processing
        ;;
        node)
        ARG_NODE=1
        shift # Remove from processing
        ;;
        node-npm)
        ARG_NODENPM=1
        shift # Remove from processing
        ;;
        node-zigbee2mqtt)
        ARG_CC2531=1
        ARG_NODE=1
        ARG_NODEZIGBEE2MQTT=1
        shift # Remove from processing
        ;;
        python3-light)
        ARG_PYTHON3LIGHT=1
        shift # Remove from processing
        ;;
        python3-multiprocessing)
        ARG_PYTHON3MULTIPROCESSING=1
        shift # Remove from processing
        ;;
        python3)
        ARG_PYTHON3LIGHT=1
        ARG_PYTHON3MULTIPROCESSING=1
        ARG_PYTHON3=1
        shift # Remove from processing
        ;;
        python3-pip)
        ARG_PYTHON3LIGHT=1
        ARG_PYTHON3MULTIPROCESSING=1
        ARG_PYTHON3=1
        ARG_PYTHON3PIP=1
        shift # Remove from processing
        ;;
        zigbee2mqtt)
        ARG_CC2531=1
        ARG_NODE=1
        ARG_NODENPM=1
        ARG_MAKE=1
        ARG_GCC=1
        ARG_PYTHON3MULTIPROCESSING=1
        ARG_ZIGBEE2MQTT=1
        shift # Remove from processing
        ;;
        domoticz)
        ARG_DOMOTICZ=1
        shift # Remove from processing
        ;;
        domoticz-zigbee2mqtt-plugin)
        # zigbee2mqtt or node-zigbee2mqtt is necassary as well
        ARG_PYTHON3LIGHT=1
        #ARG_PYTHON3MULTIPROCESSING=1
        #ARG_PYTHON3=1
        ARG_DOMOTICZ=1
        ARG_DOMOTICZZIGBE2MQTTPLUGIN=1
        shift # Remove from processing
        ;;
        domoticz-plugins-manager)
        ARG_PYTHON3LIGHT=1
        #ARG_PYTHON3MULTIPROCESSING=1
        #ARG_PYTHON3=1
        ARG_DOMOTICZ=1
        ARG_DOMOTICZPLUGINMANGER=1
        shift # Remove from processing
        ;;
        *)
        echo -e "#\e[31m Unknown Package: $1\e[0m"
        echo "Please use './util.sh help' to find a list of known packages."
        echo -e "#\e[31m FAIL \e[0m"
        exit 1
    esac
done

## Define package shell variables. Indentation is similar to opkg dependencies listing in luci.
# node
NODE="node_*_$ARCH.ipk"
    LIBSTDCPP6="libstdcpp6_*_$ARCH.ipk"
    LIBNGHTTP214="libnghttp2-14_*_$ARCH.ipk"
    LIBUV1="libuv1_*_$ARCH.ipk"
    LIBHTTPPARSER="libhttp-parser_*_$ARCH.ipk"
    LIBCARES="libcares_*_$ARCH.ipk"
    LIBATROMIC1="libatomic1_*_$ARCH.ipk"
    
# node-npm
NODENPM="node-npm_*_$ARCH.ipk"

# node-zigbee2mqtt
NODEZIGBEE2MQTT="node-zigbee2mqtt_*_$ARCH.ipk"

# python3
PYTHON3PIP="python3-pip_*_$ARCH.ipk"
PYTHON3="python3_*_$ARCH.ipk"
    PYTHON3LIGHT="python3-light_*_$ARCH.ipk"
        PYTHON3BASE="python3-base_*_$ARCH.ipk"
            LIBPTHREAD="libpthread_*_$ARCH.ipk" 
                LIBGCC1="libgcc1_*_$ARCH.ipk"
            ZLIB="zlib_*_$ARCH.ipk"
        LIBFFI="libffi_*_$ARCH.ipk"
        LIBBZ210="libbz2-1.0_*_$ARCH.ipk"
        LIBUUID1="libuuid1_*_$ARCH.ipk"
            LIBRT="librt_*_$ARCH.ipk"
    PYTHON3UNITTEST="python3-unittest_*_$ARCH.ipk"
    PYTHON3NCRUSES="python3-ncurses_*_$ARCH.ipk"
        LIBNCURSES6="libncurses6_*_$ARCH.ipk"
            TERMINFO="terminfo*.ipk"
    PYTHON3CTYPES="python3-ctypes_*_$ARCH.ipk"
    PYTHON3PYDOC="python3-pydoc_*_$ARCH.ipk"
    PYTHON3LOGGING="python3-logging_*_$ARCH.ipk"
    PYTHON3DECIMAL="python3-decimal_*_$ARCH.ipk"
    PYTHON3MULTIPROCESSING="python3-multiprocessing_*_$ARCH.ipk"
    PYTHON3CODECS="python3-codecs_*_$ARCH.ipk"
    PYTHON3XML="python3-xml_*_$ARCH.ipk"
    PYTHON3SQLITE="python3-sqlite3_*_$ARCH.ipk"    
        LIBSQLITE30="libsqlite3-0_*_$ARCH.ipk"
    PYTHON3GDBM="python3-gdbm_*_$ARCH.ipk"
        LIBGDBM="libgdbm_*_$ARCH.ipk"
    PYTHON3DISUTILS="python3-distutils_*_$ARCH.ipk"
    PYTHON3OPENSSL="python3-openssl_*_$ARCH.ipk"
        LIBOPENSSL11="libopenssl1.1_*_$ARCH.ipk"
        CABUNDLE="ca-bundle_*_all.ipk"
    PYTHON3URLLIB="python3-urllib_*_$ARCH.ipk"
        PYTHON3EMAIL="python3-email_*_$ARCH.ipk"
    PYTHON3CGI="python3-cgi_*_$ARCH.ipk"
    PYTHON3CGITB="python3-cgitb_*_$ARCH.ipk"
    PYTHON3DBM="python3-dbm_*_$ARCH.ipk"
        LIBDB47="libdb47_*_$ARCH.ipk"
            LIBXML2="libxml2_*_$ARCH.ipk"
    PYTHON3LZMA="python3-lzma_*_$ARCH.ipk"
        LIBLZMA="liblzma_*_$ARCH.ipk"
    PYTHON3ASYNCIO="python3-asyncio_*_$ARCH.ipk"
PYTHON3SETUPTOOLS="python3-setuptools_*_$ARCH.ipk"
    PYTHON3PKGRESOURCES="python3-pkg-resources_*_$ARCH.ipk"
PYTHONPIPCONF="python-pip-conf_*_$ARCH.ipk"



# mosquitto-ssl
MOSQUITTOSSL="mosquitto-ssl_*_$ARCH.ipk"
    LIBRT="librt_*_$ARCH.ipk"
        LIBPTHREAD="libpthread_*_$ARCH.ipk" 
            LIBGCC1="libgcc1_*_$ARCH.ipk"
    LIBOPENSSL11="libopenssl1.1_*_$ARCH.ipk"
    LIBWEBSOCKETSOPENSSL="libwebsockets-openssl_*_$ARCH.ipk"
        ZLIB="zlib_*_$ARCH.ipk"
        LIBCAP="libcap_*_$ARCH.ipk"
        
# mosquitto-nossl
MOSQUITTONOSSL="mosquitto-nossl_*_$ARCH.ipk"
    # TODO: add dependencies (libc, libssp, librt)

# domoticz
DOMOTICZ="domoticz_*_$ARCH.ipk"
    BOOST="boost_*_$ARCH.ipk"
        LIBSTDCPP6="libstdcpp6_*_$ARCH.ipk"
        LIBPTHREAD="libpthread_*_$ARCH.ipk" 
            LIBGCC1="libgcc1_*_$ARCH.ipk"
        LIBRT="librt_*_$ARCH.ipk"
    BOOSTDATETIME="boost-date_time_*_$ARCH.ipk"
    BOOSTSYSTEM="boost-system_*_$ARCH.ipk"
    BOOSTTHREAD="boost-thread_*_$ARCH.ipk"
        BOOSTCHRONO="boost-chrono_*_$ARCH.ipk"
        BOOSTATOMIC="boost-atomic_*_$ARCH.ipk"
    JSONCPP="jsoncpp_*_$ARCH.ipk"
    LIBCURL4="libcurl4*.ipk"
        LIBMEDBTLS12="libmbedtls12_*_$ARCH.ipk"
        CABUNDLE="ca-bundle_*_all.ipk"
    MINIZIP="minizip_*_$ARCH.ipk"
        ZLIB="zlib_*_$ARCH.ipk"
    LUA53="lua5.3_*_$ARCH.ipk"
        LIBLUA5353="liblua5.3-5.3_*_$ARCH.ipk"
    LIBMOSQUITTOSSL="libmosquitto-ssl_*_$ARCH.ipk"
        LIBCARES="libcares_*_$ARCH.ipk"
        LIBOPENSSL11="libopenssl1.1_*_$ARCH.ipk"
    LIBOPENZWAVE="libopenzwave_*_$ARCH.ipk"
    LIBSQLITE30="libsqlite3-0_*_$ARCH.ipk"
    TELLDUSCORE="telldus-core_*_$ARCH.ipk"
        CONFUSE="confuse_*_$ARCH.ipk"
        LIBFTDI="libftdi_*_$ARCH.ipk"
            LIBUSBCOMPAT4="libusb-compat4_*_$ARCH.ipk"
                LIBUSB100="libusb-1.0-0_*_$ARCH.ipk"
                
# make
MAKE="make_*_$ARCH.ipk"

# gcc
GCC="gcc_*_$ARCH.ipk"
    BINUTILS="binutils_*_$ARCH.ipk"
        OBJDUMP="objdump_*_$ARCH.ipk"
            LIBOPCODES="libopcodes_*_$ARCH.ipk"
                LIBBFD="libbfd_*_$ARCH.ipk"
                    ZLIB="zlib_*_$ARCH.ipk"
        AR="ar_*_$ARCH.ipk"
    LIBSTDCPP6="libstdcpp6_*_$ARCH.ipk"
    
# cc2531
KMODUSBSERIALTIUSB="kmod-usb-serial-ti-usb_*_$ARCH.ipk"
    KMODUSBSERIAL="kmod-usb-serial_*_$ARCH.ipk"
KMODUSBACM="kmod-usb-acm_*_$ARCH.ipk"


## Call Functions with Package Context
if [ $ARG_COLLECT == 1 ]; then
    collect
fi
if [ $ARG_INSTALL == 1 ]; then
    install
fi
if [ $ARG_REMOVE == 1 ]; then
    remove
fi

## Exit
if [ $? == 0 ]; then 
    echo -e "\e[32m SUCCESS \e[0m"
else
    echo -e "#\e[31m FAIL \e[0m"
    exit 1
fi
