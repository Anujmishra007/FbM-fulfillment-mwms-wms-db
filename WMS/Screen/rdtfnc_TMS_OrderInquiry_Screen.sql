--rdtfnc_TMS_OrderInquiry
-- 4630 - 4639


INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
VALUES ('1186', 'ENG', 'FNC', 'TMS Order Inquiry', 'rdtfnc_TMS_OrderInquiry', '0')

-- Screen 1
-- Scn = 4570 
DELETE rdt.RDTScn WHERE Scn = 4630 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4630, 'ENG', 
   @cLine01 = 'TMS INQUIRY',
   @cLine03 = 'CARRIER CODE:',
   @cLine04 = '%10i01',
   @cLine14 = '%e'

-- Screen 2
DELETE rdt.RDTScn WHERE Scn = 4631 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4631, 'ENG', 
   @cLine01 = 'TMS INQUIRY %02d11/%02d12',
   @cLine03 = 'ORDER NO: %10d01',
   @cLine04 = 'TTL ORDER: %05d02',
   @cLine05 = 'TTL CARTON NO: %05d03',
   @cLine06 = ' %20d04',
   @cLine07 = ' %20d05',
   @cLine08 = ' %20d06',
   @cLine09 = ' %20d07',
   @cLine10 = ' %20d08',
   @cLine11 = ' %20d09',
   @cLine12 = ' %20d10',
   @cLine14 = '%e'
   
   

      
UPDATE RDT.RDTScn SET Func = 1186 WHERE Scn Between 4630 AND 4639 