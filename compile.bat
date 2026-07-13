@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"

set PHP_BINARY=
if exist "bin\php\php.exe" (
    set "PHP_BINARY=bin\php\php.exe"
) else if exist "..\bin\php\php.exe" (
    set "PHP_BINARY=..\bin\php\php.exe"
) else (
    where /q php.exe && set "PHP_BINARY=php"
)

if "%PHP_BINARY%"=="" (
    echo PHP not found.
    exit /b 1
)

set COMPOSER_CMD=
if exist "composer.phar" (
    set COMPOSER_CMD="%PHP_BINARY%" "composer.phar"
) else if exist "..\composer.phar" (
    set COMPOSER_CMD="%PHP_BINARY%" "..\composer.phar"
) else (
    where /q composer && (
        set COMPOSER_CMD=composer
    ) || (
        curl -L -sS https://getcomposer.org/composer.phar -o composer.phar
        if exist "composer.phar" (
            set COMPOSER_CMD="%PHP_BINARY%" "composer.phar"
        ) else (
            echo Composer not found.
            exit /b 1
        )
    )
)

call %COMPOSER_CMD% install --no-dev --classmap-authoritative --ignore-platform-reqs
if !errorlevel! neq 0 exit /b !errorlevel!

"%PHP_BINARY%" -dphar.readonly=0 build\server-phar.php
