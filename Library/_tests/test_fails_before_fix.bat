setlocal EnableExtensions EnableDelayedExpansion

echo.
echo TEST: ctest reports failure before the implementation is fixed
pushd build >nul

ctest -C Debug >log.out 2>err.out
set test_result=%ERRORLEVEL%
find /c "No test configuration" err.out >nul
if NOT ERRORLEVEL 1 (
  echo No test configuration found - project has no test!
  goto failure
)
if NOT %test_result% GEQ 1 ( 
  echo CTest does NOT report failure before implementation fix - something is wrong!
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