REM echo off

echo : JP DR : CNWMS : : : : : : : : : : : : : : : : : : : : : : : : : : : : : >> logWMSDR.txt
for %%f in (*.sql) do call Process.bat "dts" "dts01" "VMAZJPWMSDBDR1" "CDB"  %%f "logWMSDR.txt"
