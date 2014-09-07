@echo off

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
echo Checking: built package can be found in build tree (find_package)...
mkdir find_package
cd find_package
echo cmake_minimum_required(VERSION 3.0) >CMakeLists.txt
echo project(check_find_package LANGUAGES NONE) >>CMakeLists.txt
echo find_package(GPCFontsXXX REQUIRED) >>CMakeLists.txt
cmake . >nul 2>err.out
if ERRORLEVEL 1 (
  echo.
  echo TEST FAILED:
  type err.out
)
del CMakeLists.txt >nul
cd ..

:: TODO

:: Install the library
cmake -DBUILD_TYPE=Debug -P cmake_install.cmake >nul

:: Perform checks
:: TODO

:: Leave the build, then the stage directory
cd ..
cd .. 

:end
