#!/bin/bash
cd `dirname $0`/..

if [ -z "$1" ]
then
	echo
	echo "Usage: $0 NewCAName"
	echo
	echo "    e.g.  $0 MyLovelyNewCertificateAuthority"
	echo
	exit 1
fi

DEFAULT_NEW_CA_PATH="./private"

if [ ! -d "$DEFAULT_NEW_CA_PATH" ]
then
    echo
    echo "Creating path $DEFAULT_NEW_CA_PATH to store new Certificate Authorities"
    mkdir "$DEFAULT_NEW_CA_PATH"
fi

NEW_CA_PATH="$DEFAULT_NEW_CA_PATH/$1"

if [ -d "$NEW_CA_PATH" ]
then
    echo
    echo "ERROR: Directory $NEW_CA_PATH already exists."
    echo "       You should probably choose a unique name for your new Certificate Authority."
    echo
    exit 1
fi

cp -Rp _TemplateCA "$NEW_CA_PATH"

echo
echo "Created your new Certificate Authority in $NEW_CA_PATH"
echo
echo "You now probably want initialise that new CA like this:"
echo "    cd $NEW_CA_PATH"
echo "    ./bin/01CreateRootCAKeyAndCert.sh"
echo "    ./bin/02CreateIntermediateCAKeyAndCert.sh"
echo
