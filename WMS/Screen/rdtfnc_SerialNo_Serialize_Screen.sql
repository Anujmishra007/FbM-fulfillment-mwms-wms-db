--rdtfnc_SerialNo_Serialize
-- 4890 - 4899


INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
VALUES ('1010', 'ENG', 'FNC', 'SerialNo Serialize', 'rdtfnc_SerialNo_Serialize', '0')

-- Screen 1
-- Scn = 4890 
DELETE rdt.RDTScn WHERE Scn = 4890 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4890, 'ENG', 
   @cLine01 = 'SERIALNO',
   @cLine03 = 'WORKORDER NO:',
   @cLine04 = '%10i01',
   @cLine06 = 'WORK TYPE:',
   @cLine07 = '1 = PRINT LABEL',
   @cLine08 = '2 = BUILD SERIALNO',
   @cLine10 = 'OPTION: %01i02',
   @cLine14 = '%e'

-- Screen 2
DELETE rdt.RDTScn WHERE Scn = 4891 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4891, 'ENG', 
   @cLine01 = 'SERIALNO - PRINT',
   @cLine03 = 'SKU:',
   @cLine04 = '%20i01',
   @cLine06 = 'QUANTITY:',
   @cLine07 = '%05i02',
   @cLine14 = '%e'

-- Screen 3
DELETE rdt.RDTScn WHERE Scn = 4892 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4892, 'ENG', 
   @cLine01 = 'SERIALNO - BUILD',
   @cLine03 = 'SKU:',
   @cLine04 = '%20i01',
   @cLine06 = 'CHILD SERIALNO:',
   @cLine07 = '%20i02',
   @cLine09 = 'TOTAL SCANNED:',
   @cLine10 = '%20d03',
   @cLine14 = '%e'
   
-- Screen 4
DELETE rdt.RDTScn WHERE Scn = 4893 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4893, 'ENG', 
   @cLine01 = 'SERIALNO - BUILD',
   @cLine03 = 'SKU:',
   @cLine04 = '%20d01',
   @cLine06 = 'INNER SERIALNO:',
   @cLine07 = '%20i02',
   @cLine14 = '%e'   

-- Screen 4
DELETE rdt.RDTScn WHERE Scn = 4894 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4894, 'ENG', 
   @cLine01 = 'SERIALNO - BUILD',
   @cLine03 = 'SKU:',
   @cLine04 = '%20d01',
   @cLine06 = 'MASTER SERIALNO:',
   @cLine07 = '%20i02',
   @cLine14 = '%e'     
      
UPDATE RDT.RDTScn SET Func = 1010 WHERE Scn Between 4890 AND 4899
UPDATE RDT.RDTScnDetail SET Func = 1010 WHERE Scn Between 4890 AND 4899 