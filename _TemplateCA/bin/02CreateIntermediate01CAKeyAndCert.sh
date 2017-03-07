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

if [ ! -f private/@@@CERTIFICATE_AUTHORITY_NAME@@@.root.ca.key.pem ]
then
        echo
        echo "ERROR: Looks like the Root CA is not initialised."
        echo "       You probably need to run ./bin/01CreateRootCAKeyAndCert.sh"
        echo
        exit 1
fi

if [ -f intermediate01/certs/@@@CERTIFICATE_AUTHORITY_NAME@@@.intermediate01.ca.crt.pem ]
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
      -out intermediate01/private/@@@CERTIFICATE_AUTHORITY_NAME@@@.intermediate01.ca.key.pem 4096

if [ ! $? -eq 0 ]
then
    echo
    echo "ERROR: OpenSSL command returned error.  Aborting."
    echo
    exit 1
fi

chmod 400 intermediate01/private/@@@CERTIFICATE_AUTHORITY_NAME@@@.intermediate01.key.pem

echo
echo "#############################################################################"
echo "## Creating the Certificate Signing Request for the Intermediate Cert"
echo "#############################################################################"
echo "##"
echo "## You're about to be asked for the same password you entered above so that"
echo "##     OpenSSL can use the Intermediate Key to self-sign its own CSR"
echo "##"
echo
openssl req -config intermediate01/openssl.cnf -new -sha256 \
      -subj "/C=GB/ST=England/L=London/O=@@@CERTIFICATE_AUTHORITY_NAME@@@ Ltd./OU=@@@CERTIFICATE_AUTHORITY_NAME@@@ Certificates/CN=@@@CERTIFICATE_AUTHORITY_NAME@@@ Intermediate01 Certificate" \
      -key intermediate01/private/@@@CERTIFICATE_AUTHORITY_NAME@@@.intermediate01.ca.key.pem \
      -out intermediate01/csr/@@@CERTIFICATE_AUTHORITY_NAME@@@.intermediate01.ca.csr.pem

if [ ! $? -eq 0 ]
then
    echo
    echo "ERROR: OpenSSL command returned error.  Aborting."
    echo
    exit 1
fi

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
      -in intermediate01/csr/@@@CERTIFICATE_AUTHORITY_NAME@@@.intermediate01.ca.csr.pem \
      -out intermediate01/certs/@@@CERTIFICATE_AUTHORITY_NAME@@@.intermediate01.ca.crt.pem

if [ ! $? -eq 0 ]
then
    echo
    echo "ERROR: OpenSSL command returned error.  Aborting."
    echo
    exit 1
fi
chmod 444 intermediate01/certs/@@@CERTIFICATE_AUTHORITY_NAME@@@.intermediate01.ca.crt.pem

echo "#############################################################################"
echo "## Creating the Full and Partial Chain Files"
echo "#############################################################################"

echo
echo "Creating full chain intermediate01/certs/@@@CERTIFICATE_AUTHORITY_NAME@@@.intermediate01.full-ca-chain.crt.pem"
cat intermediate01/certs/@@@CERTIFICATE_AUTHORITY_NAME@@@.intermediate01.ca.crt.pem \
      certs/@@@CERTIFICATE_AUTHORITY_NAME@@@.root.ca.crt.pem > intermediate01/certs/@@@CERTIFICATE_AUTHORITY_NAME@@@.intermediate01.full-ca-chain.crt.pem
chmod 444 intermediate01/certs/@@@CERTIFICATE_AUTHORITY_NAME@@@.intermediate01.full-ca-chain.crt.pem

echo
echo "Creating partial chain intermediate01/certs/@@@CERTIFICATE_AUTHORITY_NAME@@@.intermediate01.partial-ca-chain.crt.pem"
cat intermediate01/certs/@@@CERTIFICATE_AUTHORITY_NAME@@@.intermediate01.ca.crt.pem > intermediate01/certs/@@@CERTIFICATE_AUTHORITY_NAME@@@.intermediate01.partial-ca-chain.crt.pem
chmod 444 intermediate01/certs/@@@CERTIFICATE_AUTHORITY_NAME@@@.intermediate01.partial-ca-chain.crt.pem

echo
echo "#############################################################################"
echo "## All Done"
echo "#############################################################################"
echo "##"
echo "## Now you can use your Intermediate CA to sign certificates:"
echo "##      ./bin/SignCertificateWithIntermediate01CA.sh"
echo
