--rdtfnc_PalletReceiving
-- 3340 - 3349


INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
VALUES ('1719', 'ENG', 'FNC', 'Pallet Receiving', 'rdtfnc_PalletReceiving', '0')

-- Screen 1
-- Scn = 3340 
DELETE rdt.RDTScn WHERE Scn = 3340 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3340, 'ENG', 
   @cLine01 = 'PALLET RECEIVING',
   @cLine03 = 'TRUCK ID:',
   @cLine04 = '%20i01',
   @cLine14 = '%e'

-- Screen 2
DELETE rdt.RDTScn WHERE Scn = 3341 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3341, 'ENG', 
   @cLine01 = 'PALLET RECEIVING',
   @cLine03 = 'TRUCK ID:',
   @cLine04 = '%20d01',
   @cLine05 = 'SEAL NO:',
   @cLine06 = '%20i02',
   @cLine14 = '%e'

-- Screen 3
DELETE rdt.RDTScn WHERE Scn = 3342 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3342, 'ENG', 
   @cLine01 = 'PALLET RECEIVING',
   @cLine03 = 'TRUCK ID:',
   @cLine04 = '%20d01',
   @cLine05 = 'SEAL NO:',
   @cLine06 = '%20d02',
   @cLine07 = 'PALLET ID:',
   @cLine08 = '%20i03',
   @cLine14 = '%e'
   
-- Screen 4
DELETE rdt.RDTScn WHERE Scn = 3343 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3343, 'ENG', 
   @cLine01 = 'PALLET RECEIVING',
   @cLine03 = 'TRUCK ID:',
   @cLine04 = '%20d01',
   @cLine05 = 'SEAL NO:',
   @cLine06 = '%20d02',
   @cLine07 = 'PALLET ID:',
   @cLine08 = '%20d03',
   @cLine09 = 'Total Totes/Boxes:',
   @cLine10 = '%05i04',
   @cLine14 = '%e'

-- Screen 5
DELETE rdt.RDTScn WHERE Scn = 3344 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3344, 'ENG', 
   @cLine01 = 'PALLET RECEIVING',
   @cLine03 = 'TRUCK ID:',
   @cLine04 = '%20d01',
   @cLine05 = 'SEAL NO:',
   @cLine06 = '%20d02',
   @cLine07 = 'PALLET ID:',
   @cLine08 = '%20d03',
   @cLine09 = 'TOTE NO:',
   @cLine10 = '%20i04',
   @cLine11 = 'SCANNED: %05d05 / %05d06',
   @cLine14 = '%e'

-- Screen 6
DELETE rdt.RDTScn WHERE Scn = 3345 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3345, 'ENG', 
   @cLine01 = 'PALLET RECEIVING',
   @cLine03 = 'PALLET ID:',
   @cLine04 = '%20d01',
   @cLine06 = 'ACCEPT PALLET WITH',
   @cLine07 = 'SHORT SCANNED ? ',
   @cLine09 = '1 = YES',
   @cLine10 = '9 = NO',
   @cLine11 = 'OPTION: %01i02',
   @cLine14 = '%e'   
      
UPDATE RDT.RDTScn SET Func = 1719 WHERE Scn Between 3340 AND 3349 