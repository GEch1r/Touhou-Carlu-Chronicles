@echo off
setlocal EnableExtensions DisableDelayedExpansion

rem Run from the directory containing this script.
pushd "%~dp0" >nul

rem Prefer a local executable; otherwise use the one on PATH.
set "PACKWIZ=%~dp0packwiz.exe"
if not exist "%PACKWIZ%" set "PACKWIZ=packwiz.exe"
where "%PACKWIZ%" >nul 2>&1
if errorlevel 1 (
    echo [ERROR] packwiz.exe was not found next to this script or on PATH.
    echo Install Packwiz or place packwiz.exe in this directory.
    popd
    pause
    exit /b 1
)

rem Pass command-line arguments straight through.
rem Examples: packwiz.bat list / packwiz.bat refresh
if not "%~1"=="" (
    "%PACKWIZ%" %*
    set "EXITCODE=%ERRORLEVEL%"
    popd
    exit /b %EXITCODE%
)

:menu
cls
echo ========================================
echo       Touhou Carlu Chronicles
echo             Packwiz Quick Menu
echo ========================================
echo.
echo [1] Add mod from Modrinth
echo [2] Add mod from CurseForge
echo [3] Add file from direct URL
echo [4] List pack files
echo [5] Refresh index
echo [6] Update all files
echo [7] Start local server
echo [8] Export Modrinth .mrpack
echo [9] Export CurseForge .zip
echo [A] Enter a custom Packwiz command
echo [Q] Quit
echo.
choice /C 123456789AQ /N /M "Select: "

if errorlevel 11 goto done
if errorlevel 10 goto custom
if errorlevel 9 goto export_cf
if errorlevel 8 goto export_mr
if errorlevel 7 goto serve
if errorlevel 6 goto update
if errorlevel 5 goto refresh
if errorlevel 4 goto list
if errorlevel 3 goto add_url
if errorlevel 2 goto add_cf
if errorlevel 1 goto add_mr
goto menu

:add_mr
set "TARGET="
set /p "TARGET=Modrinth URL, project ID, slug, or search term: "
if not defined TARGET goto menu
"%PACKWIZ%" modrinth add "%TARGET%"
goto after_command

:add_cf
set "TARGET="
set /p "TARGET=CurseForge URL, project ID, slug, or search term: "
if not defined TARGET goto menu
"%PACKWIZ%" curseforge add "%TARGET%"
goto after_command

:add_url
set "NAME="
set /p "NAME=File name: "
if not defined NAME goto menu
set "URL="
set /p "URL=Direct download URL: "
if not defined URL goto menu
"%PACKWIZ%" url add "%NAME%" "%URL%"
goto after_command

:list
"%PACKWIZ%" list -v
goto after_command

:refresh
"%PACKWIZ%" refresh
goto after_command

:update
"%PACKWIZ%" update --all
goto after_command

:serve
echo Local server running. Press Ctrl+C to stop it.
"%PACKWIZ%" serve
goto done

:export_mr
set "OUTPUT="
set /p "OUTPUT=Output filename (press Enter for default): "
if defined OUTPUT (
    "%PACKWIZ%" modrinth export -o "%OUTPUT%"
) else (
    "%PACKWIZ%" modrinth export
)
goto after_command

:export_cf
set "OUTPUT="
set /p "OUTPUT=Output filename (press Enter for default): "
if defined OUTPUT (
    "%PACKWIZ%" curseforge export -o "%OUTPUT%"
) else (
    "%PACKWIZ%" curseforge export
)
goto after_command

:custom
set "ARGS="
set /p "ARGS=packwiz "
if defined ARGS "%PACKWIZ%" %ARGS%
goto after_command

:after_command
echo.
set "EXITCODE=%ERRORLEVEL%"
if not "%EXITCODE%"=="0" (
    echo [FAILED] Command failed with exit code: %EXITCODE%
) else (
    echo [OK] Command completed.
)
pause
goto menu

:done
popd
endlocal
exit /b 0
