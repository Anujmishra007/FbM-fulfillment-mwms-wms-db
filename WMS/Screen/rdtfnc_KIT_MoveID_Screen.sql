/*
   KIT Move ID --1873
*/

IF NOT EXISTS( SELECT 1 FROM rdt.rdtmsg WITH (NOLOCK) WHERE Message_ID = 1873 AND Message_Type = 'FNC' AND Lang_Code = 'ENG')
   INSERT INTO rdt.rdtMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, EventType) 
   VALUES (1873, 'ENG', 'FNC', 'KIT - Pallet Movement', 'rdtfnc_KIT_MoveID', 0)
GO

-- 6740 = FromID
DELETE rdt.RDTScn WHERE Scn = 6740 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6740, 'ENG', 
   @cLine01 = 'Pallet ID:', 
   @cLine02 = '%60i01',  
   @cLine14 = '%e',
   @cWebGroup = '{"1":["1","2"]}',
   @nFunc = 1873

-- 6741 = Move to
DELETE rdt.RDTScn WHERE Scn = 6741 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6741, 'ENG',
   @cLine01 = 'Pallet ID:', 
   @cLine02 = '%18d01',
   @cLine03 = 'To LOC:', 
   @cLine04 = '%10i02',
   @cLine13 = '%20d15', 
   @cLine14 = '%e',
   @cWebGroup = '{"1":["1","2"],"2":["3","4","5"],"3":["13"]}',
   @nFunc = 1873

-- 6742 = Message screen
DELETE rdt.RDTScn WHERE Scn = 6742 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6742, 'ENG', 
   @cLine02 = 'Pallet moved', 
   @cLine03 = 'successfully', 
   @cLine04 = '',
   @cLine06 = 'Press ENTER or ESC', 
   @cLine07 = 'to continue',
   @cLine14 = '%e',
   @cAutoDisappear = '1',
   @nFunc = 1873
