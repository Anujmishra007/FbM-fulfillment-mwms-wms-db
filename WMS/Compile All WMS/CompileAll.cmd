REM echo off


echo : CN LIVE : CNWMS >> logWMS.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmsdbcn.lflogistics.net.cn" "CNWMS" %%f "logWMS.txt"

echo : CN LIVE : HNM >> logWMS.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmsCNHNM.lflogistics.net.cn" "CNWMSHNM" %%f "logWMS.txt"

echo : CN LIVE : NKE >> logWMS.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmsCNNKE.lflogistics.net.cn" "CNWMSNKE" %%f "logWMS.txt"

echo : CN LIVE : SKE >> logWMS.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmsCNSKE.lflogistics.net.cn" "CNWMSSKE" %%f "logWMS.txt"

echo : CN LIVE : UAM >> logWMS.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmsCNUAM.lflogistics.net.cn" "CNWMSUAM" %%f "logWMS.txt"

echo : CN LIVE : SEP >> logWMS.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmsCNSEP.lflogistics.net.cn" "CNWMSSEP" %%f "logWMS.txt"


echo : AUWMS >> logWMS.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmsdbau.lfapps.net" "AUWMS" %%f "logWMS.txt"


echo : DUWMS >> logWMS.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmsdbDU.lfapps.net" "DUWMS" %%f "logWMS.txt"


echo : HK HKWMS >> logWMS.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmsdbhk.lfapps.net" "HKWMS" %%f "logWMS.txt"


echo : IN LIVE : INWMS >> logWMS.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmsdbin.lfapps.net" "INWMS" %%f "logWMS.txt"


echo : ID LIVE : IDWMS >> logWMS.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmsdbidn.lfapps.net" "IDWMS" %%f "logWMS.txt"


echo : JP LIVE : JPWMS >> logWMS.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmsdbjp.lfapps.net" "JPWMS" %%f "logWMS.txt"


echo : KR LIVE : KRWMS >> logWMS.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmsdbkr.lfapps.net" "KRWMS" %%f "logWMS.txt"


echo : MY LIVE : MYWMS >> logWMS.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmsdbmy.lfapps.net" "MYWMS" %%f "logWMS.txt"


echo : PH LIVE : PHWMS >> logWMS.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmsdbph.lfapps.net" "PHWMS" %%f "logWMS.txt"


echo : SG LIVE : SGWMS >> logWMS.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmsdbsg.lfapps.net" "SGWMS" %%f "logWMS.txt"


echo : TH LIVE : THWMS >> logWMS.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmsdbth.lfapps.net" "THWMS" %%f "logWMS.txt"


echo : TW LIVE : TWWMS >> logWMS.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmsdbtw.lfapps.net" "TWWMS" %%f "logWMS.txt"


echo : VN LIVE : VNWMS >> logWMS.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmsdbVN.lfapps.net" "VNWMS" %%f "logWMS.txt"

