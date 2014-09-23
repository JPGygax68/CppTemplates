setlocal EnableExtensions EnableDelayedExpansion

echo.
echo Test setup: instantiating the template and building a shared library
echo.

:: Copy the template to the staging area, adapting it
echo Copying and adapting the template...
robocopy %TEMPLATE_ROOT% . /xd "_*" /xf mylibrary.hpp /xf mylibrary.cpp /S >nul
mkdir include >nul
mkdir include\nslevel1
mkdir include\nslevel1\nslevel2
sed -f ..\mylibrary.hpp.sed <"%TEMPLATE_ROOT%\include\mylibrary.hpp" >include\nslevel1\nslevel2\mylibrary.hpp
if not exist src (mkdir src)
sed -f ..\mylibrary.cpp.sed <"%TEMPLATE_ROOT%\src\mylibrary.cpp" >src\mylibrary.cpp
sed -f ..\shared\CMakeLists.sed <"%TEMPLATE_ROOT%\CMakeLists.txt" >CMakeLists.txt

:: Create and enter the out-of-source build directory
if not exist build (mkdir build >nul)
pushd build

:: Generate the build system (by running CMake)
echo Running CMake configuration and generation...
cmake -DCMAKE_INSTALL_PREFIX=%CMAKE_INSTALL_PREFIX% .. >std.out 2>err.out
if ERRORLEVEL 1 (
  echo CMake failed.
  goto failure
)
if exist err.out (type err.out & del err.out >nul)

:: Build the library
echo Building the library...
cmake --build . >std.out 2>err.out
if ERRORLEVEL 1 (
  echo Failed to build the library:
  goto failure
)

:: Check that the build run generated the expected files
:: TODO: the following checks are specific to Visual Studio
if not exist debug\MyOrg_Mylibraryd.dll (
  echo FAILED to build the shared library
  goto failure
)
if not exist debug\MyOrg_Mylibraryd.lib (
  echo FAILED to generate the import library
  goto failure
)

:end
:: Leave the build subdir
popd
exit /b 0

:failure
echo Error output:
type err.out
if exist std.out ( echo Standard output: & type std.out )
popd
exit /b 1
