--rdtfnc_ScanToTruck_Pallet
-- 3330 - 3339


INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
VALUES ('1718', 'ENG', 'FNC', 'Scan To Truck', 'rdtfnc_ScanToTruck_Pallet', '0')

-- Screen 1
-- Scn = 3330 
DELETE rdt.RDTScn WHERE Scn = 3330 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3330, 'ENG', 
   @cLine01 = 'SCAN TO TRUCK',
   @cLine03 = 'TRUCK ID:',
   @cLine04 = '%20i01',
   @cLine14 = '%e'

-- Screen 2
DELETE rdt.RDTScn WHERE Scn = 3331 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3331, 'ENG', 
   @cLine01 = 'SCAN TO TRUCK',
   @cLine03 = 'TRUCK ID: ',
   @cLine04 = '%20d01',
   @cLine06 = '1 = CLOSE TRUCK ',
   @cLine07 = '5 = REMOVE PALLET',
   @cLine08 = '9 = ADD PALLET',
   @cLine09 = 'Options : %01i02',
   @cLine14 = '%e'

-- Screen 3
DELETE rdt.RDTScn WHERE Scn = 3332 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3332, 'ENG', 
   @cLine01 = 'SCAN TO TRUCK',
   @cLine03 = 'TRUCK ID: ',
   @cLine04 = '%20d01',
   @cLine06 = 'SEAL NO:',
   @cLine07 = '%20i02',
   @cLine14 = '%e'
   
-- Screen 4
DELETE rdt.RDTScn WHERE Scn = 3333 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3333, 'ENG', 
   @cLine01 = 'SCAN TO TRUCK',
   @cLine03 = 'TRUCK ID: ',
   @cLine04 = '%20d01',
   @cLine06 = 'REMOVE PALLET',
   @cLine08 = 'PALLET ID:',
   @cLine09 = '%20i02',
   @cLine14 = '%e'

-- Screen 5
DELETE rdt.RDTScn WHERE Scn = 3334 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3334, 'ENG', 
   @cLine01 = 'SCAN TO TRUCK',
   @cLine03 = 'TRUCK ID: ',
   @cLine04 = '%20d01',
   @cLine06 = 'ADD PALLET',
   @cLine08 = 'PALLET ID:',
   @cLine09 = '%20i02',
   @cLine10 = 'SCANNED: %05d03',
   @cLine14 = '%e'


DELETE rdt.RDTScn WHERE Scn = 3335 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3335, 'ENG', 
   @cLine01 = 'SCAN TO TRUCK',
   @cLine05 = 'PALLET ID:',
   @cLine06 = '%20i01',
   @cLine07 = 'SCANNED BEFORE',
   @cLine10 = 'CONFIRM ADD TO',
   @cLine11 = 'NEW TRUCK ?',
   @cLine12 = '1 = YES | 9 = NO',
   @cLine09 = 'Option: %01d02',
   @cLine14 = '%e'
         
UPDATE RDT.RDTScn SET Func = 1718 WHERE Scn Between 3330 AND 3339 