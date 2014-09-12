setlocal EnableExtensions EnableDelayedExpansion

echo.
echo Common test setup: building a shared library
echo.

:: Copy the template to the staging area, adapting it
echo Copying and adapting the template...
robocopy ..\.. . /xd "_*" /xf mylibrary.hpp /xf mylibrary.cpp /S >nul
mkdir include >nul
mkdir include\nslevel1
mkdir include\nslevel1\nslevel2
sed -f ..\mylibrary.hpp.sed <..\..\include\mylibrary.hpp >include\nslevel1\nslevel2\mylibrary.hpp
if not exist src (mkdir src)
sed -f ..\mylibrary.cpp.sed <..\..\src\mylibrary.cpp >src\mylibrary.cpp

:: Create and enter the out-of-source build directory
if not exist build (mkdir build >nul)
pushd build

:: Generate the build system (by running CMake)
echo Running CMake configuration and generation...
cmake -DCMAKE_INSTALL_PREFIX=%CMAKE_INSTALL_PREFIX% .. >nul

:: Build the library
echo Building the library...
cmake --build . >nul 2>err.out
if ERRORLEVEL 1 (
  echo Failed to build the library:
  type err.out
  exit /b 1
)

:: Check that the build run generated the expected files
:: TODO: the following checks are specific to Visual Studio
if not exist debug\Mylibraryd.dll (
  echo FAILED to build the shared library
  exit /b 1
)
if not exist debug\Mylibraryd.lib (
  echo FAILED to generate the import library
  exit /b 1
)

endlocal

:: Leave the build subdir
popd
