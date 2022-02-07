/*
   Move SKU
*/
IF NOT EXISTS( SELECT 1 FROM rdt.rdtMsg WITH (NOLOCK) WHERE Message_ID = '617' AND Message_Type = 'FNC' AND Lang_Code = 'ENG')
   INSERT INTO rdt.rdtMsg (Message_ID, Message_Type, Lang_Code, Message_Text, StoredProcName, EventType)
   VALUES (617, 'FNC', 'ENG', 'MOVE TO LOC', 'rdtfnc_MoveToLOC', 3)
GO

-- 6000 = From LOC
DELETE rdt.RDTScn WHERE Scn = 6000 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6000, 'ENG',
   @cLine01 = 'FROM LOC: %10i01',
   @cLine14 = '%e',
   @nFunc = 617

-- 6001 = From ID
DELETE rdt.RDTScn WHERE Scn = 6001 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6001, 'ENG',
   @cLine01 = 'FROM LOC: %10d01',
   @cLine02 = 'FROM ID:',
   @cLine03 = '%20i02',
   @cLine14 = '%e',
   @nFunc = 617

-- 6002 = To LOC
DELETE rdt.RDTScn WHERE Scn = 6002 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6002, 'ENG',
   @cLine01 = 'FROM LOC: %10d01',
   @cLine02 = 'FROM ID:',
   @cLine03 = '%18d02',
   @cLine04 = '', 
   @cLine05 = 'TO LOC: %10i03',
   @cLine14 = '%e',
   @nFunc = 617
   
-- 6003 = To ID
DELETE rdt.RDTScn WHERE Scn = 6003 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6003, 'ENG',
   @cLine01 = 'FROM LOC: %10d01',
   @cLine02 = 'FROM ID:',
   @cLine03 = '%18d02',
   @cLine04 = '', 
   @cLine05 = 'TO LOC: %10i03',
   @cLine06 = 'TO ID:',
   @cLine07 = '%20i04',
   @cLine14 = '%e',
   @nFunc = 617
   
-- 6004 = SKU
DELETE rdt.RDTScn WHERE Scn = 6004 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6004, 'ENG',
   @cLine01 = 'TO LOC: %10d01',
   @cLine02 = 'TO ID:',
   @cLine03 = '%18d02',
   @cLine04 = 'SKU/UPC:     PPK:%03d07',
   @cLine05 = '%60i03',
   @cLine06 = '%20d04',
   @cLine07 = '%20d05',
   @cLine08 = '%20d06',
   @cLine09 = '',
   @cLine10 = 'SKU: %05d08',
   @cLine11 = 'QTY: %05D09',
   @cLine13 = '%20d15',
   @cLine14 = '%e',
   @nFunc = 617
   
-- 6005 = Confirm
DELETE rdt.RDTScn WHERE Scn = 6005 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6005, 'ENG',
   @cLine01 = '',
   @cLine02 = 'CONFIRM MOVE?',
   @cLine03 = '',
   @cLine04 = '1 = YES', 
   @cLine05 = '9 = NO',
   @cLine06 = '',
   @cLine07 = 'OPTION: %01i01',
   @cLine08 = '',
   @cLine09 = '',
   @cLine10 = 'SKU: %05d02',
   @cLine11 = 'QTY: %05d03',
   @cLine14 = '%e',
   @nFunc = 617
