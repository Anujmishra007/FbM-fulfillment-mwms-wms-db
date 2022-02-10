--rdtfnc_SerialNo_Bundle
-- 5020 - 5029


INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
VALUES ('1017', 'ENG', 'FNC', 'Serialization Bundle', 'rdtfnc_SerialNo_Bundle', '0')

-- Screen 1
DELETE rdt.RDTScn WHERE Scn = 5020 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5020, 'ENG', 
   @cLine01 = 'SERIALNO BUNDLE',
   @cLine03 = 'WORKORDER NO:',
   @cLine04 = '%20i01',
   @cLine14 = '%e'

-- Screen 2
DELETE rdt.RDTScn WHERE Scn = 5021 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5021, 'ENG', 
   @cLine01 = 'SERIALNO BUNDLE',
   @cLine03 = 'WORKORDER NO:',
   @cLine04 = '%10d01',
   @cLine08 = 'MASTER SERIALNO:',
   @cLine09 = '%20i02',
   @cLine14 = '%e'

-- Screen 3
DELETE rdt.RDTScn WHERE Scn = 5022 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5022, 'ENG', 
   @cLine01 = 'SERIALNO BUNDLE',
   @cLine03 = 'MASTER SERIALNO:',
   @cLine04 = '%20d01',
   @cLine05 = 'BOM SKU:',
   @cLine06 = '%20d02',
   @cLine07 = '%20d03',
   @cLine08 = '%20d04',
   @cLine09 = 'BOM SERIALNO:',
   @cLine10 = '%20i05',
   @cLine11 = 'SCAN COUNT',
   @cLine12 = '%20d06',
   @cLine14 = '%e'

-- Screen 4
DELETE rdt.RDTScn WHERE Scn = 5023 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5023, 'ENG', 
   @cLine01 = 'SERIALNO BUNDLE',
   @cLine03 = 'MASTER SERIALNO:',
   @cLine04 = '%20d01',
   @cLine05 = 'BOM SKU:',
   @cLine06 = '%20d02',
   @cLine07 = 'BOM SERIALNO:',
   @cLine08 = '%20d03',
   @cLine09 = 'CHILD SERIALNO:',
   @cLine10 = '%60i04',
   @cLine11 = 'SCAN COUNT',
   @cLine12 = '%20d05',
   @cLine14 = '%e'   
   
-- Screen 5
DELETE rdt.RDTScn WHERE Scn = 5024 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5024, 'ENG', 
   @cLine01 = 'SERIALNO BUNDLE',
   @cLine03 = 'SKU:',
   @cLine04 = '%20d01',
   @cLine06 = 'ACTION:',
   @cLine07 = '1 = CONFIRM SHORT',
   @cLine08 = '9 = EXIT SCAN',
   @cLine10 = 'OPTION: %01i02',
   @cLine14 = '%e'  
   
      
UPDATE RDT.RDTScn SET Func = 1017 WHERE Scn Between 5020 AND 5029
UPDATE RDT.RDTScnDetail SET Func = 1017 WHERE Scn Between 5020 AND 5029 