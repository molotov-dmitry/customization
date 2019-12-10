#!/bin/bash

### Install Wi-Fi driver =======================================================

dkms add     -m rtl8812au -v 5.6.4.2
dkms build   -m rtl8812au -v 5.6.4.2
dkms install -m rtl8812au -v 5.6.4.2
