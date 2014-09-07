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
sed -f CMakeLists.sed <..\CMakeLists.txt >stage\CMakeLists.txt
mkdir stage\include\nslevel1
mkdir stage\include\nslevel1\nslevel2
move  stage\include\mylibrary.hpp stage\include\nslevel1\nslevel2\ >nul

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

:: TODO ? There may or may not be a need to perform checks in the build 
:: (binary) directory itself

:: Leave the build subdir
cd ..

:: Perform checks
set /a "PASSED=0"
set /a "FAILED=0"

:: Part 1: checks before installation

echo Checking: built package can be found in build tree (find_package)...
if exist check (rmdir /s /q check)
mkdir check
cd check
echo cmake_minimum_required(VERSION 3.0) >CMakeLists.txt
echo project(check_find_package LANGUAGES NONE) >>CMakeLists.txt
echo find_package(ORGMyLibrary REQUIRED) >>CMakeLists.txt
cmake . >nul 2>err.out
if ERRORLEVEL 1 ( set /a "FAILED+=1" & echo. & echo TEST FAILED: & type err.out ) else (set /a "PASSED+=1")
del CMakeLists.txt >nul
cd ..

::echo Can use built library in executable
mkdir _link_with_exe >nul
robocopy ..\link_with_exe\ .\_link_with_exe /xd "_*" /S >nul
cd _link_with_exe
:: TODO
cd ..

:: Install the library
cmake -DBUILD_TYPE=Debug -P ./build/cmake_install.cmake >nul

:: Part 2: checks regarding installed package

:: TODO

:: Leave the staging directory
cd ..

:: Print summary
if %FAILED% LEQ 0 (set STATUS=PASSED) else (set STATUS=FAILED)
echo.
echo OVERALL STATUS: %STATUS%
echo Passed checks: %PASSED%
echo Failed checks: %FAILED%

:end
