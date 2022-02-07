--rdtfnc_TPEX_ScanOffTruck
-- 4320 - 4329


INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
VALUES ('1183', 'ENG', 'FNC', 'TPEX Scan Off Truck', 'rdtfnc_TPEX_ScanOffTruck', '0')

-- Screen 1
-- Scn = 4320 
DELETE rdt.RDTScn WHERE Scn = 4320 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4320, 'ENG', 
   @cLine01 = 'TPEX SCAN OFF PALLET',
   @cLine03 = 'TRUCK ID:',
   @cLine04 = '%20i01',
   @cLine14 = '%e'

DELETE rdt.RDTScn WHERE Scn = 4321 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4321, 'ENG', 
   @cLine01 = 'TPEX SCAN OFF PALLET',
   @cLine03 = 'TRCUK ID:',
   @cLine04 = '%20d01',
   @cLine06 = 'PALLET ID:',
   @cLine07 = '%20i02',
   @cLine08 = 'DROP LOCATION:',
   @cLine09 = '%10i03',
   @cLine10 = 'TTL PALLET ON TRUCK:',
   @cLine11 = '%10d04',
   @cLine14 = '%e' 

      
UPDATE RDT.RDTScn SET Func = 1183 WHERE Scn Between 4320 AND 4329 
