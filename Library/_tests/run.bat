@echo off

setlocal EnableExtensions EnableDelayedExpansion

:: Create and enter a staging area where the template will be copied and used
echo Creating a staging directory...
if exist stage (rmdir stage /s /q)
mkdir stage >nul
pushd stage >nul

:: Common setup
call ..\build_shared.bat
if ERRORLEVEL 1 (
  echo Failed to build a shared library as a common basis for the tests
  exit /b 1
)
:: Add library output dir to path
set PREV_PATH=%PATH%
set PATH=%cd%\build\Debug;%PATH%

:: Run the tests operating on the library build tree
call ..\find_package_build_tree.bat
call ..\can_use_from_executable.bat
call ..\test_fails_before_fix.bat

:: Install the library
cmake -DBUILD_TYPE=Debug -P ./build/cmake_install.cmake >nul

:: Part 2: checks regarding installed package

:: TODO

:: Common cleanup
call ..\common_cleanup.bat

:: Leave and clean up staging area
popd
:: TODO...

:: We're done here
endlocal