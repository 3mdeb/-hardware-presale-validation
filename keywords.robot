*** Keywords ***

Prepare Test Suite
    [Documentation]    Keyword prepares Test Suite by importing specific
    ...                platform configuration keywords and variables and 
    ...                preparing connection with the DUT based on used 
    ...                transmission protocol. Keyword used in all [Suite Setup] 
    ...                sections.
    IF    '${tested_platform}' == 'sd_wire'    Import Resource    ${CURDIR}/variables/sd-wire-variables.robot
    ...    ELSE    FAIL    \nUnknown tested platform
    Open Connection And Log In

Open Connection And Log In
    [Documentation]    Open SSH connection and login to session. Setup RteCtrl
    ...                REST API and serial connection with the Device Under Test
    #Check provided ip
    SSHLibrary.Set Default Configuration    timeout=60 seconds
    Set Global Variable    ${rte_ip}    ${stand_ip}
    SSHLibrary.Open Connection    ${rte_ip}    prompt=~#
    SSHLibrary.Login    ${USERNAME}    ${PASSWORD}
    REST API Setup    RteCtrl
    # Serial setup    ${rte_ip}    ${rte_s2n_port}

Close And Open Connection
    [Documentation]    Close all opened SSH and open SSH connection again.
    SSHLibrary.Close All Connections
    Open Connection And Log In

Log Out And Close Connection
    [Documentation]    Close all opened SSH and serial connections.
    SSHLibrary.Close All Connections
    Telnet.Close All Connections

Serial setup
    [Documentation]    Setup serial communication via telnet. Takes host and
    ...                ser2net port as an arguments.
    [Arguments]    ${host}    ${s2n_port}
    Telnet.Open Connection    ${host}    port=${s2n_port}    newline=LF    terminal_emulation=yes    terminal_type=vt100    window_size=80x24
    Set Timeout    30

SDWire Diagnosis
    [Documentation]    Check that the SDWire is properly recognized by the
    ...                dmesg command.
    ${output}=    SSHLibrary.Execute Command    dmesg | grep "usb ${usb_port_number}"
    ${output}=    Fetch From Right    ${output}    new full-speed USB device
    Should Contain    ${output}    sd-wire
    [Return]    ${output}

SDWire Identification
    [Documentation]    Identify the connected SDWire.
    ${device_parameters}=    Get Lines Containing String    ${dmesg_output}   usb ${usb_port_number}: New USB device found
    ${vendor}=    Evaluate    "${device_parameters.split()[8]}"
    ${product}=    Evaluate    "${device_parameters.split()[9]}"
    ${vendor}=    Fetch From Left    ${vendor}    ,
    ${vendor}=    Fetch From Right    ${vendor}    =
    ${product}=    Fetch From Left    ${product}    ,
    ${product}=    Fetch From Right    ${product}    =
    ${serial_number}=    Get Lines Containing String    ${dmesg_output}   usb ${usb_port_number}: SerialNumber: 
    ${serial_device}=    Evaluate    "${serial_number.split()[5]}"
    [Return]    ${serial_device}    ${vendor}    ${product}

Configure SDWire
    [Documentation]    Configure SDWire with the given parameters.
    [Arguments]    ${serial_device}    ${vendor}    ${product}
    SSHLibrary.Execute Command    sd-mux-ctrl --device-serial=${serial_device} --vendor=0x${vendor} --product=0x${product} --device-type=sd-wire --set-serial=SDWIRE

Check SDWire Configuration
    [Documentation]    Check that the SDWire is properly configured.
    ${output}=    SSHLibrary.Execute Command    sd-mux-ctrl --list
    Should Contain    ${output}    Number of FTDI devices found: 1
    Should Contain    ${output}    SDWIRE

Check Connection To TS
    [Documentation]    Check that the SDWire can be connected to the Test
    ...                Server.
    SSHLibrary.Execute Command    sd-mux-ctrl --device-serial=SDWIRE --ts
    ${output}=    SSHLibrary.Execute Command    sd-mux-ctrl --device-serial=SDWIRE --status
    Should Contain    ${output}    TS

Check Connection To DUT
    [Documentation]    Check that the SDWire can be connected to the DUT.
    SSHLibrary.Execute Command    sd-mux-ctrl --device-serial=SDWIRE --dut
    ${output}=    SSHLibrary.Execute Command    sd-mux-ctrl --device-serial=SDWIRE --status
    Should Contain    ${output}    DUT

Flash SD Card
    [Documentation]    Flash SD Card using bmaptool.
    SSHLibrary.Write    bmaptool copy --nobmap ${RTE_image_name} /dev/sda
    SSHLibrary.Set Client Configuration    timeout=120s
    SSHLibrary.Read Until    synchronizing
    SSHLibrary.Set Client Configuration    timeout=60s

Change Relay State
    [Documentation]    Change the relay state on RTE.
    SSHLibrary.Execute Command    ./rte_ctrl -rel

Wait For Login Prompt In OS
    [Documentation]    Start the minicom connection and wait for the login
    ...                prompt.
    SSHLibrary.Write    minicom -D /dev/ttyUSB0
    SSHLibrary.Read Until    login:
