#!/bin/bash
# ALIAS_template.sh define alias command system for Oracle DBA quarterly patching
# undefine all alias
cat /home/oracle/11204/ALIAS_PSU.ksh

. /home/oracle/11204/PATH.ksh
#######################################################################
# Get 11204.zip code set and run define code alias query defined result
#######################################################################
alias get11204='. /home/oracle/get11204.sh'  # get code zip and unzip
alias ZZZZ='. /home/oracle/11204/ALIAS_PSU.ksh'  # source hotkey definition
alias QQQQ='alias | egrep "^Op|^OPATCH|^D0|^U0|^APS|PSUGET"' # Check defined keys
alias AAAA='cat /home/oracle/11204/ALIAS_PSU.ksh' # show hotkey define code
#######################################################################
# Navigate and list 11204 code and installation directory
#######################################################################
alias cd11204='cd /home/oracle/11204' # go to 11204 patch code directory
alias ls11204='ls -l /home/oracle/11204' # list 11204 patch code directory
alias cd11204l='cd /home/oracle/11204_log' # go to 11204 binary installation log directory 
alias ls11204l='ls -lt /home/oracle/11204_log' # list 11204 binary installation log directory 
alias cd11204i='cd /u01/install/11204' # go to 11204 binary installation directory 
alias ls11204i='ls -l /u01/install/11204' # list binary installation directory
#######################################################################
# Download database release and PSU binary and OS pre-requisites check
#######################################################################
alias PSUGET='prun.ksh get_psu_zip # Get PSU zip file from standard location'
alias HCVE='./rda.sh -T hcve'
#######################################################################
# Upgrade and maintain Opatch
#######################################################################
alias OPATCHL='prun.ksh OPATCHL # List OPatch zip file content'
alias OPATCHI='prun_log.ksh OPATCHI # Install OPatch binary using unzip'
#######################################################################
# Patch binary installation DB PSU and OJVM PSU
#######################################################################
alias Opa='prun_log.ksh opa # Apply opatch binary logging result'
alias Opc='prun.ksh opc # Check conflict for opatch binary'
alias Opl='prun.ksh opl # List install patch'
alias Opld='prun.ksh opld # List install patch in detail'
alias Opr='prun.ksh opr # Opatch rollback syntax sample'
#######################################################################
# Database PSU patching up time steps 
#######################################################################
alias U000='prun.ksh create_java_props' 
alias U010='prun.ksh setup_flashback'
alias U900='echo report_before_patch_downtime; prun_log.ksh report_before_patch_downtime'
alias U999='prun_log.ksh backup_before_patch_downtime'
#######################################################################
# Database PSU patching down time steps 
#######################################################################
alias D000='prun_log.ksh prompt_shutdown_db'
alias D010='prun_log.ksh move_DBS_home'
alias D020='prun_log.ksh run_PSU_DB_11_catbundle'
