@echo off

setlocal EnableExtensions EnableDelayedExpansion

:: Set parameters
set LIBRARY_TYPE=header-only

:: Common setup
call "%TESTS_ROOT%\header-only\create.bat"
if ERRORLEVEL 1 (
  echo Failed to build a header-only library as the basis for the tests
  exit /b 1
)
:: Add library output dir to path
set PREV_PATH=%PATH%
set PATH=%cd%\build\Debug;%PATH%

call ..\find_package_build_tree.bat

call ..\can_use_from_executable.bat

call ..\test_fails_before_fix.bat

call ..\test_succeeds_after_fix.bat

:: Install the library
cmake -DBUILD_TYPE=Debug -P ./build/cmake_install.cmake >nul

:: Delete build tree
rmdir build /s /q

call ..\find_package_install_tree.bat

:: Common cleanup
call ..\common_cleanup.bat

:: We're done here
endlocal