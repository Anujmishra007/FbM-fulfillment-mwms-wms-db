--rdtfnc_SerialNo_Kitting
-- 4990 - 4999


INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
VALUES ('1013', 'ENG', 'FNC', 'SerialNo Kitting', 'rdtfnc_SerialNo_Kitting', '0')

-- Screen 1
-- Scn = 4890 
DELETE rdt.RDTScn WHERE Scn = 4990 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4990, 'ENG', 
   @cLine01 = 'SERIALNO - KITTING',
   @cLine03 = 'WORKORDER NO:',
   @cLine04 = '%10i01',
   @cLine06 = 'WORK TYPE:',
   @cLine07 = '1 = PRINT LABEL',
   @cLine08 = '2 = BUILD SERIALNO',
   @cLine10 = 'OPTION: %01i02',
   @cLine14 = '%e'

-- Screen 2
DELETE rdt.RDTScn WHERE Scn = 4991 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4991, 'ENG', 
   @cLine01 = 'SERIALNO - PRINT',
   @cLine03 = 'SKU:',
   @cLine04 = '%20i01',
   @cLine06 = 'QUANTITY:',
   @cLine07 = '%05i02',
   @cLine14 = '%e'

-- Screen 3
DELETE rdt.RDTScn WHERE Scn = 4992 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4992, 'ENG', 
   @cLine01 = 'SERIALNO - BUILD',
   @cLine03 = 'SKU:',
   @cLine04 = '%20i01',
   @cLine06 = 'CHILD SERIALNO:',
   @cLine07 = '%20i02',
   @cLine09 = 'TOTAL SCANNED:',
   @cLine10 = '%20d03',
   @cLine14 = '%e'
   
-- Screen 4
DELETE rdt.RDTScn WHERE Scn = 4993 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4993, 'ENG', 
   @cLine01 = 'SERIALNO - BUILD',
   @cLine03 = 'SKU:',
   @cLine04 = '%20d01',
   @cLine06 = 'INNER SERIALNO:',
   @cLine07 = '%20i02',
   @cLine14 = '%e'   

-- Screen 4
DELETE rdt.RDTScn WHERE Scn = 4994 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4994, 'ENG', 
   @cLine01 = 'SERIALNO - BUILD',
   @cLine03 = 'SKU:',
   @cLine04 = '%20d01',
   @cLine06 = 'MASTER SERIALNO:',
   @cLine07 = '%20i02',
   @cLine14 = '%e'     
      
UPDATE RDT.RDTScn SET Func = 1013 WHERE Scn Between 4990 AND 4999
UPDATE RDT.RDTScnDetail SET Func = 1013 WHERE Scn Between 4990 AND 4999 