--scn 3910 --- 3919

IF NOT EXISTS (SELECT 1 FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID=841)
BEGIN
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES ('841', 'ENG', 'FNC', 'DTC Dispatch', 'rdtfnc_DTC_Dispatch', '0')
END

-- 2400 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 3910 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3910, 'ENG',
    @cLine01 = 'E-COMM DISPATCH'
   ,@cLine03 = 'TOTE NO:'
   ,@cLine04 = '%20i01'       --(ChewKP12) 
   ,@cLine05 = 'OR'           --(ChewKP01)
   ,@cLine06 = 'WAVEKEY:'     --(ChewKP01)   
   ,@cLine07 = '%10i02'       --(ChewKP01)
   ,@cLine08 = 'OR'           --(ChewKP01)
   ,@cLine09 = 'LOADKEY:'     --(ChewKP01)
   ,@cLine10 = '%10i03'       --(ChewKP01)
   ,@cLine11 = 'OR'           --WMS17077
   ,@cLine12 = 'REFNO:'       --WMS17077
   ,@cLine13 = '%20i04'       --WMS17077
   ,@cLine14 = '%e'           
   ,@cWebGroup = '{"1":["3","4"],"2":["6","7"],"3":["9","10"],"4":["12","13"]}'
   ,@nFunc = 841

-- 2401 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 3911 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3911, 'ENG',
    @cLine01 = 'E-COMM DISPATCH'
   ,@cLine03 = 'TOTE TYPE: %10d01'
   ,@cLine04 = 'TOTE NO:'
   ,@cLine05 = '%18d02'
   ,@cLine06 = 'ORDERKEY:'
   ,@cLine07 = '%10d03'
   ,@cLine08 = 'SKU/UPC:'
   ,@cLine09 = '%60i04'       -- Enlarge to 60 chars (WMS893)
   ,@cLine10 = 'TTL PICK: %05d05'
   ,@cLine11 = 'TTL SCAN: %05d06'
   ,@cLine13 = '%20d07' --(yeekung01)
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1"],"2":["4","5"],"3":["6","7"],"4":["8","9"],"5":["10","11"]}'
   ,@nFunc = 841

-- 2402 = ?? screen
--DELETE rdt.RDTScn WHERE Scn = 3912 AND Lang_Code = 'ENG'
--EXECUTE rdt.rdtAddScn 3912, 'ENG',
--    @cLine01 = 'E-COMM DISPATCH'
--   ,@cLine03 = 'TOTE NO:'
--   ,@cLine04 = '%18d01'
--   ,@cLine05 = 'ORDERKEY:'
--   ,@cLine06 = '%10d02'
--   ,@cLine07 = 'SKU/UPC:'
--   ,@cLine08 = '%20i03'
--   ,@cLine14 = '%e'
--   ,@nFunc = 841

-- 2403 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 3912 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3912, 'ENG',
    @cLine01 = 'E-COMM DISPATCH'
   ,@cLine03 = 'Reason Code:'
   ,@cLine04 = '%10i01'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["3","4"]}'
   ,@nFunc = 841

-- 2404 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 3913 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3913, 'ENG',
    @cLine01 = 'E-COMM DISPATCH'
   ,@cLine02 = 'More Tote to be'
   ,@cLine03 = 'scanned, Continue?'
   ,@cLine05 = '%18d01'
   ,@cLine06 = '%18d02'
   ,@cLine07 = '%18d03'
   ,@cLine08 = '%18d04'
   ,@cLine09 = '%18d05'
   ,@cLine10 = '%18d06'
   ,@cLine11 = '1 = Yes 9 = No'
   ,@cLine12 = 'OPTION: %01i07'
   ,@cLine13 = '%20d07' --(yeekung01)
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["2","3","5","6","7","8","9","10"],"2":["11","12"],"3":["13"]}'
   ,@nFunc = 841

-- 2405 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 3914 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3914, 'ENG',
    @cLine01 = 'E-COMM DISPATCH'
   ,@cLine03 = 'PARK TOTE'
   ,@cLine05 = 'Press ENTER or ESC'
   ,@cLine06 = 'to continue'
   ,@nFunc = 841
   
DELETE rdt.RDTScn WHERE Scn = 3915 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3915, 'ENG',
    @cLine01 = 'E-COMM DISPATCH'
   ,@cLine03 = 'ORDERKEY: %10d01'
   ,@cLine05 = 'Track No:'
   ,@cLine06 = '%20i02'
   ,@cLine08 = '%20d03'  --WMS-17410 extInfo
   ,@cLine14 = '%e'
   ,@cAutoDisappear = '1'
   ,@nFunc = 841

----WMS-13131 (yeekung01)
--DELETE rdt.RDTScn WHERE Scn = 3916 AND Lang_Code = 'ENG'
--EXECUTE rdt.rdtAddScn 3916, 'ENG',
--    @cLine01 = 'Carton Type'
--   ,@cLine02 = '%20i07'
--   ,@cLine14 = '%e'
--   ,@nFunc = 841
   
--WMS-17410 
DELETE rdt.RDTScn WHERE Scn = 3916 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3916, 'ENG',
    @cLine01 = 'CARTON: %10i07'
   ,@cLine03 = 'CUBE: %10i02^DT:INT'
   ,@cLine05 = 'WEIGHT: %10i03^DT:INT'
   ,@cLine06 = 'LENGTH: %10i05^DT:INT'  -- FCR-1625
   ,@cLine07 = 'WIDTH:  %10i06^DT:INT'  -- FCR-1625
   ,@cLine08 = 'HEIGHT: %10i08^DT:INT'  -- FCR-1625
   ,@cLine09 = 'REF NO:'
   ,@cLine10 = '%20i04'
   ,@cLine13 = '%20d09' --WMS-22041
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1"],"2":["3"],"3":["5"],"4":["7","8"],"5":["13"]}'
   ,@nFunc = 841

select * from rdt.rdtscn with (nolock) where scn between 3910 and 3919 
