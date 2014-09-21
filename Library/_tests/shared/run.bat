@echo off

:: TODO: factor out common part (= majority) into common implementation
:: (in fact, defining the library type should be all that's needed)

setlocal EnableExtensions EnableDelayedExpansion

:: Common setup
call "%TESTS_ROOT%\shared\create.bat"
if ERRORLEVEL 1 (
  echo Failed to build a shared library as a common basis for the tests
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

:: Rename the build tree
ren build build.bak

call ..\find_package_install_tree.bat

:: Reinstate the build tree
ren build.bak build

:: Uninstall
cmake -DBUILD_TYPE=Debug -P ./build/cmake_uninstall.cmake >nul

call ..\can_no_longer_find_after_uninstall.bat

:: Common cleanup
call ..\common_cleanup.bat

:: We're done here
endlocal