--rdtfnc_PTL_Carton
-- 3930 - 3939


INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
VALUES ('809', 'ENG', 'FNC', 'PTS Carton', 'rdtfnc_PTL_Carton', '0')

-- Screen 1
-- Scn = 3930 
--DELETE rdt.RDTScn WHERE Scn = 3930 AND Lang_Code = 'ENG'
--EXECUTE rdt.rdtAddScn 3930, 'ENG', 
--   @cLine01 = 'PTL - CARTON',
--   @cLine03 = 'PTS Zone:',
--   @cLine04 = '%10i01',
--   @cLine14 = '%e'

-- Screen 2
DELETE rdt.RDTScn WHERE Scn = 3930 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3930, 'ENG', 
   @cLine01 = 'PTS - CARTON',
   --@cLine03 = 'PTS Zone: %10d01',
   @cLine03 = 'User ID:',
   @cLine04 = '%18i01',
   @cLine14 = '%e'

-- Screen 3
DELETE rdt.RDTScn WHERE Scn = 3931 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3931, 'ENG', 
   @cLine01 = 'PTS - CARTON',
   --@cLine03 = 'PTS Zone: %10d01',
   @cLine03 = 'User ID:',
   @cLine04 = '%18d01',
   @cLine06 = 'DropID:',
   @cLine07 = '%20i02',
   @cLine08 = '%20d03',
   @cLine09 = 'DropID Scanned:',
   @cLine10 = '%05d04',
   @cLine14 = '%e'
   
-- Screen 4
DELETE rdt.RDTScn WHERE Scn = 3932 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3932, 'ENG', 
   @cLine01 = 'PTS - CARTON',
   @cLine03 = 'PTS Zone: %10d01',
   @cLine04 = 'User ID:',
   @cLine05 = '%18d02',
   @cLine07 = 'TOTAL DropID: %05d03',
   @cLine09 = 'CONFIRM WORKLOAD?',
   @cLine10 = '1 = YES ',
   @cLine11 = '9 = NO ',
   @cLine12 = '5 = RESET ',
   @cLine13 = 'OPTIONS: %01i04',
   @cLine14 = '%e'

-- Screen 5
DELETE rdt.RDTScn WHERE Scn = 3933 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3933, 'ENG', 
   @cLine01 = 'PTS - CARTON',
   @cLine03 = 'PTS Zone: %10d01',
   @cLine04 = 'User ID:',
   @cLine05 = '%18d02',
   @cLine06 = 'User Color: %09d03',
   @cLine09 = 'PLEASE PROCEED TO',
   @cLine11 = 'LOC: %10d04',
   @cLine14 = '%e'   
   
      
UPDATE RDT.RDTScn SET Func = 809 WHERE Scn Between 3930 AND 3939
UPDATE RDT.RDTScnDetail SET Func = 809 WHERE Scn Between 3930 AND 3939 