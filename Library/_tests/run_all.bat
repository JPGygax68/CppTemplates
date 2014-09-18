set TESTS_ROOT=%~dp0

call :run_test shared
call :run_test header-only

exit /b

:run_test
  echo.
  echo ---------------------------------
  echo TEST SEQUENCE: %1
  echo.
  echo Creating and entering a staging directory...
  if exist stage_%1 (rmdir stage_%1 /s /q)
  mkdir stage_%1 >nul
  pushd stage_%1 >nul
  set STAGE_DIRECTORY=%cd%
  call "%TESTS_ROOT%\%1\run.bat"
  popd
  exit /b