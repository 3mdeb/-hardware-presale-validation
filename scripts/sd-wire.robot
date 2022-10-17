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
    [Documentation]    This test aims to verify that the connected SDWire is
    ...                recognizable by the Test Server.
    ${output}=    SDWire Diagnosis
    Set Suite Variable    ${dmesg_output}    ${output}

SDWire_002 SDWire configure and list
    [Documentation]    This test aims to verify that the connected SDWire is
    ...                configurable and available in the list.
    ${serial_device}    ${vendor}    ${product}    SDWire Identification    ${dmesg_output}
    Configure SDWire    ${serial_device}    ${vendor}    ${product}
    Check SDWire Configuration

SDWire_003 SDWire connects to the TS
    [Documentation]    This test aims to verify that the connected SDWire can
    ...                be connected to the Test Server.
    Check Connection To TS

SDWire_004 SD card flashing
    [Documentation]    This test aims to verify that the connected SDWire can
    ...                flash  an SD card.
    Flash SD card

SDWire_005 SDWire connects to the DUT
    [Documentation]    This test aims to verify that the connected SDWire can
    ...                be connected to the DUT.
    Check Connection To DUT

SDWire_006 Booting OS from SDWire
    [Documentation]    This test aims to verify that the DUT can boot after
    ...                flashing.
    Change Relay State
    Wait For Login Prompt In OS
    Close And Open Connection
    Change Relay State
