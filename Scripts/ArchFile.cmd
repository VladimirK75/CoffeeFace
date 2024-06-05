@echo off
rem %1 - File to archive

rem %2 - type of archive name
rem      1 - YYYY-MM-DD.zip
rem      2 - YYYY-MM.zip
rem      3 - YYYY.zip
rem      4 - MM.zip

rem %3 - folder to archive

set DD=%date:~0,2%
set MM=%date:~3,2%
set YY=%date:~8,2%
set YYYY=%date:~6,4%

set pkzip=\\iron2\secur$\deal68\Util\7z.exe a -tzip -mx9 -r -x!*.zip -w%TEMP% -y

set DirTMP=%TEMP%%RANDOM%.bak

if "%2" == ""  set ArcName=%MM%.zip
if "%2" == "1" set ArcName=%YYYY%-%MM%-%DD%.zip
if "%2" == "2" set ArcName=%YYYY%-%MM%.zip
if "%2" == "3" set ArcName=%YYYY%.zip
if "%2" == "4" set ArcName=%MM%-%DD%.zip
if "%2" == "5" set ArcName=%MM%\%DD%.zip

if     "%3"=="" SET ArcFolder=%~d1%~sp1%YYYY%\
if NOT "%3"=="" SET ArcFolder=%3

 copy nul %DirTMP% > nul
xcopy %DirTMP% %ArcFolder% /Y /I /Q > nul
  del /F /Q %ArcFolder%*.bak > nul
  del /F /Q %DirTMP% > nul

rem for %%i in (%1) do  call %pkzip% -add -move -silent -temp=%TEMP% -fast -lev=9 "%ArcFolder%%ArcName%" "%%~fi"
for %%i in (%1) do ( call %pkzip% "%ArcFolder%%ArcName%" "%%~fi"
  del /F /Q "%%~fi"
                   )
