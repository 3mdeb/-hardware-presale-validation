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

SDWire_001 SDWire recognition
    [Documentation]    This test aims to verify that the connected SDWire is
    ...                recognizable by the Test Server.
    ${output}=    SDWire Diagnosis
    Set Suite Variable    ${dmesg_output}    ${output}

SDWire_002 SDWire configuration and reading
    [Documentation]    This test aims to verify that the configuration
    ...                procedure for the SDWire works correctly and, after the
    ...                procedure, the test device is readable.
    ${serial_device}    ${vendor}    ${product}    SDWire Identification    ${dmesg_output}
    Configure SDWire    ${serial_device}    ${vendor}    ${product}
    Check SDWire Configuration

SDWire_003 SDWire connecting to the Test Server
    [Documentation]    This test aims to verify that the connecting to the TS
    ...                procedure for the SDWire works correctly and, after the
    ...                procedure, the test device is manageable from the TS.
    Check Connection To TS

SDWire_004 SD card flashing
    [Documentation]    This test aims to verify that the flashing mounted in
    ...                the SDWire SD Card procedure works correctly.
    Flash SD card

SDWire_005 SDWire connecting to the Device Under Test
    [Documentation]    This test aims to verify that the connecting to the DUT
    ...                procedure for the SDWire works correctly and, after the
    ...                procedure, the test device is not manageable from the TS.
    Check Connection To DUT

SDWire_006 OS booting form card mounted in the SDWire
    [Documentation]   This test aims to verify that the DUT boots properly
    ...               after flashing SD Card by using SDWire.
    Change Relay State
    Wait For Login Prompt In OS
    Close And Open Connection
    Change Relay State
