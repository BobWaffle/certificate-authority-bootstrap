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

if [ ! -f private/root.ca.key.pem ]
then
        echo
        echo "ERROR: Looks like the Root CA is not initialised."
        echo "       You probably need to run ./bin/01CreateRootCAKeyAndCert.sh"
        echo
        exit 1
fi

if [ -f intermediate/private/intermediate.ca.key.pem ]
then
        echo "ERROR: Looks like this Intermediate CA is already initialised."
        echo
        exit 1
fi

echo "#############################################################################"
echo "## Creating the Intermediate Key"
echo "#############################################################################"
echo "##"
echo "## You're about to be asked to enter a password.  It will protect your"
echo "##      Intermediate Key."
echo "##"
echo "## Make it very secure!  This is needed to use the Intermediate Key for signing"
echo "##      all future requests using this CA."
echo "##"
echo "## It *should* be different from the password you used for the Root CA..."
echo "##      but it doesn't *have* to be different if you're just testing."
echo "##"
openssl genrsa -aes256 \
      -out intermediate/private/intermediate.ca.key.pem 4096
chmod 400 intermediate/private/intermediate.key.pem

echo
echo "#############################################################################"
echo "## Creating the Certificate Signing Request for the Intermediate Cert"
echo "#############################################################################"
echo "##"
echo "## You're about to be asked for the same password you entered above so that"
echo "##     OpenSSL can use the Intermediate Key to self-sign its own CSR"
echo "##"
echo
openssl req -config intermediate/openssl.cnf -new -sha256 \
      -subj "/C=GB/ST=England/L=London/O=Anonymous Company Ltd./OU=Anonymous Company Certificates/CN=Anonymous Intermediate Certificate" \
      -key intermediate/private/intermediate.ca.key.pem \
      -out intermediate/csr/intermediate.ca.csr.pem

echo
echo "#############################################################################"
echo "## Creating the Intermediate Cert by signing the CSR with the Root CA"
echo "#############################################################################"
echo "##"
echo "## Now you're going to be asked for the password for the Root Key so that"
echo "##     OpenSSL can use the Root Key to sign the Intermediate CSR"
echo "##"
echo
openssl ca -config openssl.cnf -extensions v3_intermediate_ca \
      -days 3650 -notext -md sha256 \
      -in intermediate/csr/intermediate.ca.csr.pem \
      -out intermediate/certs/intermediate.ca.cert.pem
chmod 444 intermediate/certs/intermediate.ca.cert.pem

echo "#############################################################################"
echo "## Creating the Full and Partial Chain Files"
echo "#############################################################################"

echo
echo "Creating full chain intermediate/certs/full-ca-chain.cert.pem"
cat intermediate/certs/intermediate.ca.cert.pem \
      certs/root.ca.cert.pem > intermediate/certs/full-ca-chain.cert.pem
chmod 444 intermediate/certs/full-ca-chain.cert.pem

echo
echo "Creating partial chain intermediate/certs/partial-ca-chain.cert.pem"
cat intermediate/certs/intermediate.ca.cert.pem > intermediate/certs/partial-ca-chain.cert.pem
chmod 444 intermediate/certs/partial-ca-chain.cert.pem

echo
echo "#############################################################################"
echo "## All Done"
echo "#############################################################################"
echo "##"
echo "## Now you can use your Intermediate CA to sign certificates:"
echo "##      e.g. ./bin/SignCertificateWithIntermediateCA.sh mydomain.com"
echo
