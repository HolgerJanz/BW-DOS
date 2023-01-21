* CONFIG data length definition
fn_ssid_ln equ 33
fn_pass_ln equ 64
fn_host_ln equ 64
fn_ip_ln   equ 4
fn_mac_ln  equ 6
fn_firm_ln equ 15
* file name
fn_fnam_ln equ 36
* host slot
fn_hslt_ln equ 32
fn_hslt_l8 equ fn_hslt_ln*8
* device slot
fn_devs_ln equ 38
fn_devs_l8 equ fn_devs_ln*8
* WiFi Status 
WF_IDLE equ 0 ; WIFI is idle
WF_NOID equ 1 ; No SSID Available
WF_SCMP equ 2 ; Scan Completed
WF_CACT equ 3 ; Connected to network, and active
WF_CFLD equ 4 ; Last connect failed
WF_CLST equ 5 ; WiFi Connection Lost
WF_CDSC equ 6 ; WiFi explicitly disconnected
