*** Keywords ***

Prepare Test Suite
    [Documentation]    Keyword prepares Test Suite by importing specific
    ...                platform configuration keywords and variables and 
    ...                preparing connection with the DUT based on used 
    ...                transmission protocol. Keyword used in all [Suite Setup] 
    ...                sections.
    Open Connection And Log In

Open Connection And Log In
    [Documentation]    Open SSH connection and login to session. Setup RteCtrl
    ...                REST API and serial connection with the Device Under Test
    #Check provided ip
    SSHLibrary.Set Default Configuration    timeout=60 seconds
    SSHLibrary.Open Connection    ${rte_ip}    prompt=~#
    SSHLibrary.Login    ${USERNAME}    ${PASSWORD}
    REST API Setup    RteCtrl
    Serial setup    ${rte_ip}    ${rte_s2n_port}
