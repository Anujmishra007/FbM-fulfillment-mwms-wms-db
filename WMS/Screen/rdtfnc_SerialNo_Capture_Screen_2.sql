--rdtfnc_SerialNo_RePrint
-- 4880 - 4889


INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
VALUES ('1009', 'ENG', 'FNC', 'SerialNo RePrint', 'rdtfnc_SerialNo_RePrint', '0')

-- Screen 1
-- Scn = 4880 
DELETE rdt.RDTScn WHERE Scn = 4880 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4880, 'ENG', 
   @cLine01 = 'SERIALNO - REPRINT',
   @cLine03 = 'WORKORDER NO:',
   @cLine04 = '%10i01',
   @cLine14 = '%e'
   
DELETE rdt.RDTScn WHERE Scn = 4881 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4881, 'ENG', 
   @cLine01 = 'SERIALNO - REPRINT',
   @cLine03 = 'SERIAL NO:',
   @cLine04 = '%20i01',
   @cLine14 = '%e'


      
UPDATE RDT.RDTScn SET Func = 1009 WHERE Scn Between 4880 AND 4889
UPDATE RDT.RDTScnDetail SET Func = 1009 WHERE Scn Between 4880 AND 4889 