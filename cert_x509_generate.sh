#!/bin/sh
#SPDX-License-Identifier: MIT

#set -x

# set absolute path of root app for global use - relative path from this point
# ${PWD%/*} -> one folder up / ${PWD%/*/*} -> two folders up 
# adjust script application path/folder
# configuration file will be the same main name as the shell script - but only with .conf extension

# option
option=${1}

# script parameter
root_path="${PWD%/}/tomatoe-lib/" # "${PWD%/*}/tomatoe-lib/"
main_lib="${root_path}/main_lib.sh"
app_name="${0##*/}"
app_fullname="${PWD}/${app_name}"
conf_default="$(echo "$app_fullname" | sed 's/.\{2\}$/conf/')"
conf_custom=${2:-"none"}

# header of parameter
printf "\nparameters load - $(date +%Y-%m-%d-%H-%M-%S)\n"
printf "########################################\n\n"

# load config file for default parameters
if [ -f  ${conf_default} ]; then
   printf "$0: include default parameters from ${conf_default}\n"
   . ${conf_default}
else
   printf "$0: config lib default parameters not found - exit\n"
   exit 1
fi

# load config file for custom parameters
if [ ${conf_custom} != "none" ]; then
   if [ -f  ${conf_custom} ]; then
      printf "$0: include custom parameters from ${conf_custom}\n"
      . ${conf_custom}
   else
      printf "$0: config lib custom parameters not found - exit\n"
      exit 1
   fi
else
   printf "$0: no custom file in arguments - not used\n"
fi

# test include external libs from main submodule
if [ -f  ${main_lib} ]; then
   . ${main_lib}
else
   printf "$0: main libs not found - exit.\n"
   exit 1
fi

# print main parameters
print_main_parameters

#print header
print_header "create x509 certificates"

# check min requirements of args
check_args $# 1

# main functions
main() {

   # check inputargs
   case $option in
            --test)
               log -info "test command for debugging $0"
               test_configuration
               ;;

            --create-rsa)
               load_config ${config_file}
               log -info "create x509 rsa certificate"
               check_requirements
               create_folder ${cert_location}
               openssl_x509_rsa
               ;;

            --create-ecdsa)
               load_config ${config_file}
               log -info "create ecdsa certificate"
               check_requirements
               create_folder ${cert_location}
               openssl_x509_ecdsa
               ;;

            --cert-inspect)
               load_config ${config_file}
               log -info "inspect certificate"
               check_requirements
               openssl_incpect
               ;;

            --cert-convert)
               load_config ${config_file}
               log -info "convert certifcates"
               check_requirements
               openssl_x509_convert
               ;;

            --delete)
               load_config ${config_file}
               log -info "convert certifcates"
               openssl_remove_data
               ;;

            --list-ec-curves)
               load_config ${config_file}
               log -info "ecdsa list available curves"
               check_requirements
               openssl_x509_ecdsa_curves
               ;;

            --help | --info | *)
               usage   "\-\-test:                              test command" \
                        "\-\-create-rsa (configfile):          create rsa cert" \
                        "\-\-create-ecdsa (configfile):        create ecdsa cert" \
                        "\-\-cert-inspect (configfile):        cert inspect" \
                        "\-\-cert-convert (cnfigfile):         cert convert" \
                        "\-\-list-ec-curves:                   list ec curves" \
                        "\-\-delete:                           delete cert data" \
                        "\-\-help:                             help"
                  ;;
   esac
}


# check reqirements - always local
check_requirements() {

   # check openssl
   if command -v openssl >/dev/null 2>&1 ; then
      log -info "openssl program Found"
   else
      log -info "openssl program Not Found"
      cleanup_exit ERR
   fi 

}

# call main function manually - if not need uncomment
main "$@"; exit
