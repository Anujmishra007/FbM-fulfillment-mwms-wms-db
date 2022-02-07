-- 2340 = DROP ID screen
DELETE rdt.RDTScn WHERE Scn = 2340 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2340, 'ENG',
    @cLine01 = 'STAGING LANE RELEASE'
   ,@cLine03 = 'STAGING LANE:'
   ,@cLine04 = '%10i01'
   ,@cLine14 = '%e'
 

