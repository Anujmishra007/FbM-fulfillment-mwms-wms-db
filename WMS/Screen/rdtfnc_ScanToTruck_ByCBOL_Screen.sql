--rdtfnc_ScanToTruck_ByCBOL
-- 6940 - 6944

IF NOT EXISTS (SELECT 1 FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID = '928')
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES ('928', 'ENG', 'FNC', 'Truck Loading(ByCBOL)', 'rdtfnc_ScanToTruck_ByCBOL', '0')

-- Screen 1
-- Scn = 6940
DELETE rdt.RDTScn WHERE Scn = 6940 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6940, 'ENG',
   @cLine01 = 'TRUCK LOADING ByCBOL',
   @cLine03 = 'CBOLKEY:',
   @cLine04 = '%20i01',
   @cLine14 = '%e'

-- Screen 2
-- Scn = 6941
DELETE rdt.RDTScn WHERE Scn = 6941 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6941, 'ENG',
   @cLine01 = 'TRUCK LOADING ByCBOL',
   @cLine02 = 'CBOLKEY: %20d01',
   @cLine04 = 'LABELNO/DROPID:',
   @cLine05 = '%20i02',
   @cLine06 = '%20d03',
   @cLine07 = '%20d15',
   @cLine08 = 'SCANNED: %20d04',
   @cLine09 = 'TOTAL  : %20d05',
   @cLine14 = '%e'

-- Screen 3
-- Scn = 6942
DELETE rdt.RDTScn WHERE Scn = 6942 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6942, 'ENG',
   @cLine01 = 'TRUCK LOADING ByCBOL',
   @cLine02 = 'CBOLKEY: %20d01',
   @cLine03 = 'LABELNO/DROPID:',
   @cLine04 = '%20d02',
   @cLine05 = 'WEIGHT : %20i03',
   @cLine07 = 'CUBE   : %20i04',
   @cLine09 = 'CARTON : %20i05',
   @cLine14 = '%e',
   @cWebGroup = '{"1":["5","5"],"2":["7","7"],"3":["9","9"]}'

-- Screen 4
-- Scn = 6943
DELETE rdt.RDTScn WHERE Scn = 6943 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6943, 'ENG',
   @cLine01 = 'TRUCK LOADING ByCBOL',
   @cLine03 = 'All LABEL/DROPID',
   @cLine04 = 'scanned for CBOL:',
   @cLine05 = '%20d01',
   @cLine07 = 'Ship all MBOLs in',
   @cLine08 = 'CBOL?',
   @cLine10 = '1 = YES',
   @cLine11 = '2 = NO',
   @cLine13 = 'OPTION:%01i02',
   @cLine14 = '%e'

-- Screen 5
-- Scn = 6944
DELETE rdt.RDTScn WHERE Scn = 6944 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6944, 'ENG',
   @cLine01 = 'TRUCK LOADING ByCBOL',
   @cLine03 = 'Not all',
   @cLine04 = 'LABEL/DROPID',
   @cLine05 = 'SCANNED for CBOL:',
   @cLine06 = '%20d01',
   @cLine14 = '%e'
