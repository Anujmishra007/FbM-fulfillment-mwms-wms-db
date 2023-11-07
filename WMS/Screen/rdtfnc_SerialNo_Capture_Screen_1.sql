--rdtfnc_SerialNo_Capture
-- 4940 - 4949


INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
VALUES ('824', 'ENG', 'FNC', 'SerialNo Capture', 'rdtfnc_SerialNo_Capture', '0')

-- Screen 1
-- Scn = 4940 
DELETE rdt.RDTScn WHERE Scn = 4940 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4940, 'ENG', 
   @cLine01 = 'SERIALNO CAPTURE',
   @cLine03 = 'TOTE ID:',
   @cLine04 = '%20i01',
   @cLine14 = '%e'

-- Screen 2
DELETE rdt.RDTScn WHERE Scn = 4941 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4941, 'ENG', 
   @cLine01 = 'SERIALNO CAPTURE',
   @cLine03 = 'TOTE ID:',
   @cLine04 = '%20d01',
   @cLine06 = 'SKU:',
   @cLine07 = '%20i02',
   @cLine14 = '%e'

-- Screen 3
DELETE rdt.RDTScn WHERE Scn = 4942 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4942, 'ENG', 
   @cLine01 = 'SERIALNO CAPTURE',
   @cLine03 = 'TOTE ID:',
   @cLine04 = '%20d01',
   @cLine05 = 'SKU:',
   @cLine06 = '%20d02',
   @cLine08 = 'MASTER SERIALNO:',
   @cLine09 = '%20i03',
   @cLine14 = '%e'

-- Screen 4
DELETE rdt.RDTScn WHERE Scn = 4943 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4943, 'ENG', 
   @cLine01 = 'SERIALNO CAPTURE',
   @cLine03 = 'TOTE ID:',
   @cLine04 = '%20d01',
   @cLine05 = 'SKU:',
   @cLine06 = '%20d02',
   @cLine07 = 'MASTER SERIALNO:',
   @cLine08 = '%20d03',
   @cLine10 = 'CHILD SERIALNO:',
   @cLine11 = '%20i04',
   @cLine14 = '%e'


-- Screen 5
DELETE rdt.RDTScn WHERE Scn = 4944 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4944, 'ENG', 
   @cLine01 = 'SERIALNO CAPTURE',
   @cLine03 = 'TOTE ID:',
   @cLine04 = '%20d01',
   @cLine05 = 'SKU:',
   @cLine06 = '%20d02',
   @cLine07 = 'MASTER SERIALNO:',
   @cLine08 = '%20d03',
   @cLine10 = 'PRINT LABEL ? ',
   @cLine11 = '1 = YES | 9 = NO',
   @cLine12 = 'OPTION: %01i04',
   @cLine14 = '%e'      
   
   
UPDATE RDT.RDTScn SET Func = 824 WHERE Scn Between 4940 AND 4949
UPDATE RDT.RDTScnDetail SET Func = 824 WHERE Scn Between 4940 AND 4949 