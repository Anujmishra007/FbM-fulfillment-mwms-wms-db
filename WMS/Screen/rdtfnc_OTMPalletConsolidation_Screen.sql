--rdtfnc_OTMPalletConsolidation
-- 4390 - 4398


INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
VALUES ('1722', 'ENG', 'FNC', 'OTM Pallet Consolidation', 'rdtfnc_OTMPalletConsolidation', '0')

-- Screen 1
-- Scn = 4390 
DELETE rdt.RDTScn WHERE Scn = 4390 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4390, 'ENG', 
   @cLine01 = 'PALLET CONSOLIDATION',
   @cLine03 = 'PALLET ID:',
   @cLine04 = '%20i01',
   @cLine06 = '1 = WHOLE',
   @cLine07 = '9 = PARTIAL',
   @cLine08 = 'Options = %01i02',
   @cLine14 = '%e'

-- Screen 2
DELETE rdt.RDTScn WHERE Scn = 4391 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4391, 'ENG', 
   @cLine01 = 'PALLET CONSOLIDATION',
   @cLine03 = 'FROM PALLET ID:',
   @cLine04 = '%20d01',
   @cLine05 = 'TO PALLET ID:',
   @cLine06 = '%20i02',
   @cLine14 = '%e'

-- Screen 3
DELETE rdt.RDTScn WHERE Scn = 4392 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4392, 'ENG', 
   @cLine01 = 'PALLET CONSOLIDATION',
   @cLine03 = 'FROM PALLET ID:',
   @cLine04 = '%20d01',
   @cLine05 = 'TO PALLET ID:',
   @cLine06 = '%20d02',
   @cLine08 = 'ORDER NO:',
   @cLine09 = '%10i03',
   @cLine14 = '%e'

   

   
UPDATE RDT.RDTScn SET Func = 1722 WHERE Scn Between 4390 AND 4398 