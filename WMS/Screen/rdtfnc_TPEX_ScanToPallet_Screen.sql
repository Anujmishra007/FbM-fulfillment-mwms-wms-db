--rdtfnc_TPEX_ScanToPallet
-- 4350 - 4359


INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
VALUES ('1180', 'ENG', 'FNC', 'TPEX Scan to Pallet', 'rdtfnc_TPEX_ScanToPallet', '0')

-- Screen 1
-- Scn = 4350 
DELETE rdt.RDTScn WHERE Scn = 4350 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4350, 'ENG', 
   @cLine01 = 'TPEX SCAN TO PALLET',
   @cLine03 = 'TRUCK ID:',
   @cLine04 = '%20i01',
   @cLine06 = 'SHIPMENT NO:',
   @cLine07 = '%10i02',
   @cLine14 = '%e'

-- Screen 2
DELETE rdt.RDTScn WHERE Scn = 4351 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4351, 'ENG', 
   @cLine01 = 'TPEX SCAN TO PALLET',
   @cLine03 = 'PALLET ID:',
   @cLine04 = '%20i01',
   @cLine06 = 'PALLET CNT: %05d02',
   @cLine08 = '1 = CLOSE TRUCK',
   @cLine09 = 'OPTION: %01i03',
   @cLine14 = '%e'

-- Screen 3
DELETE rdt.RDTScn WHERE Scn = 4352 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4352, 'ENG', 
   @cLine01 = 'TPEX SCAN TO PALLET',
   @cLine03 = 'TRUCK ID:',
   @cLine04 = '%10d01',
   @cLine06 = 'TOTAL PALLET CNT:',
   @cLine07 = '%05d02',
   @cLine14 = '%e'   

      
UPDATE RDT.RDTScn SET Func = 1180 WHERE Scn Between 4350 AND 4359 
