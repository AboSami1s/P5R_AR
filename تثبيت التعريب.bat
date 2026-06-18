@echo off
setlocal EnableExtensions EnableDelayedExpansion
title Persona 5 Royal Arabic Patch

set "SCRIPT_DIR=%~dp0"
set "DATA_DIR=%SCRIPT_DIR%_data"
set "PATCH=%DATA_DIR%\P5R_AR.hdiff"
set "PATCHER=%DATA_DIR%\hpatchz.exe"
set "ORIGINAL_HASH=6A6925020AE6E5EDFC61F3E259C8D146C69D7D923CF4FCE61E98968A69FC4CB2"
set "ARABIC_HASH=865D4DE6253C799D2DCCC728091AEB769B91A5A0351AFED6887778A2C09B48C7"

echo Persona 5 Royal Arabic Patch
echo.

if not exist "!PATCH!" (
  echo Missing patch file:
  echo !PATCH!
  goto fail
)

if not exist "!PATCHER!" (
  echo Missing patch tool:
  echo !PATCHER!
  goto fail
)

set "CPK_DIR=%ProgramFiles(x86)%\Steam\steamapps\common\P5R\CPK"
set "ARG=%~1"
if defined ARG (
  if exist "!ARG!\EN.CPK" (
    set "CPK_DIR=!ARG!"
  ) else (
    for %%I in ("!ARG!") do set "CPK_DIR=%%~dpI"
  )
)

:check_cpk
if exist "!CPK_DIR!\EN.CPK" goto cpk_found
if exist "!CPK_DIR!" (
  for %%I in ("!CPK_DIR!") do (
    if /I "%%~nxI"=="EN.CPK" set "CPK_DIR=%%~dpI"
  )
)
if exist "!CPK_DIR!\EN.CPK" goto cpk_found

echo EN.CPK was not found in the default Steam path.
echo.
set /p "CPK_DIR=Paste the CPK folder path, then press Enter: "
set "CPK_DIR=!CPK_DIR:"=!"
if exist "!CPK_DIR!\EN.CPK" goto cpk_found
if exist "!CPK_DIR!" (
  for %%I in ("!CPK_DIR!") do (
    if /I "%%~nxI"=="EN.CPK" set "CPK_DIR=%%~dpI"
  )
)
if exist "!CPK_DIR!\EN.CPK" goto cpk_found

echo.
echo EN.CPK was not found:
echo !CPK_DIR!\EN.CPK
goto fail

:cpk_found

set "TARGET=!CPK_DIR!\EN.CPK"
set "BACKUP=!CPK_DIR!\EN_BACKUP.CPK"
set "TEMP_FILE=!CPK_DIR!\EN_ARABIC_TMP.CPK"

call :hash "!TARGET!" CURRENT_HASH
if /I "!CURRENT_HASH!"=="!ARABIC_HASH!" (
  echo Arabic patch is already installed.
  goto done
)

set "SOURCE=!TARGET!"
if /I not "!CURRENT_HASH!"=="!ORIGINAL_HASH!" (
  if exist "!BACKUP!" (
    call :hash "!BACKUP!" BACKUP_HASH
    if /I "!BACKUP_HASH!"=="!ORIGINAL_HASH!" (
      set "SOURCE=!BACKUP!"
    ) else (
      echo This EN.CPK is not the supported original file.
      echo Restore or verify the game files first.
      goto fail
    )
  ) else (
    echo This EN.CPK is not the supported original file.
    echo Restore or verify the game files first.
    goto fail
  )
)

if not exist "!BACKUP!" (
  echo Creating backup...
  copy /Y "!TARGET!" "!BACKUP!" >nul
  if errorlevel 1 (
    echo Could not create backup. Run this file as administrator.
    goto fail
  )
)

echo Applying patch...
del /F /Q "!TEMP_FILE!" >nul 2>nul
"!PATCHER!" -f "!SOURCE!" "!PATCH!" "!TEMP_FILE!"
if errorlevel 1 (
  del /F /Q "!TEMP_FILE!" >nul 2>nul
  echo Patch failed.
  goto fail
)

call :hash "!TEMP_FILE!" NEW_HASH
if /I not "!NEW_HASH!"=="!ARABIC_HASH!" (
  del /F /Q "!TEMP_FILE!" >nul 2>nul
  echo Patch verification failed.
  goto fail
)

copy /Y "!TEMP_FILE!" "!TARGET!" >nul
if errorlevel 1 (
  del /F /Q "!TEMP_FILE!" >nul 2>nul
  echo Could not replace EN.CPK. Run this file as administrator.
  goto fail
)

del /F /Q "!TEMP_FILE!" >nul 2>nul
echo.
echo Arabic patch installed successfully.
echo Backup:
echo !BACKUP!
goto done

:hash
set "%~2="
for /f "usebackq tokens=* delims=" %%H in (`certutil -hashfile "%~1" SHA256 ^| findstr /R /I "^[0-9A-F][0-9A-F]*$"`) do set "%~2=%%H"
exit /b 0

:fail
echo.
echo Installation did not complete.
echo.
pause
exit /b 1

:done
echo.
pause
exit /b 0
