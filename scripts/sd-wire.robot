*** Settings ***
Library     SSHLibrary    timeout=90 seconds
Library     Telnet    timeout=20 seconds    connection_timeout=120 seconds
Library     Process
Library     OperatingSystem
Library     String
Library     RequestsLibrary
Library     Collections

Suite Setup       Run Keyword    Prepare Test Suite
Suite Teardown    Run Keyword    Log Out And Close Connection

Resource    ../rtectrl-rest-api/rtectrl.robot
Resource    ../keywords.robot

*** Test Cases ***

SDWire_001 Device recognition
    [Documentation]    This test aims to verify that the connected SD wire is
    ...                recognizable by the Test Server.
    # ${output}=    SSHLibrary.Execute Command    dmesg | grep usb X-X.X
    ${output}=    SSHLibrary.Execute Command    dmesg
    Should Contain    ${output}    FTDI
    Set Global Variable    ${dmesg_output}    ${output}

SDWire_002 SD-wire configure and list
    [Documentation]    This test aims to verify that the connected SD wire is
    ...                configurable and available in the list.
    ${temp}=    Get Lines Containing String    ${dmesg_output}   usb X-X.X: New USB device found
    ${vendor}=    Evaluate    ${temp.split()[7]}
    ${product}=    Evaluate    ${temp.split()[8]}
    ${vendor}=    Fetch From Left    ${vendor}    ,
    ${vendor}=    Fetch From Right    ${vendor}    =
    ${product}=    Fetch From Left    ${product}    ,
    ${product}=    Fetch From Right    ${product}    =
    ${temp}=    Get Lines Containing String    ${dmesg_output}   usb X-X.X: SerialNumber: 
    ${serial_device}=    Evaluate    ${temp.split()[4]}
    SSHLibrary.Execute Command    sd-mux-ctrl --device-serial=${serial_device} --vendor=0x${vendor} --product=0x${product} --device-type=sd-wire --set-serial=SDWIRE
    ${output}=    SSHLibrary.Execute Command    sudo sd-mux-ctrl --list
    Should Contain    ${output}    Number of FTDI devices found: 1
    Should Contain    ${output}    SDWIRE

SDWire_003 SD-wire connects to the TS
    [Documentation]    This test aims to verify that the connected SD wire can
    ...                be connected to the Test Server.
    ${output}=    SSHLibrary.Execute Command    sudo sd-mux-ctrl --device-serial=sd-wire_11 --ts
    Should Contain    ${output}    ???

SDWire_004 SD card flashing
    [Documentation]    This test aims to verify that the connected SD wire can
    ...                flash SD card.
    ${output}=    SSHLibrary.Execute Command    sudo bmaptool copy --bmap bmap_file RTE_image /dev/sdb
    Should Contain    ${output}    ???

SDWire_005 SD-wire connects to the DUT
    [Documentation]    This test aims to verify that the connected SD wire can
    ...                be connected to the DUT.
    ${output}=    SSHLibrary.Execute Command    sudo sd-mux-ctrl --device-serial=sd-wire_11 --dut
    Should Contain    ${output}    ???

SDWire_006 Booting OS from SD-wire
    [Documentation]    This test aims to verify that the DUT can boot after
    ...                flashing.
    RteCtrl Power On
    Telnet.Read Until    login
