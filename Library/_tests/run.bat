@echo off

echo Running tests for "Library"...
echo.

if exist stage (rmdir stage /s /q)
mkdir stage >nul
robocopy .. ./stage /xd "_*" /S

sed -f sed.txt <..\CMakeLists.txt >stage\CMakeLists.txt

cd stage
if not exist build (mkdir build >nul)
cd build
cmake ..
cd ..
cd .. 

:end
