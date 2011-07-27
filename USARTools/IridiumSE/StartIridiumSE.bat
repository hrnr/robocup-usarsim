@echo off

cd /d %~dp0
start javaw -cp Iridium.jar;jrubyscript.jar org.nist.usarui.script.IridiumSE
