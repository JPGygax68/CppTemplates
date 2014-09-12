@echo off

:: Settings for the batch file itself
setlocal EnableExtensions EnableDelayedExpansion

:: Add the special tools directory to the path
set PATH=%cd%\win32\bin;%PATH%

:: We define an install directory to be used for testing
set CMAKE_INSTALL_PREFIX=%cd%\install
if exist %CMAKE_INSTALL_PREFIX% (rmdir /s /q %CMAKE_INSTALL_PREFIX%)
mkdir %CMAKE_INSTALL_PREFIX% >nul

:: Run the test on template "Library"
pushd Library\_tests
call run.bat
popd