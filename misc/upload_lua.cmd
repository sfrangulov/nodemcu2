@echo off
setlocal enabledelayedexpansion enableextensions
set LIST=
for %%x in (../*.lua) do set LIST=!LIST! %%x
cd ..
nodemcu-tool upload %LIST:~1%