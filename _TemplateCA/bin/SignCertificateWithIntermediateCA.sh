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

if [ ! -f intermediate/private/intermediate.ca.key.pem ]
then
	echo
        echo "ERROR: Looks like the Intermediate CA is not initialised."
        echo "       You probably need to run ./bin/02CreateIntermediateCAKeyAndCert.sh"
        echo
        exit 1
fi

if [ -z "$1" ]
then
	echo
	echo "Usage: $0 domainname.com"
	echo
	exit 1
fi


echo "#############################################################################"
echo "## Creating the CSR for $1"
echo "#############################################################################"
openssl req -config ./intermediate/openssl.cnf -newkey rsa:4096 -sha256 -nodes -subj "/C=GB/ST=England/L=London/O=Anonymous Company Ltd./OU=Anonymous Company Certificates/CN=$1" -out intermediate/csr/$1.request.pem -keyout intermediate/private/$1.key.pem
echo
echo "#############################################################################"
echo "Signing the certificate with the Intemediate Authority"
echo "#############################################################################"
openssl ca -config ./intermediate/openssl.cnf -out intermediate/certs/$1.crt.pem -infiles intermediate/csr/$1.request.pem

echo
echo "#############################################################################"
echo "## Creating a certificate including the full chain"
echo "#############################################################################"
cat ./intermediate/certs/$1.crt.pem >> intermediate/certs/$1.fully-chained.crt.pem
cat  ./intermediate/certs/full-ca-chain.cert.pem >> intermediate/certs/$1.fully-chained.crt.pem

echo
echo "#############################################################################"
echo "## Creating a certificate including the partial (intermediate-only) chain"
echo "#############################################################################"
cat ./intermediate/certs/$1.crt.pem >> intermediate/certs/$1.partially-chained.crt.pem
cat  ./intermediate/certs/partial-ca-chain.cert.pem >> intermediate/certs/$1.partially-chained.crt.pem
echo
echo "#############################################################################"
echo
echo "You will probably want some or all of these files:"
echo "     intermediate/private/$1.key.pem\t\t<- You definitely want this"
echo "     intermediate/certs/$1.crt.pem"
echo "     intermediate/certs/$1.fully.chained.crt.pem"
echo "     intermediate/certs/full-ca-chain.cert.pem"
echo "     intermediate/certs/$1.partially.chained.crt.pem"
echo "     intermediate/certs/partial-ca-chain.cert.pem"
echo
echo
echo "In Apache (and assuming your clients already trust the Root CA - hence not requiring"
echo "     the fully-signed chain) your config might look like this:"
echo
echo "      SSLEngine On"
echo "      SSLCertificateFile {SSL_PATH}$1.partially.chained.crt.pem"
echo "      SSLCertificateKeyFile {SSL_PATH}$1.key.pem"
echo
echo "Or, equivalently:"
echo
echo "      SSLEngine On"
echo "      SSLCertificateChainFile partial-ca-chain.cert.pem"
echo "      SSLCertificateFile {SSL_PATH}$1.crt.pem"
echo "      SSLCertificateKeyFile {SSL_PATH}$1.key.pem"
