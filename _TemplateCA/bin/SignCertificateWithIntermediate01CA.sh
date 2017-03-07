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

if [ ! -f intermediate01/private/@@@CERTIFICATE_AUTHORITY_NAME@@@.intermediate01.ca.key.pem ]
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
	echo "Usage: $0 domain [alt_domain...]"
	echo
	echo "    e.g. $0 www.mysite.com api.mysite.com images.mysite.com"
	echo
	exit 1
fi

# Grab the passed domains as subject alternative names
ALL_DOMAINS="$*"
ALTERNATES=`echo $ALL_DOMAINS | sed "s/\([^ ]*\) */DNS:\1,/g" | sed "s/\(.*\),/\1/g"`

echo "#############################################################################"
echo "## Creating the CSR for $1"
echo "#############################################################################"
openssl req \
        -reqexts SAN \
        -config <(cat ./intermediate01/openssl.cnf \
                <(printf "[SAN]\nsubjectAltName=$ALTERNATES\nbasicConstraints=CA:FALSE\nkeyUsage=nonRepudiation,digitalSignature,keyEncipherment")) \
        -newkey rsa:4096 -sha256 -nodes \
        -subj "/C=GB/ST=England/L=London/O=@@@CERTIFICATE_AUTHORITY_NAME@@@ Ltd./OU=@@@CERTIFICATE_AUTHORITY_NAME@@@ Certificates/CN=$1" \
        -out intermediate01/csr/$1.request.pem -keyout intermediate01/private/$1.key.pem

if [ ! $? -eq 0 ]
then
    echo
    echo "ERROR: OpenSSL command returned error.  Aborting."
    echo
    exit 1
fi

echo
echo "#############################################################################"
echo "Signing the certificate with the Intemediate Authority"
echo "#############################################################################"
openssl ca -config ./intermediate01/openssl.cnf \
        -out intermediate01/certs/$1.crt.pem -infiles intermediate01/csr/$1.request.pem


if [ ! $? -eq 0 ]
then
    echo
    echo "ERROR: OpenSSL command returned error.  Aborting."
    echo
    exit 1
fi

echo
echo "#############################################################################"
echo "## Creating a certificate including the full chain"
echo "#############################################################################"
cat ./intermediate01/certs/$1.crt.pem >> intermediate01/certs/$1.intermediate01.fully-chained.crt.pem
cat  ./intermediate01/certs/@@@CERTIFICATE_AUTHORITY_NAME@@@.intermediate01.full-ca-chain.crt.pem >> intermediate01/certs/$1.intermediate01.fully-chained.crt.pem

echo
echo "#############################################################################"
echo "## Creating a certificate including the partial (intermediate-only) chain"
echo "#############################################################################"
cat ./intermediate01/certs/$1.crt.pem >> intermediate01/certs/$1.intermediate01.partially-chained.crt.pem
cat  ./intermediate01/certs/@@@CERTIFICATE_AUTHORITY_NAME@@@.intermediate01.partial-ca-chain.crt.pem >> intermediate01/certs/$1.intermediate01.partially-chained.crt.pem
echo
echo "#############################################################################"
echo
echo "You will probably want some or all of these files:"
echo "     intermediate01/private/$1.key.pem"
echo "     intermediate01/certs/$1.crt.pem"
echo "     intermediate01/certs/$1.fully-chained.crt.pem"
echo "     intermediate01/certs/$1.partially-chained.crt.pem"
echo "     intermediate01/certs/@@@CERTIFICATE_AUTHORITY_NAME@@@.intermediate01.full-ca-chain.crt.pem"
echo "     intermediate01/certs/@@@CERTIFICATE_AUTHORITY_NAME@@@.intermediate01.partial-ca-chain.crt.pem"
echo
echo "In Apache (and assuming your clients already trust the Root CA - hence not requiring"
echo "     the fully-signed chain) your config might look like this:"
echo
echo "      SSLEngine On"
echo "      SSLCertificateChainFile /path/to/@@@CERTIFICATE_AUTHORITY_NAME@@@.intermediate01.partial-ca-chain.crt.pem"
echo "      SSLCertificateFile /path/to/$1.crt.pem"
echo "      SSLCertificateKeyFile /path/to/$1.key.pem"
echo
echo "In Apache, if you needed the full ssl chain, your config might look like this:"
echo
echo "      SSLEngine On"
echo "      SSLCertificateChainFile /path/to/@@@CERTIFICATE_AUTHORITY_NAME@@@.intermediate01.full-ca-chain.crt.pem"
echo "      SSLCertificateFile /path/to/$1.crt.pem"
echo "      SSLCertificateKeyFile /path/to/$1.key.pem"
echo
echo "In nginx, if you needed the full ssl chain, your config might look like this:"
echo
echo "      ssl on;"
echo "      ssl_certificate_key /path/to/$1.key.pem;"
echo "      ssl_certificate /path/to/$1.fully-chained.crt.pem;"
echo
