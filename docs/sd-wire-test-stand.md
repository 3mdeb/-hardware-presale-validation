# SD Wire test stand documentation

## Summary of required elements

1. __2x__ RTE HAT.
1. __2x__ Orange Pi Zero with soldered 26-pin header.
1. __2x__ 5V 2A micro USB power supply for OPi board.
1. __3x__ Micro SD card (2x for Orange Pi Zero and 1x for SDWire).
1. __2x__ RJ45 Ethernet cable.
1. Micro-USB --> USB cable
1. UART/USB converter or RS232 null modem cable (or 3/5 jumper wires).
1. SDWire

## RTE with meta-rte setup

### Required elements

1. RTE HAT.
1. Orange Pi Zero with soldered 26-pin header.
1. 5V 2A micro USB power supply for OPi board.
1. Micro SD card for Orange Pi Zero.
1. RJ45 Ethernet cable (for RTE and DUT).
1. UART/USB converter or RS232 null modem cable (or 3/5 jumper wires).

### Installing OS on Orange Pi

1. Download the `meta-rte` image from [3mdeb cloud](https://cloud.3mdeb.com/).
1. Extract downloaded image.
1. Flash micro SD card, e.g. using:

    ```bash
    sudo dd if=PATH_TO_IMAGE of=/dev/sdc status=progress bs=4M
    ```

1. Plug card into Orange Pi.

### RTE connections

1. Plug RTE to Orange Pi, then connect 5V power supply directly to OPi or J17
    connector on RTE.
1. Connect Ethernet cable to OPi.
1. Set serial connection wit RTE - connect UART/USB converter between PC and RTE
    (J2 header with pins GND, RX, TX)  and type on your PC terminal:

    ```bash
    sudo minicom -D /dev/ttyUSB0 -o -b 115200
    ```

1. Log in to system:

    ```bash
    login: root
    password: meta-rte
    ```

1. Set static ip for RTE - while connected with RTE via minicom, edit
    `/lib/systemd/network/50-dhcp.network` (using vi):

    ```bash
    [Match]
    Name=eth0
    
    [Network]
    DNS=192.168.3.1
    Address=192.168.3.XX
    Gateway=192.168.3.1
    ```

    where `XX` is chosen static IP for your RTE (be sure that this IP is not
    taken by someone else). Then save changed file, reboot RTE and after logging
    again, type `ifconfig` and check if "eth0/inet addr" is the same as set in
    previous step. If everything is correct, you can now use ssh connection
    with known ip address.

### RTE configuration

1. After acquired IP address, we can connect to RTE's OS via SSH by running
    ssh USER@RTE_IP, for example:

    ```bash
    ssh root@192.168.3.105
    ```

1. After successful connection, check if ser2net redirection is configured.
    Type:

    ```bash
    root@orange-pi-zero:~# cat /etc/ser2net.conf
    ```

1. Output should contain:

    ```bash
    13541:telnet:600:/dev/ttyS1:115200 8DATABITS NONE 1STOPBIT
    13542:telnet:600:/dev/ttyUSB0:115200 8DATABITS NONE 1STOPBIT
    ```

## RTE with Armbian setup

It's important to say that setup for `Armbian` is similar to setup for
`meta-rte`, but there are several key differences.

### Required elements

1. RTE HAT.
1. Orange Pi Zero with soldered 26-pin header.
1. 5V 2A micro USB power supply for OPi board.
1. Micro SD card for Orange Pi Zero.
1. RJ45 Ethernet cable (for RTE and DUT).
1. UART/USB converter or RS232 null modem cable (or 3/5 jumper wires).

### Installing OS on Orange Pi

1. Download the `Armbian` image from [3mdeb cloud](https://cloud.3mdeb.com/).
1. Extract downloaded image.
1. Flash micro SD card, e.g. using:

    ```bash
    sudo dd if=PATH_TO_IMAGE of=/dev/sdc status=progress bs=4M
    ```

1. Plug card into Orange Pi.

### RTE connections

1. Plug RTE to Orange Pi, then connect 5V power supply directly to OPi or J17
    connector on RTE.
1. Connect Ethernet cable to OPi.
1. Set serial connection wit RTE - connect UART/USB converter between PC and RTE
    (J2 header with pins GND, RX, TX)  and type on your PC terminal:

    ```bash
    sudo minicom -D /dev/ttyUSB0 -o -b 115200
    ```

1. Log in to system:

    ```bash
    login: root
    password: armbian
    ```

1. Set static ip for RTE - while connected with RTE via minicom, edit
    `/etc/network/interfaces.d/eth0` file (vim or nano):

    ```bash
    auto eth0
    iface eth0 inet static
            address 192.168.3.XX
            netmask 255.255.255.0
            gateway 192.168.3.1
            dns-nameservers 8.8.8.8 8.8.4.4
    ```

### RTE configuration

1. After acquired IP address, we can connect to RTE's OS via SSH by running
    ssh USER@RTE_IP, for example:

    ```bash
    ssh root@192.168.3.105
    ```

1. After successful connection, check if ser2net redirection is configured.
    Type:

    ```bash
    root@orange-pi-zero:~# cat /etc/ser2net.conf
    ```

1. Output should contain:

    ```bash
    13541:telnet:600:/dev/ttyS1:115200 8DATABITS NONE 1STOPBIT
    13542:telnet:600:/dev/ttyUSB0:115200 8DATABITS NONE 1STOPBIT
    ```

## SDWire setup

### Required elements

1. SDWire
1. SD card
1. Micro-USB --> USB cable

### Environment preparation

SDWire has dedicated software which is a simple tool meant to control the
hardware. Source code of the tool is published on tizen git server. This is
simple to use, command-line utility software written in C and based on
open-source libFTDI library.

1. Clone the repository:

    ```bash
    git clone https://git.tizen.org/cgit/tools/testlab/sd-mux
    ```

1. Check whether the installation requirements for sd-mux are met:

    - `libftdi1` 1.4 development library is installed. To do this, open the
        terminal and type the following command:

        ```bash
        dpkg -L libftdi1-dev
        ```

        If the library is installed, after typing the above command you will
        see information about the paths to the library components. * popt
        development library is installed. To do this, open the terminal and type
        the following command:

        ```bash
        dpkg -L libpopt-dev
        ```

        If the library is installed, after typing the above command you will see
        information about the paths to the library components. * cmake binary
        tool is installed. To do this, open the terminal and type the following
        command:

        ```bash
        cmake --version
        ```

        If the tool is installed, after typing the above command you will see
        information about the installed on your computer cmake version.

1. Install missing libraries and/or tools:

    - `libftdi1` 1.4 development library. To do this, open the terminal and type
        the following command:

        ```bash
        sudo apt-get install libftdi1-dev
        ```

    - `popt` development library. To do this, open the terminal and type the
        following command:

        ```bash
        sudo apt-get install libpopt-dev
        ```

    - `cmake` binary tool. To do this, open the terminal and type the following
        command:

        ```bash
        sudo apt-get install cmake
        ```

1. Enter into sd-mux project directory and reproduce the following steps to
    build project:

    - open directory in terminal
    - create `build` directory by the following command:

        ```bash
        mkdir build
        ```

    - enter into 'build' directory by the following command:

        ```bash
        cd build
        ```

    - run the following commands one by one:

        ```bash
        cmake ..
        make
        ```

1. In the above-described directory (sd-mux/build) run the following command to
    build binary:

    ```bash
    sudo make install
    ```

    Note, that the above-described command installs binary into
    `/usr/local/bin`. If you want to install files in directory rather than the
    default one add an argument to cmake command:

    ```bash
    cmake -DCMAKE_INSTALL_PREFIX=/usr ..
    ```

    Then it is obligatory to run again the following commands:

    ```bash
    make
    make install
    ```

## Combining and finalizing setup

<!-- Work in progress -->
