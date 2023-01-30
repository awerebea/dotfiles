#! /bin/bash

if grep -q closed /proc/acpi/button/lid/LID/state; then
    pam-auth-update --remove fprintd
else
    pam-auth-update --enable fprintd
fi
