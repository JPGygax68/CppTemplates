setlocal EnableExtensions EnableDelayedExpansion

:: Check that find_package() is still able to find the package now the build tree is gone
echo.
echo TEST: find_package() can no longer find the library after uninstall executed and build tree removed

if exist after_uninstall (rmdir /s /q after_uninstall)
mkdir after_uninstall
pushd after_uninstall

echo cmake_minimum_required(VERSION 3.0) >CMakeLists.txt
echo project(check_find_package LANGUAGES NONE) >>CMakeLists.txt
echo find_package(ORGMyLibrary REQUIRED) >>CMakeLists.txt
cmake -DCMAKE_INSTALL_PREFIX=%CMAKE_INSTALL_PREFIX% . >nul 2>err.out
if not ERRORLEVEL 1 ( 
  echo find_package^(^) can still find the library after uninstall
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