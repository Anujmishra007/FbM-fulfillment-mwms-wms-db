--rdtfnc_ScanToTruck_Barry
-- 6580 - 6586

IF NOT EXISTS (SELECT 1 FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID = '927')
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES ('927', 'ENG', 'FNC', 'Floor Check', 'rdtfnc_Floor_Check', '0')

-- Screen 1
-- Scn = 6580 
DELETE rdt.RDTScn WHERE Scn = 6580 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6580, 'ENG', 
   @cLine01 = 'FromLOC:',
   @cLine02 = '%10i01',
   @cLine14 = '%e'

-- Screen 2
-- Scn = 6581 
DELETE rdt.RDTScn WHERE Scn = 6581 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6581, 'ENG', 
   @cLine01 = 'From LOC:',
   @cLine02 = '%10d01',
   @cLine04 = 'From ID:',
   @cLine05 = '%10i02',
   @cLine14 = '%e'
