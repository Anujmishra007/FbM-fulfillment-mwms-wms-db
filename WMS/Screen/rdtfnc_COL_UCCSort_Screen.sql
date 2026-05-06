/*
    --1874
*/

IF NOT EXISTS( SELECT 1 FROM rdt.rdtmsg WITH (NOLOCK) WHERE Message_ID = 1874 AND Message_Type = 'FNC' AND Lang_Code = 'ENG')
   INSERT INTO rdt.rdtMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, EventType) 
   VALUES (1874, 'ENG', 'FNC', 'COL - UCC Carton Sort', 'rdtfnc_COL_UCCSort', 0)
GO

-- 6760 
DELETE rdt.RDTScn WHERE Scn = 6760 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6760, 'ENG', 
   @cLine01 = 'Carton:', 
   @cLine02 = '%1000iV_Max',  
   @cLine14 = '%e',
   @cWebGroup = '{"1":["1","2"]}',
   @nFunc = 1874

-- 6761 
DELETE rdt.RDTScn WHERE Scn = 6761 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6761, 'ENG',
   @cLine01 = 'Suggested Loc Type:', 
   @cLine02 = '%20d01',
   @cLine03 = '%10i02', 
   @cLine14 = '%e',
   @cWebGroup = '{"1":["1","2","3"]}',
   @nFunc = 1874
