--rdtfnc_Close_Tote
-- 4970 - 4979


INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
VALUES ('1036', 'ENG', 'FNC', 'Close Tote', 'rdtfnc_Close_Tote', '0')

-- Screen 1
-- Scn = 4970 
DELETE rdt.RDTScn WHERE Scn = 4970 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4970, 'ENG', 
   @cLine01 = 'CLOSE TOTE',
   @cLine03 = 'CLOSE TOTE NO:',
   @cLine04 = '%20i01',
   @cLine06 = 'NEW TOTE NO:',
   @cLine07 = '%20i02',
   @cLine14 = '%e'

-- Screen 2
DELETE rdt.RDTScn WHERE Scn = 4971 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4971, 'ENG', 
   @cLine01 = 'CLOSE TOTE',
   @cLine03 = 'CLOSE TOTE NO:',
   @cLine04 = '%20d01',
   @cLine05 = 'NEW TOTE NO:',
   @cLine06 = '%20d02',
   @cLine08 = 'CONFIRM CLOSE TOTE?',
   @cLine09 = '1 = YES | 9 = NO',
   @cLine10 = 'OPTIONS: %01i03',
   @cLine14 = '%e'

      
UPDATE RDT.RDTScn SET Func = 1036 WHERE Scn Between 4970 AND 4979
UPDATE RDT.RDTScnDetail SET Func = 1036 WHERE Scn Between 4970 AND 4979 