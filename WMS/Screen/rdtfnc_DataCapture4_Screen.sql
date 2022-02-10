-- 1770 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1770 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1770, 'ENG',
    @cLine01 = 'LOC: %10i01'
   ,@cLine03 = 'REFERENCE:' -- (ChewKP01) 
   ,@cLine04 = '%20i02' -- (ChewKP01) 
   ,@cLine14 = '%e'
 
-- 1771 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1771 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1771, 'ENG',
    @cLine01 = 'LOC: %10d01'
   ,@cLine02 = 'UCC:'
   ,@cLine03 = '%20i03'
   ,@cLine05 = 'SCAN: %05d04'
   ,@cLine14 = '%e'
 
