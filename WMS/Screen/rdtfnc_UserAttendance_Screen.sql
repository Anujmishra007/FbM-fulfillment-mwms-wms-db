--rdtfnc_UserAttendance
-- 4380 - 4389


INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
VALUES ('704', 'ENG', 'FNC', 'User Attendance', 'rdtfnc_UserAttendance', '0')

-- Screen 1
-- Scn = 4380 
DELETE rdt.RDTScn WHERE Scn = 4380 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4380, 'ENG', 
   @cLine01 = 'USER ATTENDANCE',
   @cLine03 = 'USER ID:',
   @cLine04 = '%18i01',
   @cLine14 = '%e'

-- Screen 2
DELETE rdt.RDTScn WHERE Scn = 4381 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4381, 'ENG', 
   @cLine01 = 'USER ATTENDANCE',
   @cLine03 = 'USER ID:',
   @cLine04 = '%18d01',
   @cLine05 = 'LOC: %10d02',
   @cLine06 = 'START TIME:',
   @cLine07 = '%20d03',
   @cLine08 = 'END TIME:',
   @cLine09 = '%20d04',
   @cLine11 = 'LOC: %10i05',
   @cLine14 = '%e'

-- Screen 3
-- Screen 2
DELETE rdt.RDTScn WHERE Scn = 4382 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4382, 'ENG', 
   @cLine01 = 'USER ATTENDANCE',
   @cLine03 = 'USER ID:',
   @cLine04 = '%18d01',
   @cLine06 = 'LOC: %10d02',
   @cLine07 = 'START TIME:',
   @cLine08 = '%20d03',
   @cLine09 = 'END TIME:',
   @cLine10 = '%20d04',

   @cLine14 = '%e' 

      
UPDATE RDT.RDTScn SET Func = 1180 WHERE Scn Between 4350 AND 4359 
