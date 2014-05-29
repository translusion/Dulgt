This folder contains third party code. Some is slightly modified.

### KSPasswordField, *Version 1.1.1*
The standard cocoa password field doesn't support switching between showing and hiding password.

### MIHQRCodeView, *Version 1.0.2*
There are a lot of code for encoding QR code, but this one is a thin wrapper around Core Image's own QR code generator rather than writing custom code.

The Cocoapods pod was setup for iOS and not OSX so I included the files directly.

### libscrypt, *Version 1.19*
The core algorithm used to derive passwords from memory and paper secrets. The whole program is really built around this algorithm. It was chosen because it is a memory hard cryptographic hashing function. Meaning it can't be brute forced by specialized hardware.

Project page  can be found at: http://www.lolware.net/libscrypt.html

There was no cocoapod available and it was non trivial to get to compile so I compiled it separately and included the result. Ideally we should include the source code in the future instead.
