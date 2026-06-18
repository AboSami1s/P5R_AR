@echo off
setlocal EnableExtensions EnableDelayedExpansion
title Persona 5 Royal Arabic Patch Remover

set "ORIGINAL_HASH=6A6925020AE6E5EDFC61F3E259C8D146C69D7D923CF4FCE61E98968A69FC4CB2"

echo Persona 5 Royal Arabic Patch Remover
echo.

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
if exist "!CPK_DIR!\EN_BACKUP.CPK" goto cpk_found
if exist "!CPK_DIR!" (
  for %%I in ("!CPK_DIR!") do (
    if /I "%%~nxI"=="EN.CPK" set "CPK_DIR=%%~dpI"
  )
)
if exist "!CPK_DIR!\EN.CPK" goto cpk_found
if exist "!CPK_DIR!\EN_BACKUP.CPK" goto cpk_found

echo EN.CPK was not found in the default Steam path.
echo.
set /p "CPK_DIR=Paste the CPK folder path, then press Enter: "
set "CPK_DIR=!CPK_DIR:"=!"
if exist "!CPK_DIR!\EN.CPK" goto cpk_found
if exist "!CPK_DIR!\EN_BACKUP.CPK" goto cpk_found
if exist "!CPK_DIR!" (
  for %%I in ("!CPK_DIR!") do (
    if /I "%%~nxI"=="EN.CPK" set "CPK_DIR=%%~dpI"
  )
)
if exist "!CPK_DIR!\EN.CPK" goto cpk_found
if exist "!CPK_DIR!\EN_BACKUP.CPK" goto cpk_found

:cpk_found

set "TARGET=!CPK_DIR!\EN.CPK"
set "BACKUP=!CPK_DIR!\EN_BACKUP.CPK"

if not exist "!BACKUP!" (
  echo Backup file was not found:
  echo !BACKUP!
  goto fail
)

call :hash "!BACKUP!" BACKUP_HASH
if /I not "!BACKUP_HASH!"=="!ORIGINAL_HASH!" (
  echo EN_BACKUP.CPK is not the supported original file.
  echo Restore or verify the game files first.
  goto fail
)

if exist "!TARGET!" (
  call :hash "!TARGET!" CURRENT_HASH
  if /I "!CURRENT_HASH!"=="!ORIGINAL_HASH!" (
    echo Original file is already restored.
    goto done
  )

  del /F /Q "!TARGET!" >nul 2>nul
  if exist "!TARGET!" (
    echo Could not remove current EN.CPK. Run this file as administrator.
    goto fail
  )
)

ren "!BACKUP!" "EN.CPK"
if errorlevel 1 (
  echo Could not restore EN_BACKUP.CPK. Run this file as administrator.
  goto fail
)

echo.
echo Arabic patch removed successfully.
echo Restored:
echo !TARGET!
goto done

:hash
set "%~2="
for /f "usebackq tokens=* delims=" %%H in (`certutil -hashfile "%~1" SHA256 ^| findstr /R /I "^[0-9A-F][0-9A-F]*$"`) do set "%~2=%%H"
exit /b 0

:fail
echo.
echo Removal did not complete.
echo.
pause
exit /b 1

:done
echo.
pause
exit /b 0
