#!/bin/bash

### Install Wi-Fi driver =======================================================

dkms add     -m rtl8812au -v 5.2.20
dkms build   -m rtl8812au -v 5.2.20
dkms install -m rtl8812au -v 5.2.20
