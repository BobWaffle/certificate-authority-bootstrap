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

if [ -f private/root.ca.key.pem ]
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
openssl genrsa -aes256 -out private/root.ca.key.pem 4096
chmod 400 private/root.ca.key.pem

echo
echo "#############################################################################"
echo "## Creating the Root Certificate"
echo "#############################################################################"
echo "##"
echo "## You're about to be asked for the same password you entered above so that"
echo "##     OpenSSL can use the Root Key to self-sign its own Certificate"
echo "##"
openssl req -config openssl.cnf \
      -subj "/C=GB/ST=England/L=London/O=Anonymous Company Ltd./OU=Anonymous Company Certificates/CN=Anonymous Root Certificate" \
      -key private/root.ca.key.pem \
      -new -x509 -days 7300 -sha256 -extensions v3_ca \
      -out certs/root.ca.cert.pem
chmod 444 certs/root.ca.cert.pem

echo
echo "#############################################################################"
echo "## All Done"
echo "#############################################################################"
echo "##"
echo "## Now you probably want to go and run ./bin/02CreateIntermediateCAKeyAndCert.sh"
echo "##"
echo
