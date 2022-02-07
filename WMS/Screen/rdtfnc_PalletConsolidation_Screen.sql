--rdtfnc_PalletConsolidation
-- 3350 - 3359


INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
VALUES ('1720', 'ENG', 'FNC', 'Pallet Consolidation', 'rdtfnc_PalletConsolidation', '0')

-- Screen 1
-- Scn = 3350 
DELETE rdt.RDTScn WHERE Scn = 3350 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3350, 'ENG', 
   @cLine01 = 'PALLET CONSOLIDATION',
   @cLine03 = 'PALLET ID:',
   @cLine04 = '%20i01',
   @cLine06 = '1 = WHOLE',
   @cLine07 = '9 = PARTIAL',
   @cLine08 = 'Options = %01i02',
   @cLine14 = '%e'

-- Screen 2
DELETE rdt.RDTScn WHERE Scn = 3351 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3351, 'ENG', 
   @cLine01 = 'PALLET CONSOLIDATION',
   @cLine03 = 'FROM PALLET ID:',
   @cLine04 = '%20d01',
   @cLine05 = 'TO PALLET ID:',
   @cLine06 = '%20i02',
   @cLine14 = '%e'

-- Screen 3
DELETE rdt.RDTScn WHERE Scn = 3352 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3352, 'ENG', 
   @cLine01 = 'PALLET CONSOLIDATION',
   @cLine03 = 'FROM PALLET ID:',
   @cLine04 = '%20d01',
   @cLine05 = 'TO PALLET ID:',
   @cLine06 = '%20d02',
   @cLine08 = 'TOTE NO / ORDER NO:', -- (ChewKP01) 
   @cLine09 = '%20i03',-- (ChewKP01) 
   @cLine14 = '%e'

   

   
UPDATE RDT.RDTScn SET Func = 1720 WHERE Scn Between 3350 AND 3359 