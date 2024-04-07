#!/bin/sh
#SPDX-License-Identifier: MIT

#set -x

# set absolute path of root app for global use - relative path from this point
# ${PWD%/*} -> one folder up / ${PWD%/*/*} -> two folders up 
SCRIPT_ROOT_PATH="${PWD}/posix-lib-utils"

echo $SCRIPT_ROOT_PATH

# test include external libs from debian submodule
if [ -f  ${SCRIPT_ROOT_PATH}/tls_lib.sh ]; then
   . ${SCRIPT_ROOT_PATH}/tls_lib.sh
else
   printf "$0: tls external libs not found - exit.\n"
   exit 1
fi

#print header
print_header "create x509 certificates"

#Check number of args
check_args $# 1

#Parameter/Arguments
option=$1
config_file=${2:-"./conf/cert_standard.conf"}

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
               create_folder ${CERT_LOCATION}
               openssl_x509_rsa
               ;;

            --create-ecdsa)
               load_config ${config_file}
               log -info "create ecdsa certificate"
               check_requirements
               create_folder ${CERT_LOCATION}
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
