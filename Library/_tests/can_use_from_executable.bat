setlocal EnableExtensions EnableDelayedExpansion

:: Check that the library can be linked with an executable
echo.
echo TEST: Can use built library in executable
mkdir can_use_from_executable >nul
robocopy "%TESTS_ROOT%\can_use_from_executable" .\can_use_from_executable /xd "_*" /S >nul
pushd can_use_from_executable

:: Configure the test executable project
cmake -DCMAKE_INSTALL_PREFIX=%CMAKE_INSTALL_PREFIX% . >nul 2>err.out
if ERRORLEVEL 1 ( 
  echo CMake failed trying to configure the project for the test executable:
  type err.out
  goto failure
)
:: Build
cmake --build . >err.out
if ERRORLEVEL 1 ( 
  echo Test executable failed to build: 
  type err.out
  goto failure
)
:: Run and check output
Debug\main.exe >out.txt
find /c "Hello, this is MyClass" out.txt >nul
if ERRORLEVEL 1 ( 
  echo Test executable failed to generate the expected output:
  type out.txt
  goto failure
)

:: Check successful
echo ..OK

:end
popd
endlocal
exit /b 0

:failure
popd
endlocal
exit /b 1