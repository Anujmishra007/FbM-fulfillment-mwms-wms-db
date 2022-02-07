--rdtfnc_SerialNo_Serialize
-- 5010 - 5019


INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
VALUES ('1016', 'ENG', 'FNC', 'Serialization Single', 'rdtfnc_SerialNo_Single', '0')

-- Screen 1
DELETE rdt.RDTScn WHERE Scn = 5010 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5010, 'ENG', 
   @cLine01 = 'SERIALNO SINGLE',
   @cLine03 = 'WORKORDER NO:',
   @cLine04 = '%10i01',
   @cLine14 = '%e'

-- Screen 2
DELETE rdt.RDTScn WHERE Scn = 5011 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5011, 'ENG', 
   @cLine01 = 'SERIALNO SINGLE',
   @cLine03 = 'SKU:',
   @cLine04 = '%20d01',
   @cLine05 = '%20d02',
   @cLine06 = '%20d03',
   @cLine08 = 'MASTER SERIALNO:',
   @cLine09 = '%20i04',
   @cLine14 = '%e'

-- Screen 3
DELETE rdt.RDTScn WHERE Scn = 5012 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5012, 'ENG', 
   @cLine01 = 'SERIALNO SINGLE',
   @cLine03 = 'SKU:',
   @cLine04 = '%20d01',
   @cLine05 = '%20d02',
   @cLine06 = '%20d03',
   @cLine07 = 'CHILD SERIALNO:',
   @cLine08 = '%40i04',
   @cLine10 = 'SCAN COUNT',
   @cLine11 = '%20d05',
   @cLine14 = '%e'

-- Screen 4
DELETE rdt.RDTScn WHERE Scn = 5013 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5013, 'ENG', 
   @cLine01 = 'SERIALNO SINGLE',
   @cLine03 = 'SKU:',
   @cLine04 = '%20d01',
   @cLine06 = 'ACTION:',
   @cLine07 = '1 = CONFIRM SHORT',
   @cLine08 = '9 = EXIT SCAN',
   @cLine10 = 'OPTION: %01i02',
   @cLine14 = '%e'   
      
UPDATE RDT.RDTScn SET Func = 1016 WHERE Scn Between 5010 AND 5019
UPDATE RDT.RDTScnDetail SET Func = 1016 WHERE Scn Between 5010 AND 5019 