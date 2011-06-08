@echo off
title Making...
echo Making Pass 1
Binaries\UDK.exe make -all > nul
echo Making Pass 2
Binaries\UDK.exe make -all
pause
run