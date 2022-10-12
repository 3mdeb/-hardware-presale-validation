# SD Wire test cases documentation

TS - Test Server
DUT - Device under test

## SDWire_001 Device recognition

1. Run in the TS terminal the following command:

    ```bash
    dmesg
    ```

1. The output should contain information about detected SDWire. Example output:

    ```bash
    (...)
    [73278.307591] usb-storage 3-1.1:1.0: USB Mass Storage device detected
    [73278.307823] scsi host6: usb-storage 3-1.1:1.0
    [73278.384925] usb 3-1.2: new full-speed USB device number 45 using xhci_hcd
    [73278.492025] usb 3-1.2: New USB device found, idVendor=0403, idProduct=6015, bcdDevice=10.00
    [73278.492027] usb 3-1.2: New USB device strings: Mfr=1, Product=2, SerialNumber=3
    [73278.492028] usb 3-1.2: Product: FT200X USB I2C
    [73278.492029] usb 3-1.2: Manufacturer: FTDI
    [73278.492030] usb 3-1.2: SerialNumber: DB007V7V
    (...)
    ```

1. Save output for the next tests.

## SDWire_002 SD-wire configure and list

1. Run in the TS terminal the following command:

    ```bash
    sudo sd-mux-ctrl --device-serial=DB007V7V --vendor=0x0403 --product=0x6015 --device-type=sd-wire --set-serial=SDWIRE
    ```

    where:

    ```bash
    --device-serial=<SerialNumber> (from dmesg output)

    --vendor=0x<idVendor> (from dmesg output)

    --product=0x<idProduct> (from dmesg output)

    --set-serial=<New serial device>
    ```

1. Run in the TS terminal the following command:

    ```bash
    sudo sd-mux-ctrl --list
    ```

1. The output of the command above should be similar to this below:

    ```bash
    Number of FTDI devices found: 1
    Dev: 0, Manufacturer: SRPOL, Serial: SDWIRE, Description: sd-wire
    ```

    Unwanted output:

    ```bash
    Number of FTDI devices found: 0
    ```

## SDWire_003 SD-wire connects to the TS

1. Run in the TS terminal the following command:

    ```bash
    sudo sd-mux-ctrl --device-serial=sd-wire_11 --ts
    ```

1. Output ?

## SDWire_004 SD card flashing

1. Run in the TS terminal the following commands:

    ```bash
    sudo bmaptool copy --bmap ~/path/where/your/bmap/file/is/located /path/where/your/image/is/located /path/to/memory/device
    ```

1. Output ?

## SDWire_005 SD-wire connects to the DUT

1. Run in the TS terminal the following command:

    ```bash
    sudo sd-mux-ctrl --device-serial=sd-wire_11 --dut
    ```

1. Output ?

## SDWire_006 Booting OS from SD-wire

1. Power on the DUT.
1. Get output from the DUT.
1. The DUT should properly boot to the `login` phrase.
