/*
   ECOM QA Batch
*/
IF NOT EXISTS( SELECT 1 FROM rdt.rdtMsg WITH (NOLOCK) WHERE Message_ID = '650' AND Message_Type = 'FNC' AND Lang_Code = 'ENG')
   INSERT INTO rdt.rdtMsg (Message_ID, Message_Type, Lang_Code, Message_Text, StoredProcName, EventType)
   VALUES (650, 'FNC', 'ENG', 'ECOM QA BATCH', 'rdtfnc_ECOMQABatch', 3)
GO

-- 6040 = BatchNo
DELETE rdt.RDTScn WHERE Scn = 6040 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6040, 'ENG',
   @cLine01 = 'BATCHNO: ',
   @cLine02 = '%10i01',
   @cLine03 = '',
   @cLine04 = 'STATION:',
   @cLine05 = '%10i02',
   @cLine14 = '%e',
   @nFunc = 650

-- 6041 = SKU
DELETE rdt.RDTScn WHERE Scn = 6041 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6041, 'ENG',
   @cLine01 = 'BATCHNO: ',
   @cLine02 = '%10d01',
   @cLine03 = '',
   @cLine04 = 'SKU/UPC:     PPK:%03d07',
   @cLine05 = '%60i02',
   @cLine06 = '%20d04',
   @cLine07 = '%20d05',
   @cLine08 = '%20d06',
   @cLine09 = '',
   @cLine10 = 'SKU: %05d08',
   @cLine11 = 'QTY: %05D09',
   @cLine13 = '%20d15',
   @cLine14 = '%e',
   @nFunc = 650

-- 6042 = Confirm QA
DELETE rdt.RDTScn WHERE Scn = 6042 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6042, 'ENG',
   @cLine01 = '',
   @cLine02 = 'CONFIRM QA?',
   @cLine03 = '',
   @cLine04 = '1 = YES (PARTIAL)', 
   @cLine05 = '9 = NO  (RESET)', 
   @cLine06 = '',
   @cLine07 = 'OPTION: %01i01',
   @cLine08 = '',
   @cLine09 = '',
   @cLine10 = 'SKU: %05d02',
   @cLine11 = 'QTY: %05d03',
   @cLine14 = '%e',
   @nFunc = 650
