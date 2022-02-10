IF NOT EXISTS( SELECT 1 FROM rdt.rdtmsg WITH (NOLOCK) WHERE Message_ID = 745 AND Message_Type = 'FNC')
   INSERT INTO rdt.rdtMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, EventType) 
   VALUES (745, 'ENG', 'FNC', 'Putaway LOC SKU', 'rdtfnc_PutawayByLOCSKU', 0)
GO

-- 5570 = LOC
DELETE rdt.RDTScn WHERE Scn = 5570 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5570, 'ENG'
   ,@cLine01 = 'LOC: %10i01'
   ,@cLine14 = '%e'
   ,@nFunc = 745
 
-- 5571 = SKU
DELETE rdt.RDTScn WHERE Scn = 5571 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5571, 'ENG'
   ,@cLine01 = 'LOC: %10d01'
   ,@cLine02 = ''
   ,@cLine03 = 'SKU/UPC:'
   ,@cLine04 = '%60i02'
   ,@cLine14 = '%e'
   ,@nFunc = 745

-- 5572 = Suggested LOC, final LOC
DELETE rdt.RDTScn WHERE Scn = 5572 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5572, 'ENG'
   ,@cLine01 = 'SKU:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = '%20d02'
   ,@cLine04 = '%20d03'
   ,@cLine05 = ''
   ,@cLine06 = 'QTY: %05d04'
   ,@cLine07 = ''
   ,@cLine08 = 'SUGGESTED LOC:'
   ,@cLine09 = '%10d05'
   ,@cLine10 = ''
   ,@cLine11 = 'FINAL LOC:'
   ,@cLine12 = '%10i06'
   ,@cLine14 = '%e'
   ,@nFunc = 745
   
-- 5573 = Successful message
DELETE rdt.RDTScn WHERE Scn = 5573 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5573, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'Successful putaway'
   ,@cLine03 = ''
   ,@cLine04 = ''
   ,@cLine05 = 'Press ENTER to'
   ,@cLine06 = 'putaway next item'
   ,@cLine14 = '%e'
   ,@nFunc = 745

-- 5574 = LOC not match
DELETE rdt.RDTScn WHERE Scn = 5574 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5574, 'ENG', 
   @cLine01 = '',
   @cLine02 = 'LOC NOT MATCH.',
   @cLine03 = 'PROCEED?',
   @cLine04 = '',
   @cLine05 = '1 = YES',
   @cLine06 = '2 = NO',
   @cLine07 = '',
   @cLine08 = 'OPTION: %01i01',
   @cLine14 = '%e',     
   @nFunc   = 745