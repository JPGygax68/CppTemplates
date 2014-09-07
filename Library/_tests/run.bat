@echo off

echo.
echo ---------------------------------------
echo Running tests for "Library"...
echo.

:: Create a staging area where the template will be copied and used
echo Create a staging directory...
if exist stage (rmdir stage /s /q)
mkdir stage >nul

:: Copy and adapt the template
echo Copying and adapting the template...
robocopy ..\ .\stage\ /xd "_*" /S >nul
sed -f sed.txt <..\CMakeLists.txt >stage\CMakeLists.txt
mkdir stage\include\gpc
mkdir stage\include\gpc\fonts
move  stage\include\mylibrary.hpp stage\include\gpc\fonts\mytestlibrary.hpp >nul

:: Enter the build directory
cd stage
if not exist build (mkdir build >nul)
cd build

:: Generate the build system
echo Running CMake configuration and generation...
cmake -DCMAKE_INSTALL_PREFIX=%CMAKE_INSTALL_PREFIX% .. >nul

:: Build the library
echo Building the library...
cmake --build . >nul

:: Perform checks
set /a "PASSED=0"
set /a "FAILED=0"

:: Part 1: checks before installation

echo Checking: built package can be found in build tree (find_package)...
mkdir find_package
cd find_package
echo cmake_minimum_required(VERSION 3.0) >CMakeLists.txt
echo project(check_find_package LANGUAGES NONE) >>CMakeLists.txt
echo find_package(GPCFonts REQUIRED) >>CMakeLists.txt
cmake . >nul 2>err.out
if ERRORLEVEL 1 ( set /a "FAILED+=1" & echo. & echo TEST FAILED: & type err.out ) else (set /a "PASSED+=1")
del CMakeLists.txt >nul
cd ..

:: Install the library
cmake -DBUILD_TYPE=Debug -P cmake_install.cmake >nul

:: Part 2: checks regarding installed package

:: TODO

:: Leave the build, then the stage directory
cd ..
cd .. 

:: Print summary
if %FAILED% LEQ 0 (set STATUS=PASSED) else (set STATUS=FAILED)
echo.
echo OVERALL STATUS: %STATUS%
echo Passed checks: %PASSED%
echo Failed checks: %FAILED%

:end
