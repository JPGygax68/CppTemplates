setlocal EnableExtensions EnableDelayedExpansion

:: Check that find_package() is able to find the package
echo.
echo TEST: built package can be found in build tree (find_package)...

if exist find_package (rmdir /s /q find_package)
mkdir find_package
pushd find_package

echo cmake_minimum_required(VERSION 3.0) >CMakeLists.txt
echo project(check_find_package LANGUAGES NONE) >>CMakeLists.txt
echo find_package(ORGMyLibrary REQUIRED) >>CMakeLists.txt
cmake . >nul 2>err.out
if ERRORLEVEL 1 ( 
  echo find_package^(^) cannot find the library in its build tree
  goto failure
)

echo ..OK

del CMakeLists.txt >nul

:end
popd
endlocal
exit /b 0

:failure
popd
endlocal
exit /b 1