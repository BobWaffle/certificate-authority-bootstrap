# certificate-authority-bootstrap

This project provides a template and some helper scripts to create your own Root and Intermediate Certificate Authorities.

# Quickstart

## 1) Initialise the Root and Intermediate CAs
_This is for *NIX systems._
1) Clone the repo
2) Change into the repo directory 
3) Clone the CA template
4) Change into the new CA directory
5) Initialise the Root CA
6) Initialise the Intermediate CA

**DO NOT CUT-AND-PASTE THESE COMMANDS IN ONE BLOCK**  Why?  Because you're going to be prompted for passwords etc.
 
 ```
 git clone https://github.com/BobWaffle/certificate-authority-bootstrap.git
 cd certificate-authority-bootstrap
 ./bin/bootstrap-ca.sh MyNewCA
 cd ./private/MyNewCA
 ./bin/01CreateRootCAKeyAndCert.sh
 ./bin/02CreateIntermediateCAKeyAndCert.sh
 ```

## 2) Get Signing

Now you're ready to start signing your own certificates using your intermediate authority.

```
[Still within your new Certificate Authority directory]
./bin/SignCertificateWithIntermediateCA.sh my.domain.com
```

## 3) [Optional] Trust Your Own CAs

This step allows you to add one or both of your Certificate Authorities to your device(s) on which you want to trust them.

**Why _might_ you do this?**  So you don't get prompted by your device that "The Certificate is not trusted".

**What is the danger of doing this?**  Good question!  I'm glad you asked.  **Remember:**  _Once you trust your own Certificate Authority at the operating system level, you will never see any warnings for SSL certificates that were signed by that Certificate Authority._

**Why is that dangerous?**  Imagine someone got hold of your CA files (and password) and generated an SSL certificate for www.yourbank.com.  They'd then be able to pretend to be https://www.yourbank.com and your browser wouldn't warn you.

**I don't understand** Well... perhaps you shouldn't be mucking around with Certificate Authorites.  Don't say I didn't warn you.

**OK OK - I understand the risks... what do I do?**  Exactly _what_ you do depends on your requirements (do you need to install the Root CA or is the Intermediate CA sufficient?)  One you know which you want to install, simply add the relevant certificate to your operating system's Trusted Certificates.

**I don't know if I should install the Root or Intermediate CA Cert...**
* **If you install the Root CA** then _all certificates signed by the Root CA or any of your intermediate CAs will be trusted_.  (The scripts I have provided only create a single Intermediate CA... but you could choose to make more.)
* **If you install the Intermediate CA** then _only certificates signed by the Intermediate CA will be trusted_.

**Erm... HOW do I trust a CA on my device of type X?**  Google it.
* [Install a private Certificate Authority on Android](https://www.google.co.uk/?q=install%20root%20certificate%20on%20Android)
* [Install a private Certificate Authority on iPhone](https://www.google.co.uk/?q=install%20root%20certificate%20on%20iPhone)
* [Install a private Certificate Authority on Mac](https://www.google.co.uk/?q=install%20root%20certificate%20on%20Mac)
* [Install a private Certificate Authority on Windows](https://www.google.co.uk/?q=install%20root%20certificate%20on%20Windows)
