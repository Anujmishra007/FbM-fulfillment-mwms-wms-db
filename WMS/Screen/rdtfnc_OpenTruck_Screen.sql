--rdtfnc_OpenTruck
-- 3320 - 3329


INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
VALUES ('1717', 'ENG', 'FNC', 'Open Truck', 'rdtfnc_OpenTruck', '0')

-- Screen 1
-- Scn = 3320 
DELETE rdt.RDTScn WHERE Scn = 3320 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3320, 'ENG', 
   @cLine01 = 'OPEN TRUCK',
   @cLine03 = 'TRUCK ID:',
   @cLine04 = '%20i01',
   @cLine14 = '%e'

DELETE rdt.RDTScn WHERE Scn = 3321 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3321, 'ENG', 
   @cLine01 = 'OPEN TRUCK',
   @cLine03 = 'TRUCK ID:',
   @cLine04 = '%20d01',
   @cLine05 = 'SEAL NO:',
   @cLine06 = '%20i02',
   @cLine14 = '%e'   

-- Screen 3
DELETE rdt.RDTScn WHERE Scn = 3322 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3322, 'ENG', 
   @cLine01 = 'OPEN TRUCK',
   @cLine03 = 'Opening Truck:',
   @cLine04 = '%20d01',
   @cLine05 = 'SealNo:',
   @cLine06 = '%20d02',
   @cLine07 = 'Are you sure ?',
   @cLine09 = '1 = YES | 9 = NO',
   @cLine10 = 'Options : %01i03',
   @cLine14 = '%e'

-- Screen 4
DELETE rdt.RDTScn WHERE Scn = 3323 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3323, 'ENG', 
   @cLine01 = 'OPEN TRUCK',
   @cLine03 = 'TRUCK ID:',
   @cLine04 = '%20d01',
   @cLine05 = 'SealNo:',
   @cLine06 = '%20d02',
   @cLine07 = 'is now open.',
   @cLine14 = '%e'
   

   
UPDATE RDT.RDTScn SET Func = 1717 WHERE Scn Between 3320 AND 3322 