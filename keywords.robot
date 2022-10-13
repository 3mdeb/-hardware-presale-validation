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

Log Out And Close Connection
    [Documentation]    Close all opened SSH and serial connections
    SSHLibrary.Close All Connections
    Telnet.Close All Connections

Serial setup
    [Documentation]    Setup serial communication via telnet. Takes host and
    ...                ser2net port as an arguments.
    [Arguments]    ${host}    ${s2n_port}
    Telnet.Open Connection    ${host}    port=${s2n_port}    newline=LF    terminal_emulation=yes    terminal_type=vt100    window_size=80x24
    Set Timeout    30
