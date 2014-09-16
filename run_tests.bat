@echo off

:: Settings for the batch file itself
setlocal EnableExtensions EnableDelayedExpansion

:: Add the special tools directory to the path
set PATH=%cd%\win32\bin;%PATH%

:: We define an install directory to be used for testing
set CMAKE_INSTALL_PREFIX=%cd%\install
if exist %CMAKE_INSTALL_PREFIX% (rmdir /s /q %CMAKE_INSTALL_PREFIX%)
mkdir %CMAKE_INSTALL_PREFIX% >nul

:: Variables use throughout the tests
set ROOT=%cd%\

:: Template "Library"

pushd Library >nul
set TEMPLATE_ROOT=%cd%

pushd _tests\header-only >nul
call run.bat
popd

goto end

echo.
echo ------------------------------------
echo.

pushd _tests\shared_library >nul
call run.bat
popd

:end
popd