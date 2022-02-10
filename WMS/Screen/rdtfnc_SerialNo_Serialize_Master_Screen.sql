--rdtfnc_SerialNo_Serialize_Master
-- 5000 - 5009


INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
VALUES ('1014', 'ENG', 'FNC', 'SerialNo Serialize Master', 'rdtfnc_SerialNo_Serialize_Master', '0')

-- Screen 1
-- Scn = 5000 
DELETE rdt.RDTScn WHERE Scn = 5000 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5000, 'ENG', 
   @cLine01 = 'SERIALNO - SERIALIZE-M',
   @cLine03 = 'WORKORDER NO:',
   @cLine04 = '%10i01',
   --@cLine06 = 'WORK TYPE:',
   --@cLine07 = '1 = PRINT LABEL',
   --@cLine08 = '2 = BUILD SERIALNO',
   --@cLine10 = 'OPTION: %01i02',
   @cLine14 = '%e'

-- Screen 2
--DELETE rdt.RDTScn WHERE Scn = 5001 AND Lang_Code = 'ENG'
--EXECUTE rdt.rdtAddScn 5001, 'ENG', 
--   @cLine01 = 'SERIALNO - PRINT',
--   @cLine03 = 'SKU:',
--   @cLine04 = '%20i01',
--   @cLine06 = 'QUANTITY:',
--   @cLine07 = '%05i02',
--   @cLine14 = '%e'

-- Screen 2
DELETE rdt.RDTScn WHERE Scn = 5001 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5001, 'ENG', 
   @cLine01 = 'SERIALNO - SERIALIZE-M',
   @cLine03 = 'SKU:',
   @cLine04 = '%20i01',
   @cLine06 = 'CHILD SERIALNO:',
   @cLine07 = '%20i02',
   @cLine09 = 'TOTAL SCANNED:',
   @cLine10 = '%20d03',
   @cLine14 = '%e'
   
-- Screen 4
DELETE rdt.RDTScn WHERE Scn = 5002 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5002, 'ENG', 
   @cLine01 = 'SERIALNO - SERIALIZE-M',
   @cLine03 = 'SKU:',
   @cLine04 = '%20d01',
   @cLine06 = 'MASTER SERIALNO:',
   @cLine07 = '%20i02',
   @cLine14 = '%e'     
      
UPDATE RDT.RDTScn SET Func = 1014 WHERE Scn Between 5000 AND 5009
UPDATE RDT.RDTScnDetail SET Func = 1014 WHERE Scn Between 5000 AND 5009 