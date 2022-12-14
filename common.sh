#!/usr/bin/env bash

_encrypt () { gpg --batch --passphrase $password -c; }
_decrypt () { gpg --batch --passphrase $password -d; }
_compress () { tar -cz $1; }
_decompress () { tar -xz -C $1; }

_hash() { sha256sum | awk -F' ' '{print $1}'; }