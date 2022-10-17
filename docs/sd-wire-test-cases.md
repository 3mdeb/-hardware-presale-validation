# SD Wire test cases documentation

## Glossary

* TS - Test Server
* DUT - Device Under Test

## Test cases common documentation

**Test setup**

1. Compiled test environment in accordance with
    [SDWire test stand](/docs/sd-wire-test-stand.md)

## SDWire_001 SDWire recognition

**Test description**

This test aims to verify that the connected SDWire is recognizable by the Test
Server.

**Test setup**

1. Proceed with the
    [Test cases common documentation](#test-cases-common-documentation) section.

**Test steps**

1. Login into the TS by using the proper login and password.
1. Run in the TS terminal the following command:

    ```bash
    dmesg
    ```

**Expected result**

The output should contain information about detected SDWire. The output of the
command should show, that the Product is `FT200X USB I2C` and the Manufacturer
is `FTDI`.

Example output:

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

## SDWire_002 SDWire configuration and reading

**Test description**

This test aims to verify that the configuration procedure for the SDWire works
correctly and, after the procedure, the test device is readable.

**Test setup**

1. Proceed with the
    [Test cases common documentation](#test-cases-common-documentation) section.

**Test steps**

1. Login into the TS by using the proper login and password.
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

**Expected result**

The output of the last command should contain information about founding at
least one FTDI device.

Example output:

```bash
Number of FTDI devices found: 1
Dev: 0, Manufacturer: SRPOL, Serial: SDWIRE, Description: sd-wire
```

## SDWire_003 SDWire connecting to the Test Server

**Test description**

This test aims to verify that the connecting to the TS procedure for the
SDWire works correctly and, after the procedure, the test device is manageable
from the TS.

**Test setup**

1. Proceed with the
    [Test cases common documentation](#test-cases-common-documentation) section.

**Test steps**

1. Login into the TS by using the proper login and password.
1. Run in the TS terminal the following command:

    ```bash
    sudo sd-mux-ctrl --device-serial=<serial_device> --ts
    ```

1. Check the status of the connection by running the following command:

    ```bash
    sudo sd-mux-ctrl --device-serial=<serial_device> --status
    ```

**Expected result**

The output of the last command should contain information that the SDWire is
connected to the TS.

Example output:

```bash
SD connected to: TS
```

## SDWire_004 SD card flashing

**Test description**

This test aims to verify that the flashing mounted in the SDWire SD Card
procedure works correctly.

**Test setup**

1. Proceed with the
    [Test cases common documentation](#test-cases-common-documentation) section.

**Test steps**

1. Login into the TS by using the proper login and password.
1. Run in the TS terminal the following commands:

    ```bash
    sudo bmaptool copy --nobmap <RTE_image> <device_path>
    ```

    Example command:

    ```bash
    sudo bmaptool copy --nobmap core-image-minimal-orange-pi-zero-v0.7.3.wic.gz /dev/sda
    ```

**Expected result**

The output of the command should contain information that the SD Card has been
flashed with the chosen image.

Example output:

```bash
bmaptool: info: no bmap given, copy entire image to '/dev/sda'
\
bmaptool: info: synchronizing '/dev/sda'
bmaptool: info: copying time: 1m 34.2s, copying speed 11.1 MiB/sec
```

## SDWire_005 SDWire connecting to the Device Under Test

**Test description**

This test aims to verify that the connecting to the DUT procedure for the
SDWire works correctly and, after the procedure, the test device is not
manageable from the TS.

**Test setup**

1. Proceed with the
    [Test cases common documentation](#test-cases-common-documentation) section.

**Test steps**

1. Login into the TS by using the proper login and password.
1. Run in the TS terminal the following command:

    ```bash
    sudo sd-mux-ctrl --device-serial=<serial_device> --dut
    ```

1. Check the status of the connection by running the following command:

    ```bash
    sudo sd-mux-ctrl --device-serial=<serial_device> --status
    ```

**Expected result**

The output of the last command should contain information that the SDWire is
connected to the DUT.

Example output:

```bash
SD connected to: DUT
```

## SDWire_006 OS booting form card mounted in the SDWire

**Test description**

This test aims to verify that the DUT boots properly after flashing SD Card by
using SDWire.

**Test setup**

1. Proceed with the
    [Test cases common documentation](#test-cases-common-documentation) section.

**Test steps**

1. Login into the TS by using the proper login and password.
1. Power on the DUT by running the following command in the TS terminal:

    ```bash
    ./rte_ctrl -rel
    ```

1. Run the following command to get the output from the DUT:

    ```bash
    minicom -D /dev/ttyUSB0
    ```

**Expected result**

The DUT should properly boot to the `login` phrase.
