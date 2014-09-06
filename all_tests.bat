@echo off

:: Settings for the batch file itself
SETLOCAL EnableExtensions EnableDelayedExpansion

:: Add the special tools directory to the path
set PATH=%cd%\win32\bin;%PATH%

:: Run the test on template "Library"
cd Library\_tests
call run.bat
cd ..\..