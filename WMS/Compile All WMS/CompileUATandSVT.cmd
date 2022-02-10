REM echo off

echo : CN UAT : CNWMS >> logWMSuat.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmscn-uat.lflogistics.net.cn" "CNWMS"  %%f "logWMSuat.txt"

echo : CN UAT : CNWMS_HM1 >> logWMSuat.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmscn-uat.lflogistics.net.cn" "CNWMS_HM1"  %%f "logWMSuat.txt"

echo : CN UAT : CNWMS_HM2 >> logWMSuat.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmscn-uat.lflogistics.net.cn" "CNWMS_HM2"  %%f "logWMSuat.txt"


echo : CN SB1 : CNWMS >> logWMSuat.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmsDBCNVT.lfuat.net" "CNWMS"  %%f "logWMSuat.txt"

echo : CN SVT : CNWMS >> logWMSuat.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "CNWMSDBPD6" "CNWMS"  %%f "logWMSuat.txt"

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

echo : CN SEP : CNWMS >> logWMSuat.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmsCNSEP.LFUAT.net" "CNWMSSEP"  %%f "logWMSuat.txt"


echo : GT  : GTWMS >> logWMSuat.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "172.21.16.214" "GTWMS" %%f "logWMSuat.txt"

echo : GT  : SCEWMS_UAT >> logWMSuat.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "172.21.16.214" "SCEWMS_UAT" %%f "logWMSuat.txt"

echo : GT  : SCEWMS >> logWMSuat.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "172.21.16.214" "SCEWMS" %%f "logWMSuat.txt"

echo : VMGBWMSDBDV4 : LFL_WMS_DEV >> logWMSuat.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "172.21.16.214" "LFL_WMS_DEV" %%f "logWMSuat.txt"

echo : GT  : LFL_WMS_UAT >> logWMSuat.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "172.21.16.214" "LFL_WMS_UAT" %%f "logWMSuat.txt"

echo : GT  : LFL_WMS_CHN >> logWMSuat.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "172.21.16.214" "LFL_WMS_CHN" %%f "logWMSuat.txt"

echo : GT  : LFL_WMS_SGP >> logWMSuat.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "172.21.16.214" "LFL_WMS_SGP" %%f "logWMSuat.txt"


echo : AU UAT : AUWMS >> logWMSuat.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmsau.lfuat.net" "AUWMS"  %%f "logWMSuat.txt"

echo : DU UAT : DUWMS >> logWMSuat.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmsdu.lfuat.net" "DUWMS"  %%f "logWMSuat.txt"

echo : HK UAT : HKWMS >> logWMSuat.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmshk.lfuat.net" "HKWMS"  %%f "logWMSuat.txt"

echo : ID UAT : IDWMS >> logWMSuat.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmsidn.lfuat.net" "IDWMS" %%f "logWMSuat.txt"


echo : IN UAT : INWMS >> logWMSuat.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmsIN.lfuat.net" "INWMS" %%f "logWMSuat.txt"

echo : IN UAT : INWMS_HM1 >> logWMSuat.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmsIN.lfuat.net" "INWMS_HM1" %%f "logWMSuat.txt"

echo : IN UAT : INWMS_HM2 >> logWMSuat.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmsIN.lfuat.net" "INWMS_HM2" %%f "logWMSuat.txt"


echo : JP UAT : JPWMS >> logWMSuat.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmsjp.lfuat.net" "JPWMS" %%f "logWMSuat.txt"

echo : JP UAT : JPWMS_HM1 >> logWMSuat.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmsjp.lfuat.net" "JPWMS_HM1" %%f "logWMSuat.txt"

echo : JP UAT : JPWMS_HM2 >> logWMSuat.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmsjp.lfuat.net" "JPWMS_HM2" %%f "logWMSuat.txt"


echo : KR UAT : KRWMS >> logWMSuat.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmskr.lfuat.net" "KRWMS" %%f "logWMSuat.txt"

echo : KR UAT : KRWMS_HM1 >> logWMSuat.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmskr.lfuat.net" "KRWMS_HM1" %%f "logWMSuat.txt"

echo : KR UAT : KRWMS_HM2 >> logWMSuat.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmskr.lfuat.net" "KRWMS_HM2" %%f "logWMSuat.txt"


echo : MY UAT : MYWMS >> logWMSuat.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmsmy.lfuat.net" "MYWMS"  %%f "logWMSuat.txt"

echo : PH UAT : PHWMS >> logWMSuat.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmsph.lfuat.net" "PHWMS"  %%f "logWMSuat.txt"

echo : SG UAT : SGWMS >> logWMSuat.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmssg.lfuat.net" "SGWMS"  %%f "logWMSuat.txt"


echo : TH UAT : THWMS >> logWMSuat.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmsth.lfuat.net" "THWMS"  %%f "logWMSuat.txt"

echo : TH UAT : THWMS_NIKE >> logWMSuat.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmsth.lfuat.net" "THWMS_NIKE"  %%f "logWMSuat.txt"

echo : TW UAT : TWWMS >> logWMSuat.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmstw.lfuat.net" "TWWMS"  %%f "logWMSuat.txt"

echo : TW UAT : TWWMS_NSC >> logWMSuat.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmstw.lfuat.net" "TWWMS_NSC"  %%f "logWMSuat.txt"

echo : VN UAT : VNWMS >> logWMSuat.txt
for %%f in (*.sql) do call Process.bat "dmadmin" "dm@dmin01" "wmsvn.lfuat.net" "VNWMS"  %%f "logWMSuat.txt"
