@echo off

echo Running tests for "Library"...
echo.

:: Create a staging area where the template will be copied and used
if exist stage (rmdir stage /s /q)
mkdir stage >nul

:: Copy and adapt the template
robocopy ..\ .\stage\ /xd "_*" /S >nul
sed -f sed.txt <..\CMakeLists.txt >stage\CMakeLists.txt
mkdir stage\include\gpc
mkdir stage\include\gpc\fonts
move  stage\include\mylibrary.hpp stage\include\gpc\fonts\mytestlibrary.hpp

:: Enter the build directory
cd stage
if not exist build (mkdir build >nul)
cd build

:: Generate the build system
cmake -DCMAKE_INSTALL_PREFIX=%CMAKE_INSTALL_PREFIX% ..

:: Build the library
cmake --build .

:: Perform checks
:: TODO

:: Install the library
cmake -DBUILD_TYPE=Debug -P cmake_install.cmake

:: Perform checks
:: TODO

:: Leave the build, then the stage directory
cd ..
cd .. 

:end
