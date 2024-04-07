# tc3-openssl-cert :closed_lock_with_key:
generate openssl certificate for differenet tc3 applications

## contents
- [contents](#contents)
- [installation](#installation)
- [usage](#usage)
- [resources](#resources)
- [tests](#tests)

## installation
* install openssl
* adjust configuration settings in `/conf` folder
* it is possible to create different config files for different certificates
* test configuration with `tc3-openssl-cert.sh --test`

## usage 
* create rsa certificate
  - `tc3-openssl-cert.sh --create-rsa`
* create ecdsa certificate
  - `tc3-openssl-cert.sh --create-ecdsa`
* create inspect certificate from configfile
  - `tc3-openssl-cert.sh --cert-inspect`
* delete all certificates
  - `tc3-openssl-cert.sh --delete`
* list ec curves
  - `tc3-openssl-cert.sh --list-ec-curves`
  - 
## resources
* debug examples - python tls client [debug](debug/)
* certicicate configurations - adjustable [conf](conf/)
* information about certificates [doc](doc/)
* twincat program [twincat](twincat/)

## tests
* not testet completly
  
---
*[v0.1.0]*
