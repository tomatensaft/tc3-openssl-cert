#!/bin/sh
#SPDX-License-Identifier: MIT

# set -x

#print header
printf "create certificates...\n"

#Check number of args
if [ $# -lt 1 ]; then
   printf "use at least one(1) argument\n\n"
   exit 1
fi

#Parameter/Arguments
option=$1
config_file=${2:-"./conf/cert_standard.conf"}

# main functions
main() {

   # check inputargs
   case $option in
            --test)
               log_message "test command for debugging $0"
               test_configuration
               ;;

            --create_rsa)
               load_config ${config_file}
               log_message "create x509 rsa certificate"
               check_requirements
               create_cert_folder ${CERT_LOCATION}
               openssl_x509_rsa
               ;;

            --create_ecdsa)
               load_config ${config_file}
               log_message "create ecdsa certificate"
               check_requirements
               create_cert_folder ${CERT_LOCATION}
               openssl_x509_ecdsa
               ;;

            --cert_inspect)
               load_config ${config_file}
               log_message "inspect certificate"
               check_requirements
               openssl_incpect
               ;;

            --cert_convert)
               load_config ${config_file}
               log_message "convert certifcates"
               check_requirements
               openssl_x509_convert
               ;;

            --delete)
               load_config ${config_file}
               log_message "convert certifcates"
               openssl_remove_data
               ;;

            --list_ec_curves)
               load_config ${config_file}
               log_message "ecdsa list available curves"
               check_requirements
               openssl_x509_ecdsa_curves
               ;;

            --help | --info | *)
               printf  "usage:\n \
                        test:                                        test command\n \
                        create_rsa:                                  create rsa certificates\n \
                        create_ecdsa:                                create ecdsa certificates\n \
                        cert_inspect [cert name]:                    inspect vertificates\n \
                        cert_convert [cert_name] [outputformat]:     convert certificates\n \
                        list_ec_curves:                              list ec curves\n \
                        delete:                                      delete all cert data\n \
                        help:                                        help\n\n" 
               ;;
   esac
}


# log message
# $1 message text
log_message() {

   log=${1:-"no text"}
   printf "\n$(date +%Y-%m-%d-%H-%M-%S): ${log}\n"
   printf "########################################\n"

}

# check reqirements
check_requirements() {

   # check openssl
   if command -v openssl >/dev/null 2>&1 ; then
      log_message "openssl program Found"
   else
      log_message "openssl program Not Found"
      exit 1
   fi 

}

# create cert folders
# $1 certifcation folder
create_cert_folder() {

   log_message "$0: create folder $1"
   mkdir -p $1

}

# load config file
# $1 configuration file
load_config() {

   # load parameter file
   # define parameters in configfile
   if [ -f $1 ]; then
      log_message "$0: $1 parameter file found."
      . $1
   else
      log_message "$0: $1 no parameter file found."
      exit 1
   fi

}

# inspect ssl cert
# $1 certification name
openssl_incpect() {

   # inspect TCER
   log_message "inspect certificates"
   openssl x509 -in $1 -noout -text   

}

# convet certificates
# $1 input cert
# $2 output format
openssl_x509_convert() {
   log_message "convert certificates"
}

# create x509 ecdsa cert from parameterfile
openssl_x509_ecdsa_curves() {

   log_message "ec param list curve"
   openssl ecparam -list_curves

}

# certificate with elliptic curve from parameterfile
openssl_x509_ecdsa() {

   # generate the root ca certificate and key
   log_message "generate root ca key"
   openssl ecparam -name prime256v1 -genkey -noout -out ${ROOTCA_NAME}.key

   # generate server private key
   log_message "generate server private key"
   openssl ecparam -name prime256v1 -genkey -noout -out ${SERVER_CERT_NAME}.key

   # generate server public key
   log_message "generate public client key"
   openssl ec -in ${SERVER_CERT_NAME}.key -pubout -out ${PUBLICCERT_NAME}.key

   # create self sined certificate
   log_message "generate self signed cerificate request"
   openssl req -new -x509 -key ${SERVER_CERT_NAME}.key -subj ${SERVER_CERT_ATTRIBUTES} -out ${SERVER_CERT_NAME}.pem -days ${CERT_DURATION}

   # convert pem to pfx
   log_message "export cert to pfxt"
   openssl pkcs12 -export -inkey ${SERVER_CERT_NAME}.key -in ${SERVER_CERT_NAME}.pem -out ${SERVER_CERT_NAME}.pfx

   # finished
   log_message "cert generate finished"

}


# certificate rsa - for tls/mqtt/opcua from parameterfile
openssl_x509_rsa() {

   #ca private key
   log_message "generate ca private key"
   openssl genrsa -out ${ROOTCA_NAME}.key 2048

   # generate root ca
   log_message "generate x.509 root certificate and sign"
   openssl req -x509 -new -nodes -key ${ROOTCA_NAME}.key -sha256 -subj ${ROOTCA_ATTRIBUTES} -days ${CERT_DURATION} -out ${ROOTCA_NAME}.pem

   # generate server key
   log_message "generate server private key"
   openssl genrsa -out ${SERVER_CERT_NAME}.key 2048

   # generate server csr signing request
   log_message "generate server singning request"
   openssl req -out ${SERVER_CERT_NAME}.csr -key ${SERVER_CERT_NAME}.key -subj ${SERVER_CERT_ATTRIBUTES} -new

   # sign server certificate
   log_message "sign server private certificate"
   openssl x509 -req -in ${SERVER_CERT_NAME}.csr -CA ${ROOTCA_NAME}.pem -CAkey ${ROOTCA_NAME}.key -CAcreateserial -out ${SERVER_CERT_NAME}.crt -days ${CERT_DURATION} -sha256

   # generate client key
   log_message "generate client key"
   openssl genrsa -out ${CLIENT_CERT_NAME}.key 2048

   # generate client csr signing request
   log_message "generate client singning request"
   openssl req -out ${CLIENT_CERT_NAME}.csr -key ${CLIENT_CERT_NAME}.key -subj ${CLIENT_CERT_ATTRIBUTES} -new

   # sign client certificate
   log_message "sign client private certificate"
   openssl x509 -req -in ${CLIENT_CERT_NAME}.csr -CA ${ROOTCA_NAME}.pem -CAkey ${ROOTCA_NAME}.key -CAcreateserial -out ${CLIENT_CERT_NAME}.crt -days ${CERT_DURATION} -sha256

   # finished
   log_message "cert generate finished"

}

openssl_remove_data() {
   # finished
   log_message "remove all cert data"
   rm -rf ./certdata_*
}


# test configuration
test_configuration() {

   log_message "test configuration\n"
}

# call main function manually - if not need uncomment
main "$@"; exit
