--rdtfnc_TMS_ScanToPallet
-- 4820 - 4829


INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
VALUES ('1187', 'ENG', 'FNC', 'TMS Scan to Pallet', 'rdtfnc_TMS_ScanToPallet', '0')

-- Screen 1
-- Scn = 4820 
DELETE rdt.RDTScn WHERE Scn = 4820 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4820, 'ENG', 
   @cLine01 = 'TPEX SCAN TO PALLET',
   @cLine03 = 'TRUCK ID:',
   @cLine04 = '%20i01',
   @cLine05 = 'TO WHS:',
   @cLine06 = '%20i03',
   @cLine07 = 'SHIPMENT NO:',
   @cLine08 = '%10i02',
   @cLine14 = '%e'

-- Screen 2
DELETE rdt.RDTScn WHERE Scn = 4821 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4821, 'ENG', 
   @cLine01 = 'TPEX SCAN TO PALLET',
   @cLine03 = 'PALLET ID:',
   @cLine04 = '%20i01',
   @cLine06 = 'PALLET CNT: %05d02',
   @cLine08 = '1 = CLOSE TRUCK',
   @cLine09 = 'OPTION: %01i03',
   @cLine14 = '%e'

-- Screen 3
DELETE rdt.RDTScn WHERE Scn = 4822 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4822, 'ENG', 
   @cLine01 = 'TPEX SCAN TO PALLET',
   @cLine03 = 'TRUCK ID:',
   @cLine04 = '%10d01',
   @cLine06 = 'TOTAL PALLET CNT:',
   @cLine07 = '%05d02',
   @cLine14 = '%e'   

      
UPDATE RDT.RDTScn SET Func = 1187 WHERE Scn Between 4820 AND 4829 
