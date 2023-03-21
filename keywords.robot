*** Keywords ***

Prepare Test Suite
    [Documentation]    Keyword prepares Test Suite by importing specific
    ...                platform configuration keywords and variables and 
    ...                preparing connection with the DUT based on used 
    ...                transmission protocol. Keyword used in all [Suite Setup] 
    ...                sections.
    ${serial_number_exists}=    Run Keyword And Return Status   Variable Should Exist    ${serial_number}
    IF    not ${serial_number_exists}    FAIL    \nDevice serial number has not been defined!
    IF    '${device}' == 'sd_wire'    Import Resource    ${CURDIR}/variables/sd-wire-variables.robot
    ...    ELSE    FAIL    \nUnknown tested platform
    Open Connection And Log In

Open Connection And Log In
    [Documentation]    Open SSH connection and login to session. Setup RteCtrl
    ...                REST API and serial connection with the Device Under Test
    SSHLibrary.Set Default Configuration    timeout=60 seconds
    SSHLibrary.Open Connection    ${stand_ip}    prompt=${test_server_prompt}
    SSHLibrary.Login    ${test_server_login}    ${test_server_password}

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
    SSHLibrary.Write    dmesg
    SSHLibrary.Read Until    ${sd_wire_recognition_string}
    ${output}=    SSHLibrary.Read Until Prompt
    Should Contain    ${output}    FT200X USB I2C
    [Return]    ${output}

SDWire Identification
    [Documentation]    Identify the connected SDWire.
    [Arguments]    ${dmesg_output}
    ${vendor_product}=    Get Lines Containing String    ${dmesg_output}    ${vendor_product_line}
    ${serial_number}=    Get Lines Containing String    ${dmesg_output}   SerialNumber:
    
    ${vendor_id}=    Fetch From Right    ${vendor_product.split()[-3]}    =
    ${product_id}=    Fetch From Right    ${vendor_product.split()[-2]}    =
    ${serial_id}=    Evaluate    "${serial_number.split()[-1]}"
    [Return]    ${vendor_id}    ${product_id}    ${serial_id}

Configure SDWire
    [Documentation]    Configure SDWire with the given parameters.
    [Arguments]    ${serial_id}    ${vendor_id}    ${product_id}
    SSHLibrary.Execute Command    sd-mux-ctrl --device-serial=${serial_id} --vendor=0x${vendor_id} --product=0x${product_id} --device-type=sd-wire --set-serial=sd-wire_${serial_number}

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
