setlocal EnableExtensions EnableDelayedExpansion

echo.
echo Test setup: building a header-only library
echo.

:: Copy the template to the staging area, adapting it
echo Copying and adapting the template...
robocopy %TEMPLATE_ROOT% . /xd "_*" /S >nul
mkdir include >nul
mkdir include\nslevel1
mkdir include\nslevel1\nslevel2
sed -f ..\mylibrary.hpp.sed <"%TEMPLATE_ROOT%\include\mylibrary.hpp" >include\nslevel1\nslevel2\mylibrary.hpp
del include\mylibrary.hpp >nul
rmdir /s /q src >nul
sed -f ..\CMakeLists.sed <"%TEMPLATE_ROOT%\CMakeLists.txt" >CMakeLists.txt

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
