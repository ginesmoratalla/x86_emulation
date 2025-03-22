#!/usr/bin/env bash

# Check for root privileges
if [[ "$EUID" -ne 0 ]];
  then
    echo "[x] Script must be run with root privileges"
    exit
fi

# Check if target file was provided
if [[ -z "$1" ]];
  then
    echo "[x] Target .ova file not provided as input"
    exit
  else
    echo "[✓] Target file passed: $1"
fi

OVA_FILE="$1"

# Extract ova file
mkdir ova_extracted
tar -xvf $OVA_FILE -C ova_extracted
if [[ $? -eq 0 ]];
  then
    echo "[✓] "$OVA_FILE" extracted succesfuly"
  else
    echo "[x] Failed to extract "$OVA_FILE""
    exit
fi

# Find the vdmk files
cd ova_extracted
VMDK_FILE=$(ls . | grep ".vmdk" | xargs -I {} echo {})
IFS='.' read -ra ADDR <<< "$VMDK_FILE"
qemu-img convert -f vmdk -O qcow2 "$VMDK_FILE" "${ADDR[0]}.qcow2"
if [[ $? -eq 0 ]];
  then
    echo "[✓] QEMU qcow2 image (${ADDR[0]}) created succesfully"
  else
    echo "[x] Failed to convert vmdk disk to qcow2"
    exit
fi
