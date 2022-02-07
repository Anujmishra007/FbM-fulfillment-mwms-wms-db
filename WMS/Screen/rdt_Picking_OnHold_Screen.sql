-- 4790 = Picking on hold screen
DELETE rdt.RDTScn WHERE Scn = 4790 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4790, 'ENG',
    @cLine04 = 'PICKING ON HOLD'
   ,@cLine06 = 'PRESS %02d01 TO UNHOLD'
   ,@cLine14 = '%e' 