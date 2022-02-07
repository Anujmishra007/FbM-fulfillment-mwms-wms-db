--rdtfnc_TMS_ScanOrder
-- 4570 - 4579


INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
VALUES ('1185', 'ENG', 'FNC', 'TMS Scan Order', 'rdtfnc_TMS_ScanOrder', '0')

-- Screen 1
-- Scn = 4570 
DELETE rdt.RDTScn WHERE Scn = 4570 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4570, 'ENG', 
   @cLine01 = 'TMS SCAN ORDER',
   @cLine03 = 'CARRIER CODE:',
   @cLine04 = '%10i01',
   @cLine14 = '%e'

-- Screen 2
DELETE rdt.RDTScn WHERE Scn = 4571 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4571, 'ENG', 
   @cLine01 = 'TMS SCAN ORDER',
   @cLine03 = 'ORDER NO:',
   @cLine04 = '%10i01',
   @cLine06 = 'ORDER COUNT: %05d02',
   @cLine08 = '1 = SCAN CARTON',
   @cLine09 = 'OPTION: %01i03',
   @cLine14 = '%e'
   
   
-- Screen 3
DELETE rdt.RDTScn WHERE Scn = 4572 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4572, 'ENG', 
   @cLine01 = 'TMS SCAN ORDER',
   @cLine03 = 'ORDER NO:',
   @cLine04 = '%10d01',
   @cLine05 = 'CARTON NO:',
   @cLine06 = '%20i02',
   @cLine08 = 'CTN COUNT: %05d03',
   @cLine14 = '%e'
   
-- Screen 4
DELETE rdt.RDTScn WHERE Scn = 4573 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4573, 'ENG', 
   @cLine01 = 'TMS SCAN ORDER',
   @cLine03 = 'ORDER NO:',
   @cLine04 = '%10d01',
   @cLine05 = 'CARTON NO:',
   @cLine06 = '%20d02',
   @cLine08 = '1 = ACCEPT CARTON',
   @cLine09 = '9 = REJECT CARTON',
   @cLine10 = 'OPTION: %01i03',
   @cLine14 = '%e'   

      
UPDATE RDT.RDTScn SET Func = 1185 WHERE Scn Between 4570 AND 4579 