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

SDWire_001 SD wire is recognizable
    [Documentation]    This test aims to verify that the connected SD wire is
    ...                recognizable by the Test Server
    No Operation
