/*
   KIT Update --1877
*/

IF NOT EXISTS( SELECT 1 FROM rdt.rdtmsg WITH (NOLOCK) WHERE Message_ID = 1877 AND Message_Type = 'FNC' AND Lang_Code = 'ENG')
   INSERT INTO rdt.rdtMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, EventType) 
   VALUES (1877, 'ENG', 'FNC', 'KIT - UPDATE', 'rdtfnc_KIT_Update', 0)
GO

-- 6830 = KIT Key
DELETE rdt.RDTScn WHERE Scn = 6830 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6830, 'ENG', 
   @cLine01 = 'KIT Ticket #:', 
   @cLine02 = '%60i01',  
   @cLine14 = '%e',
   @cWebGroup = '{"1":["1","2"]}',
   @nFunc = 1877

-- 6831 = Pallet ID
DELETE rdt.RDTScn WHERE Scn = 6831 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6831, 'ENG',
   @cLine01 = 'KIT Ticket #:',
   @cLine02 = '%60d01',
   @cLine03 = 'Pallet ID:', 
   @cLine04 = '%60i02',
   @cLine13 = '%20d15', 
   @cLine14 = '%e',
   @cWebGroup = '{"1":["1","2"],"2":["3","4"]  }',
   @nFunc = 1877

-- 6832 = SKU
DELETE rdt.RDTScn WHERE Scn = 6832 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6832, 'ENG',
   @cLine01 = 'KIT Ticket #:',
   @cLine02 = '%60d01',
   @cLine03 = 'Pallet ID:', 
   @cLine04 = '%60d02',
   @cLine05 = 'SKU:', 
   @cLine06 = '%60i03',
   @cLine13 = '%20d15', 
   @cLine14 = '%e',
   @cWebGroup = '{"1":["1","2"],"2":["3","4"],"3":["5","6"]}',
   @nFunc = 1877

-- 6833 = Qty
DELETE rdt.RDTScn WHERE Scn = 6833 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6833, 'ENG',
   @cLine01 = 'KIT Ticket #:',
   @cLine02 = '%60d01',
   @cLine03 = 'Pallet ID:', 
   @cLine04 = '%60d02',
   @cLine05 = 'SKU:', 
   @cLine06 = '%60d03',
   @cLine07 = 'LEFT OVER QTY:', 
   @cLine08 = '%05i04^DT:INT',
   @cLine13 = '%20d15', 
   @cLine14 = '%e',
   @cWebGroup = '{"1":["1","2"],"2":["3","4"] }',
   @nFunc = 1877

-- 6834 = Message screen
DELETE rdt.RDTScn WHERE Scn = 6834 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6834, 'ENG', 
   @cLine02 = 'Successfully Updated', 
   @cLine03 = '', 
   @cLine04 = '',
   @cLine06 = 'Press ENTER or ESC', 
   @cLine07 = 'to Continue',
   @cLine13 = '%20d15',
   @cLine14 = '%e',
   @cAutoDisappear = '1',
   @nFunc = 1877
