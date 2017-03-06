#!/bin/bash
cd `dirname $0`/..

if [[ `pwd` =~ .*_TemplateCA.* ]]
then
        echo
        echo "ERROR: You probably don't want to run this file here."
        echo "       Clone the _TemplateCA directory and run it in there instead."
        echo
        exit 1
fi

if [ -f private/@@@CERTIFICATE_AUTHORITY_NAME@@@.root.ca.crt.pem ]
then
	echo "ERROR: Looks like this Root CA is already initialised."
	echo
	exit 1
fi

echo "#############################################################################"
echo "## Creating the Root Key"
echo "#############################################################################"
echo "##"
echo "## You're about to be asked to enter a password.  It will protect your"
echo "##      Root Key."
echo "##"
echo "## Make it very secure!  This is needed to use the Root Key for creating"
echo "##      your Intermediate CAs."
echo "##"
openssl genrsa -aes256 -out private/@@@CERTIFICATE_AUTHORITY_NAME@@@.root.ca.key.pem 4096

if [ ! $? -eq 0 ]
then
    echo
    echo "ERROR: OpenSSL command returned error.  Aborting."
    echo
    exit 1
fi

chmod 400 private/@@@CERTIFICATE_AUTHORITY_NAME@@@.root.ca.key.pem

echo
echo "#############################################################################"
echo "## Creating the Root Certificate"
echo "#############################################################################"
echo "##"
echo "## You're about to be asked for the same password you entered above so that"
echo "##     OpenSSL can use the Root Key to self-sign its own Certificate"
echo "##"
openssl req -config openssl.cnf \
      -subj "/C=GB/ST=England/L=London/O=@@@CERTIFICATE_AUTHORITY_NAME@@@ Ltd./OU=@@@CERTIFICATE_AUTHORITY_NAME@@@ Certificates/CN=@@@CERTIFICATE_AUTHORITY_NAME@@@ Root Certificate" \
      -key private/@@@CERTIFICATE_AUTHORITY_NAME@@@.root.ca.key.pem \
      -new -x509 -days 7300 -sha256 -extensions v3_ca \
      -out certs/@@@CERTIFICATE_AUTHORITY_NAME@@@.root.ca.crt.pem

if [ ! $? -eq 0 ]
then
    echo
    echo "ERROR: OpenSSL command returned error.  Aborting."
    echo
    exit 1
fi

chmod 444 certs/@@@CERTIFICATE_AUTHORITY_NAME@@@.root.ca.crt.pem

echo
echo "#############################################################################"
echo "## All Done"
echo "#############################################################################"
echo "##"
echo "## Now you probably want to go and run ./bin/02CreateIntermediate01CAKeyAndCert.sh"
echo "##"
echo
