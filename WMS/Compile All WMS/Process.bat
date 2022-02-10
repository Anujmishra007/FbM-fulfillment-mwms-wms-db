echo off
echo ---- %3 ---- 
echo Compile %5
rem echo ---- %3 ---- >> %6

rem echo Country: %3 Server > %6

echo --  %5 >> %6
sqlcmd /U %1 /P %2 /S %3 /d %4 /i %5 -w 2048 >> %6
echo ----------------------------------------------------------------------------- >> %6
REM xcopy %1.sql Deploy\