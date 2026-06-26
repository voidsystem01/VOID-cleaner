@echo off
title zapret-winws
chcp 65001 > nul
setlocal enabledelayedexpansion

:: Проверка прав администратора
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [!] Ошибка: Требуются права АДМИНИСТРАТОРА.
    echo Запустите файл правой кнопкой мыши -^> "Запуск от имени администратора".
    echo.
    pause
    exit /b
)

:menu
cls
color 0B
echo.
echo        ██╗   ██╗    ██████╗    ██╗   ██████╗ 
echo        ██║   ██║   ██╔═══██╗   ██║   ██╔══██╗
echo        ██║   ██║   ██║   ██║   ██║   ██║  ██║
echo        ╚██╗ ██╔╝   ██║   ██║   ██║   ██║  ██║
echo         ╚████╔╝    ╚██████╔╝   ██║   ██████╔╝
echo          ╚═══╝      ╚═════╝    ╚═╝   ╚═════╝ 
echo ────────────────────────────────────────────────
echo    [1] - ОЧИСТКА СЛЕДОВ
echo    [2] - ТЕЛЕГРАМ: @voidsystem01
echo    [3] - ВЫХОД
echo ────────────────────────────────────────────────
echo.
set /p choice="ВЫБЕРИТЕ ВАРИАНТ (1-3): "

if "%choice%"=="1" goto clean
if "%choice%"=="2" goto telegram
if "%choice%"=="3" goto exit
goto menu

:telegram
cls
echo.
echo ────────────────────────────────────────────────
echo  Контакты поддержки: @voidsystem01
echo ────────────────────────────────────────────────
echo.
pause
goto menu

:clean
cls
echo.
echo [!] Подготовка к очистке среды...
timeout /t 1 /nobreak >nul

:: 1. Принудительное завершение Проводника
echo [+] Остановка Windows Explorer (Проводник)...
taskkill /f /im explorer.exe >nul 2>&1
timeout /t 2 /nobreak >nul

:: 2. ShellBags
echo [+] Удаление следов для ShellBag Analyzer (очистка конфигураций папок)...
reg delete "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\BagMRU" /f >nul 2>&1
reg delete "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\Shell\BagMRU" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\Shell\Bags" /f >nul 2>&1
reg delete "HKUS\.DEFAULT\Software\Microsoft\Windows\Shell\BagMRU" /f >nul 2>&1
reg delete "HKUS\.DEFAULT\Software\Microsoft\Windows\Shell\Bags" /f >nul 2>&1

:: 3. LastActivityView / ExecutedProgramsList
echo [+] Удаление следов для LastActivityView и ExecutedProgramsList...
reg delete "HKCU\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Compatibility Assistant\Store" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Compatibility Assistant\Store" /f >nul 2>&1

:: 4. OpenSaveFilesView (Диалоги открытия/сохранения)
echo [+] Удаление следов для OpenSaveFilesView (диалоговые окна файлов)...
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\OpenSavePidlMRU" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\LastVisitedPidlMRU" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\OpenSaveMRU" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\LastVisitedMRU" /f >nul 2>&1

:: 5. Windows Timeline
echo [+] Удаление следов для Windows Timeline (Журнал действий)...
net stop CDPSvc /y >nul 2>&1
del /f /q /s "%localappdata%\ConnectedDevicesPlatform\*\ActivitiesCache.db*" >nul 2>&1
net start CDPSvc >nul 2>&1

:: 6. UserAssist, RunMRU
echo [+] Удаление следов для окна "Выполнить" (Win+R) и UserAssist...
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\UserAssist" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\TypedPaths" /f >nul 2>&1

:: 7. Prefetch, Recent, JumpLists
echo [+] Удаление следов для RecentFilesView и JumpLists (Prefetch, недавние)...
del /f /q /s "%systemroot%\Prefetch\*.*" >nul 2>&1
del /f /q /s "%userprofile%\Recent\*.*" >nul 2>&1
del /f /q "%appdata%\Microsoft\Windows\Recent\AutomaticDestinations\*" >nul 2>&1
del /f /q "%appdata%\Microsoft\Windows\Recent\CustomDestinations\*" >nul 2>&1

:: 8. USN Journal
echo [+] Удаление следов из USN Journal (Журнал изменений NTFS)...
fsutil usn deletejournal /d C: >nul 2>&1

:: 9. Браузеры, Discord, Steam
echo [+] Удаление кэша для Google Chrome, Yandex Browser, Discord, Steam...
del /f /q /s "%localappdata%\Google\Chrome\User Data\Default\Cache\*.*" >nul 2>&1
del /f /q /s "%localappdata%\Yandex\YandexBrowser\User Data\Default\Cache\*.*" >nul 2>&1
del /f /q /s "%appdata%\discord\Cache\*.*" >nul 2>&1
del /f /q /s "%appdata%\discord\Code Cache\*.*" >nul 2>&1
if exist "C:\Program Files (x86)\Steam" (
    del /f /q /s "C:\Program Files (x86)\Steam\logs\*.*" >nul 2>&1
    del /f /q /s "C:\Program Files (x86)\Steam\appcache\*.*" >nul 2>&1
)

:: 10. Перезапуск
echo [+] Восстановление Windows Explorer...
start explorer.exe
timeout /t 2 /nobreak >nul

echo.
echo ────────────────────────────────────────────────
echo  ПРОЦЕСС ОЧИСТКИ СИСТЕМЫ ЗАВЕРШЕН.
echo ────────────────────────────────────────────────
echo.
pause
goto self_delete

:exit
goto self_delete

:self_delete
:: Блок самоликвидации скрипта
cls
echo [!] Выход из системы и самоликвидация...
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU" /f >nul 2>&1
(goto) 2>nul & del "%~f0"