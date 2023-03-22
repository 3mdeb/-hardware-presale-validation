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
    [Arguments]    ${host}    ${s2n_port}
    Telnet.Open Connection
    ...    ${host}
    ...    port=${s2n_port}
    ...    newline=LF
    ...    terminal_emulation=yes
    ...    terminal_type=vt100
    ...    window_size=80x24
    Set Timeout    30

SDWire Diagnosis
    [Documentation]    Check that the SDWire is properly recognized by the
    ...    dmesg command.
    SSHLibrary.Write    dmesg
    SSHLibrary.Read Until    ${sd_wire_recognition_string}
    ${output}=    SSHLibrary.Read Until Prompt
    Should Contain    ${output}    FT200X USB I2C
    RETURN    ${output}

SDWire Identification
    [Documentation]    Identify the connected SDWire.
    [Arguments]    ${dmesg_output}
    ${vendor_product}=    Get Lines Containing String    ${dmesg_output}    ${vendor_product_line}
    ${serial_number}=    Get Lines Containing String    ${dmesg_output}    SerialNumber:
    ${vendor_id}=    Fetch From Right    ${vendor_product.split()[-3].replace(',','')}    =
    ${product_id}=    Fetch From Right    ${vendor_product.split()[-2].replace(',','')}    =
    ${serial_id}=    Evaluate    "${serial_number.split()[-1]}"
    RETURN    ${vendor_id}    ${product_id}    ${serial_id}

Configure SDWire
    [Documentation]    Configure SDWire with the given parameters.
    [Arguments]    ${serial_id}    ${vendor_id}    ${product_id}
    ${parameters}=    Set Variable
    ...    --device-serial=${serial_id} --vendor=0x${vendor_id} --product=0x${product_id} --device-type=sd-wire --set-serial=sd-wire_${serial_number}
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
    ${parameters}=    Set Variable    --nobmap ${image_to_flash} /dev/sda
    SSHLibrary.Write    bmaptool copy ${parameters}
    SSHLibrary.Set Client Configuration    timeout=120s
    SSHLibrary.Read Until    synchronizing
    SSHLibrary.Set Client Configuration    timeout=60s

Change Relay State
    [Documentation]    Change the relay state on RTE.
    SSHLibrary.Execute Command    ./rte_ctrl -rel

Wait For Login Prompt In OS
    [Documentation]    Start the minicom connection and wait for the login
    ...    prompt.
    SSHLibrary.Write    minicom -D /dev/ttyUSB0
    SSHLibrary.Read Until    login:
