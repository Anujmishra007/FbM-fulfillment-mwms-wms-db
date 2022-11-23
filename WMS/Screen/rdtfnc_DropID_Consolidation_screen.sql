
if NOT EXISTS (SELECT 1 from rdt.rdtmsg (nolock) where message_id='992')
begin
   INSERT INTO rdt.rdtmsg (Message_ID,Message_Text,Message_Type,Lang_Code,StoredProcName)
   values('992','DropID Consolidation','FNC','ENG','rdtfnc_DropID_Consolidation')
end

-- rdtfnc_Pick_Consolidation
-- 3790 - 3799
DELETE rdt.rdtscn Where Scn = 6110 AND Lang_code = 'ENG'
EXECUTE rdt.rdtAddScn 6110, 'ENG',
   @cLine01 = 'DropID:',
   @cLine02 = '%20i01', 
   @cLine03 = 'PICK ZONE: %10i02', 
   @cLine04 = 'Loc: %10i03', 
   @cLine14 = '%e',
   @nFunc = 992

DELETE rdt.rdtscn Where Scn = 6111 AND Lang_code = 'ENG'
EXECUTE rdt.rdtAddScn 6111, 'ENG',
   @cLine01 = 'DropID:',
   @cLine02 = '%20d01', 
   @cLine03 = 'PICK ZONE: %10d02', 
   @cLine04 = 'Loc: %10d03', 
   @cLine07 = 'Loc had consolidation', 
   @cLine08 = '%20d04', 
   @cLine14 = '%e',
   @nFunc = 992