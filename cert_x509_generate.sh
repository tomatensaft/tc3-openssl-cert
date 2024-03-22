#!/bin/sh
#SPDX-License-Identifier: MIT

#set -x

# include external libs from git module
if [ -f  ./posix-lib-utils/standard_lib.sh ] && \
   [ -f  ./posix-lib-utils/linux_lib.sh ]; then
   . ./posix-lib-utils/standard_lib.sh
   . ./posix-lib-utils/linux_lib.sh
else
   printf "$0: external libs not found - exit."
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

            --create_rsa)
               load_config ${config_file}
               log -info "create x509 rsa certificate"
               check_requirements
               create_folder ${CERT_LOCATION}
               openssl_x509_rsa
               ;;

            --create_ecdsa)
               load_config ${config_file}
               log -info "create ecdsa certificate"
               check_requirements
               create_folder ${CERT_LOCATION}
               openssl_x509_ecdsa
               ;;

            --cert_inspect)
               load_config ${config_file}
               log -info "inspect certificate"
               check_requirements
               openssl_incpect
               ;;

            --cert_convert)
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

            --list_ec_curves)
               load_config ${config_file}
               log -info "ecdsa list available curves"
               check_requirements
               openssl_x509_ecdsa_curves
               ;;

            --help | --info | *)
               usage   "\-\-test:                              test command" \
                        "\-\-create_rsa (configfile):          create rsa cert" \
                        "\-\-create_ecdsa (configfile):        create ecdsa cert" \
                        "\-\-cert_inspect (configfile):        cert inspect" \
                        "\-\-cert_convert (cnfigfile):         cert convert" \
                        "\-\-list_ec_curves:                   list ec curves" \
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

# inspect ssl cert
# $1 certification name
openssl_incpect() {

   # inspect TCER
   log -info "inspect certificates"
   openssl x509 -in $1 -noout -text   

}

# convet certificates
# $1 input cert
# $2 output format
openssl_x509_convert() {
   log -info "convert certificates"
}

# create x509 ecdsa cert from parameterfile
openssl_x509_ecdsa_curves() {

   log -info "ec param list curve"
   openssl ecparam -list_curves

}

# certificate with elliptic curve from parameterfile
openssl_x509_ecdsa() {

   # generate the root ca certificate and key
   log -info "generate root ca key"
   openssl ecparam -name prime256v1 -genkey -noout -out ${ROOTCA_NAME}.key

   # generate server private key
   log -info "generate server private key"
   openssl ecparam -name prime256v1 -genkey -noout -out ${SERVER_CERT_NAME}.key

   # generate server public key
   log -info "generate public client key"
   openssl ec -in ${SERVER_CERT_NAME}.key -pubout -out ${CLIENT_CERT_NAME}.key

   # create self sined certificate
   log -info "generate self signed cerificate request"
   openssl req -new -x509 -key ${SERVER_CERT_NAME}.key -subj ${SERVER_CERT_ATTRIBUTES} -out ${SERVER_CERT_NAME}.pem -days ${CERT_DURATION}

   # convert pem to pfx
   log -info "export cert to pfxt"
   openssl pkcs12 -export -inkey ${SERVER_CERT_NAME}.key -in ${SERVER_CERT_NAME}.pem -out ${SERVER_CERT_NAME}.pfx

   # finished
   log -info "cert generate finished"

}


# certificate rsa - for tls/mqtt/opcua from parameterfile
openssl_x509_rsa() {

   #ca private key
   log -info "generate ca private key"
   openssl genrsa -out ${ROOTCA_NAME}.key 2048

   # generate root ca
   log -info "generate x.509 root certificate and sign"
   openssl req -x509 -new -nodes -key ${ROOTCA_NAME}.key -sha256 -subj ${ROOTCA_ATTRIBUTES} -days ${CERT_DURATION} -out ${ROOTCA_NAME}.pem

   # generate server key
   log -info "generate server private key"
   openssl genrsa -out ${SERVER_CERT_NAME}.key 2048

   # generate server csr signing request
   log -info "generate server singning request"
   openssl req -out ${SERVER_CERT_NAME}.csr -key ${SERVER_CERT_NAME}.key -subj ${SERVER_CERT_ATTRIBUTES} -new

   # sign server certificate
   log -info "sign server private certificate"
   openssl x509 -req -in ${SERVER_CERT_NAME}.csr -CA ${ROOTCA_NAME}.pem -CAkey ${ROOTCA_NAME}.key -CAcreateserial -out ${SERVER_CERT_NAME}.crt -days ${CERT_DURATION} -sha256

   # generate client key
   log -info "generate client key"
   openssl genrsa -out ${CLIENT_CERT_NAME}.key 2048

   # generate client csr signing request
   log -info "generate client singning request"
   openssl req -out ${CLIENT_CERT_NAME}.csr -key ${CLIENT_CERT_NAME}.key -subj ${CLIENT_CERT_ATTRIBUTES} -new

   # sign client certificate
   log -info "sign client private certificate"
   openssl x509 -req -in ${CLIENT_CERT_NAME}.csr -CA ${ROOTCA_NAME}.pem -CAkey ${ROOTCA_NAME}.key -CAcreateserial -out ${CLIENT_CERT_NAME}.crt -days ${CERT_DURATION} -sha256

   # finished
   log -info "cert generate finished"

}

# remove all cert folders
openssl_remove_data() {

   log -info "remove all cert data"
   rm -rf ./certdata_*
}


# test configuration
test_configuration() {

   log -info "test configuration"
}

# call main function manually - if not need uncomment
main "$@"; exit
