Hardware Presale Validation Test Environment
=====================================

This repository aims to gather all tests related to
[supported devices](#supported-devices). Tests are written in the Robot
Framework and should be performed on the dedicated test stand.

Supported devices
-------------------
| Name of the device | Support | Test stand documentation    | Test cases description             |
|--------------------|---------|-----------------------------|------------------------------------|
| SDwire             | Full    | [Documentation][SDwire-1]   | [Test cases description][SDwire-2] |

[SDwire-1]: docs/sd-wire-test-stand.md
[SDwire-2]: docs/sd-wire-test-cases.md

Virtualenv Initialization
-------------------------

```bash
git clone git@gitlab.com:3mdeb/rte/hardware-presale-validation.git
cd open-firmware-rte
git submodule update --init --checkout
virtualenv -p $(which python3) robot-venv
source robot-venv/bin/activate
pip install -U -r requirements.txt
```

If you initialize the environment and try to run the environment again you just
need to use only this command:

```bash
source robot-venv/bin/activate
```

Testing scripts running
-------------------------

To run testing script dedicated for the currently testing platform run in
terminal with active virtual environment the following command:

```bash
robot -L TRACE -v stand_ip:$STAND_IP tested_platform:$TESTED_PLATFORM scripts/$SCRIPT
```

Where:
$STAND_IP - IP address for test stand dedicated for the tested device
$TESTED_PLATFORM - name of the tested platform
$SCRIPT - name of the script dedicated for the tested platform

For example, to run test for the SD Wire, the following command should be used:

```bash
robot -L TRACE -v stand_ip:192.168.4.217 tested_platform:sd_wire scripts/sd-wire.robot
```
