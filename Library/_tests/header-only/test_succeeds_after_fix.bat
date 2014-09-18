setlocal EnableExtensions EnableDelayedExpansion

echo.
echo TEST: ctest reports success after the implementation is fixed
pushd build >nul

:: "Fix" the implementation
sed -i "s/Hello, this is MyClass/Hello, this is MyClass FIXED/" ../include/nslevel1/nslevel2/mylibrary.hpp

:: Rebuild the library and test suite
cmake --build . >std.out 2>err.out
if ERRORLEVEL 1 (
  echo Failed to rebuild the library:
  goto failure
)

:: Check again
ctest -C Debug >log.out 2>err.out
if NOT %ERRORLEVEL% EQU 0 ( 
  echo CTest still reports an error after implementation fix
  goto failure
)

:: Check successful
echo ..OK

:end
popd
endlocal
exit /b 0

:failure
echo Error message(s):
type err.out
if exist log.out (
  echo Standard output:
  type log.out
)
popd
endlocal
exit /b 1