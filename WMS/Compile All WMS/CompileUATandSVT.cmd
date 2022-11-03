REM echo off

echo : CN UAT : CNWMS >> logWMSuat.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmscn-uat.lflogistics.net.cn" "CNWMS"  %%f "logWMSuat.txt"

echo : CN UAT : CNWMS_HM1 >> logWMSuat.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmscn-uat.lflogistics.net.cn" "CNWMS_HM1"  %%f "logWMSuat.txt"

echo : CN UAT : CNWMS_HM2 >> logWMSuat.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmscn-uat.lflogistics.net.cn" "CNWMS_HM2"  %%f "logWMSuat.txt"


echo : CN SVT : CNWMS >> logWMSuat.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmsDB-SVT.lflogistics.net.cn" "CNWMS"  %%f "logWMSuat.txt"

echo : CN SVT : CNWMS >> logWMSuat.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmsDBHNM-SVT.lflogistics.net.cn" "CNWMSHNM"  %%f "logWMSuat.txt"

echo : CN SVT : CNWMS >> logWMSuat.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmsDBUAM-SVT.lflogistics.net.cn" "CNWMSUAM"  %%f "logWMSuat.txt"

echo : CN SVT : CNWMS >> logWMSuat.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmsDBSKE-SVT.lflogistics.net.cn" "CNWMSSKE"  %%f "logWMSuat.txt"

echo : CN SVT : CNWMS >> logWMSuat.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmsDBNKE-SVT.lflogistics.net.cn" "CNWMSNKE"  %%f "logWMSuat.txt"

echo : CN SVT : CNWMS >> logWMSuat.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmsSEPSVT.lflogistics.net.cn" "CNWMSNKE"  %%f "logWMSuat.txt"



echo : GT  : GTWMS >> logWMSuat.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmsdb-dev.lflogistics.net" "GTWMS" %%f "logWMSuat.txt"

echo : GT  : SCEWMS_UAT >> logWMSuat.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmsdb-dev.lflogistics.net" "SCEWMS_UAT" %%f "logWMSuat.txt"

echo : GT  : SCEWMS >> logWMSuat.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmsdb-dev.lflogistics.net" "SCEWMS" %%f "logWMSuat.txt"

echo : VMGBWMSDBDV4 : LFL_WMS_DEV >> logWMSuat.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmsdb-dev.lflogistics.net" "LFL_WMS_DEV" %%f "logWMSuat.txt"

echo : GT  : LFL_WMS_UAT >> logWMSuat.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmsdb-dev.lflogistics.net" "LFL_WMS_UAT" %%f "logWMSuat.txt"

echo : GT  : LFL_WMS_CHN >> logWMSuat.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmsdb-dev.lflogistics.net" "LFL_WMS_CHN" %%f "logWMSuat.txt"

echo : GT  : LFL_WMS_SGP >> logWMSuat.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmsdb-dev.lflogistics.net" "LFL_WMS_SGP" %%f "logWMSuat.txt"


echo : AU UAT : AUWMS >> logWMSuat.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmsdbau-uat.lflogistics.net" "AUWMS"  %%f "logWMSuat.txt"

echo : DU UAT : DUWMS >> logWMSuat.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmsdbae-uat.lflogistics.net" "DUWMS"  %%f "logWMSuat.txt"

echo : HK UAT : HKWMS >> logWMSuat.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmsdbhk-uat.lflogistics.net" "HKWMS"  %%f "logWMSuat.txt"

echo : ID UAT : IDWMS >> logWMSuat.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmsdbid-uat.lflogistics.net" "IDWMS" %%f "logWMSuat.txt"


echo : IN UAT : INWMS >> logWMSuat.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmsdbIN-uat.lflogistics.net" "INWMS" %%f "logWMSuat.txt"

echo : IN UAT : INWMS_HM1 >> logWMSuat.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmsdbIN-uat.lflogistics.net" "INWMS_HM1" %%f "logWMSuat.txt"

echo : IN UAT : INWMS_HM2 >> logWMSuat.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmsdbIN-uat.lflogistics.net" "INWMS_HM2" %%f "logWMSuat.txt"


echo : JP UAT : JPWMS >> logWMSuat.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmsdbjp-uat.lflogistics.net" "JPWMS" %%f "logWMSuat.txt"

echo : JP UAT : JPWMS_HM1 >> logWMSuat.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmsdbjp-uat.lflogistics.net" "JPWMS_HM1" %%f "logWMSuat.txt"

echo : JP UAT : JPWMS_HM2 >> logWMSuat.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmsdbjp-uat.lflogistics.net" "JPWMS_HM2" %%f "logWMSuat.txt"


echo : KR UAT : KRWMS >> logWMSuat.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmsdbkr-uat.lflogistics.net" "KRWMS" %%f "logWMSuat.txt"

echo : KR UAT : KRWMS_HM1 >> logWMSuat.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmsdbkr-uat.lflogistics.net" "KRWMS_HM1" %%f "logWMSuat.txt"

echo : KR UAT : KRWMS_HM2 >> logWMSuat.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmsdbkr-uat.lflogistics.net" "KRWMS_HM2" %%f "logWMSuat.txt"


echo : MY UAT : MYWMS >> logWMSuat.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmsdbmy-uat.lflogistics.net" "MYWMS"  %%f "logWMSuat.txt"

echo : PH UAT : PHWMS >> logWMSuat.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmsdbph-uat.lflogistics.net" "PHWMS"  %%f "logWMSuat.txt"

echo : SG UAT : SGWMS >> logWMSuat.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmsdbsg-uat.lflogistics.net" "SGWMS"  %%f "logWMSuat.txt"


echo : TH UAT : THWMS >> logWMSuat.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmsdbth-uat.lflogistics.net" "THWMS"  %%f "logWMSuat.txt"

echo : TH UAT : THWMS_NIKE >> logWMSuat.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmsdbth-uat.lflogistics.net" "THWMS_NIKE"  %%f "logWMSuat.txt"

echo : TW UAT : TWWMS >> logWMSuat.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmsdbtw-uat.lflogistics.net" "TWWMS"  %%f "logWMSuat.txt"

echo : TW UAT : TWWMS_NSC >> logWMSuat.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmsdbtw-uat.lflogistics.net" "TWWMS_NSC"  %%f "logWMSuat.txt"

echo : VN UAT : VNWMS >> logWMSuat.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmsdbvn-uat.lflogistics.net" "VNWMS"  %%f "logWMSuat.txt"
