-- 879 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 879 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 879, 'ENG',
    @cLine01 = 'Serial No Search'
   ,@cLine03 = 'Serial #:'
   ,@cLine05 = '%30i01' -- (Modified for SOS#315487 - extend field length to 30 char)
   ,@cLine14 = '%e'
 
-- 880 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 880 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 880, 'ENG',
    @cLine01 = 'Serial No Search'
   ,@cLine03 = 'Serial #:'
   ,@cLine04 = '%30d01' -- (Modified for SOS#315487 - extend field length to 30 char)
   ,@cLine05 = 'Order #:'
   ,@cLine06 = '%10d02'
   ,@cLine07 = 'Customer:'
   ,@cLine08 = '%20d03'
   ,@cLine09 = '%20d04'
   ,@cLine10 = 'SKU:'
   ,@cLine11 = '%20d05'
   ,@cLine12 = '%20d06'
   ,@cLine13 = '<enter> - Next SN#'
   ,@cLine14 = '%e'
 
UPDATE RDT.RDTSCN SET FUNC = 872 WHERE SCN BETWEEN 879 AND 880