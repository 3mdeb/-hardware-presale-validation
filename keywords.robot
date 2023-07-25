*** Keywords ***
Prepare Test Suite
    [Documentation]    Keyword prepares Test Suite by importing specific
    ...    platform configuration keywords and variables and
    ...    preparing connection with the DUT based on used
    ...    transmission protocol. Keyword used in all [Suite Setup]
    ...    sections.
    ${serial_number_exists}=    Run Keyword And Return Status    Variable Should Exist    ${serial_number}
    IF    not ${serial_number_exists}
        FAIL    \nDevice serial number has not been defined!
    END
    IF    '${device}' == 'sd_wire'
        Import Resource    ${CURDIR}/variables/sd-wire-variables.robot
    ELSE
        FAIL    \nUnknown tested platform
    END
    Setup SSH Connection

Setup SSH Connection
    [Documentation]    Try to log on crystal via SSH.
    FOR    ${INDEX}    IN RANGE    30
        TRY
            SSHLibrary.Open Connection    ${stand_ip}    prompt=${test_server_prompt}
            SSHLibrary.Login    ${test_server_login}    ${test_server_password}
            SSHLibrary.Set Client Configuration    timeout=60s
            BREAK
        EXCEPT
            Log To Console    \n${INDEX} attempt to setup connection with test stand failed.
            IF    '${INDEX}' == '30'
                FAIL    Failed to establish ssh connection
            END
            Sleep    3s
        END
    END

Log Out And Close Connection
    [Documentation]    Close all opened SSH and serial connections.
    SSHLibrary.Close All Connections
    Telnet.Close All Connections

Serial setup
    [Documentation]    Setup serial communication via telnet. Takes host and
    ...    ser2net port as an arguments.
    [Arguments]
    # We always connect to the stand, and the DUT is connected to ttyS1
    Telnet.Open Connection
    ...    ${stand_ip}
    ...    port=13541
    ...    newline=LF
    ...    terminal_emulation=yes
    ...    terminal_type=vt100
    ...    window_size=80x24
    Set Timeout    30

SDWire Diagnosis
    [Documentation]    Check that the SDWire is properly recognized by the
    ...    lsusb command.
    # Use lsusb as it shows currently connected devices, instead of the whole
    # history of connected USB devices in dmesg. The test would detect the
    # wrong FTDI serial number if SDwire would be tested in serialized mode
    # without rebooting the stand...
    ${output}=    SSHLibrary.Execute Command    lsusb
    # When SDwire is already configured, the test should not fail, but skip
    # the IDs detection and SDwire configuration programming.
    IF    '''${ftdi_string}''' in '''${output}'''
        ${configed}=    Set Variable    ${False}
    ELSE IF    '''${sd_wire_string}''' in '''${output}'''
        ${configed}=    Set Variable    ${True}
    ELSE
        Fatal Error    SD-wire not detected. Did you forget to plug the USB cable to SDWire?
    END
    RETURN    ${output}    ${configed}

SDWire Identification
    [Documentation]    Identify the connected SDWire.
    [Arguments]    ${lsusb_output}
    ${ftdi_line}=    Get Lines Containing String    ${lsusb_output}    ${ftdi_string}
    ${length}=    Get Length    ${ftdi_line}
    Should Be True    ${length} != 0
    @{words}=    Split String    ${ftdi_line}    ${SPACE}
    # Vendor ID and Product ID is right after bus, bus num, dev, dev num and ID string
    ${vendor_id}    ${product_id}=    Split String    ${words[5]}    :
    # We get the serial number from the USB device descriptor from given VID/PID
    ${output}=    SSHLibrary.Execute Command    lsusb -v -d ${words[5]}
    ${serial_number}=    Get Lines Containing String    ${output}    iSerial
    ${serial_id}=    Evaluate    "${serial_number.split()[-1]}"
    RETURN    ${vendor_id}    ${product_id}    ${serial_id}

Configure SDWire
    [Documentation]    Configure SDWire with the given parameters.
    [Arguments]    ${serial_id}    ${vendor_id}    ${product_id}
    ${parameters}=    Set Variable    --device-serial=${serial_id} --vendor=0x${vendor_id} --product=0x${product_id} --device-type=sd-wire --set-serial=sd-wire_${serial_number}
    SSHLibrary.Execute Command    sd-mux-ctrl ${parameters}

Check SDWire Configuration
    [Documentation]    Check that the SDWire is properly configured.
    ${output}=    SSHLibrary.Execute Command    sd-mux-ctrl --list
    Should Contain    ${output}    Number of FTDI devices found: 1
    Should Contain    ${output}    sd-wire_${serial_number}

Check Connection To TS
    [Documentation]    Check that the SDWire can be connected to the Test
    ...    Server.
    ${parameters}=    Set Variable    --device-serial=sd-wire_${serial_number} --ts
    SSHLibrary.Execute Command    sd-mux-ctrl ${parameters}
    ${parameters}=    Set Variable    --device-serial=sd-wire_${serial_number} --status
    ${output}=    SSHLibrary.Execute Command    sd-mux-ctrl ${parameters}
    Should Contain    ${output}    SD connected to: TS

Check Connection To DUT
    [Documentation]    Check that the SDWire can be connected to the DUT.
    ${parameters}=    Set Variable    --device-serial=sd-wire_${serial_number} --dut
    SSHLibrary.Execute Command    sd-mux-ctrl ${parameters}
    ${parameters}=    Set Variable    --device-serial=sd-wire_${serial_number} --status
    ${output}=    SSHLibrary.Execute Command    sd-mux-ctrl ${parameters}
    Should Contain    ${output}    SD connected to: DUT

Flash SD Card
    [Documentation]    Flash SD Card using bmaptool.
    SSHLibrary.File Should Exist    ${image_to_flash}
    ${parameters}=    Set Variable    
    SSHLibrary.Set Client Configuration    timeout=240s
    SSHLibrary.Execute Command    bmaptool copy --bmap ${bmap_file} ${image_to_flash} /dev/sda
    SSHLibrary.Set Client Configuration    timeout=60s

Relay Off
    [Documentation]    Change the relay state on RTE to off.
    SSHLibrary.Execute Command    echo 0 > /sys/class/gpio/gpio199/value

Relay On
    [Documentation]    Change the relay state on RTE to on.
    SSHLibrary.Execute Command    echo 1 > /sys/class/gpio/gpio199/value
    

Power DUT On And Wait For Login Prompt In OS
    [Documentation]    Start the minicom connection and wait for the login
    ...    prompt.
    Relay Off
    Serial setup
    Sleep    1s
    Relay On
    Telnet.Read Until    login:
