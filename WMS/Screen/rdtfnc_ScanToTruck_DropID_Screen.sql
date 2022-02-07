--rdtfnc_TruckLoading
-- 3220 - 3229


INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
VALUES ('1716', 'ENG', 'FNC', 'ScanToTruck(DropID)', 'rdtfnc_ScanToTruck_DropID', '0')

-- Screen 1
-- Scn = 3220 
DELETE rdt.RDTScn WHERE Scn = 3220 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3220, 'ENG', 
   @cLine01 = 'TRUCK LOADING',
   @cLine03 = 'MBOLKEY:',
   @cLine04 = '%10i01',
   @cLine14 = '%e'

-- Screen 2
DELETE rdt.RDTScn WHERE Scn = 3221 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3221, 'ENG', 
   @cLine01 = 'TRUCK LOADING',
   @cLine03 = 'MBOLKEY:',
   @cLine04 = '%10d01',
   @cLine05 = 'CONSIGNEE:',
   @cLine06 = '%15i02',
   @cLine14 = '%e'

-- Screen 3
DELETE rdt.RDTScn WHERE Scn = 3222 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3222, 'ENG', 
   @cLine01 = 'TRUCK LOADING',
   @cLine03 = 'MBOLKEY:',
   @cLine04 = '%10d01',
   @cLine05 = 'CONSIGNEE:',
   @cLine06 = '%15d02',
   @cLine07 = 'DROPID:  CNT:%05d03',
   @cLine08 = '%20i04',
   @cLine14 = '%e'
   
-- Screen 4
DELETE rdt.RDTScn WHERE Scn = 3223 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3223, 'ENG', 
   @cLine01 = 'TRUCK LOADING',
   @cLine03 = 'MBOLKEY:',
   @cLine04 = '%10d01',
   @cLine05 = 'CONSIGNEE:',
   @cLine06 = '%15d02',
   --@cLine07 = 'DROPID:  CNT:%05d03',
   --@cLine08 = '%20d04',
   @cLine10 = 'CONFIRM LOADING?',
   @cLine11 = '1 = YES | 2 = NO',
   @cLine12 = 'OPTION: %01i05',
   @cLine14 = '%e'  
   
-- Screen 5
DELETE rdt.RDTScn WHERE Scn = 3224 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3224, 'ENG', 
   @cLine01 = 'TRUCK LOADING',
   @cLine03 = 'MBOLKEY:',
   @cLine04 = '%10d01',
   @cLine05 = 'CONSIGNEE:',
   @cLine06 = '%15d02',
   --@cLine07 = 'DROPID:',
   --@cLine08 = '%20d03',
   @cLine10 = 'TRUCK LOADING',
   @cLine11 = 'SUCCESSFULLY',
   @cLine14 = '%e'  
   
UPDATE RDT.RDTScn SET Func = 1716 WHERE Scn Between 3220 AND 3229 