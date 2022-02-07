-- 2160 = TRLR ID screen
DELETE rdt.RDTScn WHERE Scn = 2160 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2160, 'ENG',
    @cLine01 = 'TRLR ID'
   ,@cLine02 = '%10i01'
   ,@cLine14 = '%e'
 
-- 2161 = TRLR ID, Store 
DELETE rdt.RDTScn WHERE Scn = 2161 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2161, 'ENG',
    @cLine01 = 'TRLR ID:'
   ,@cLine02 = '%10d01'
   ,@cLine03 = 'STORE #:'
   ,@cLine04 = '%10i02'
   ,@cLine14 = '%e'
 
-- 2162 = TRLR ID, Store, Tote
DELETE rdt.RDTScn WHERE Scn = 2162 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2162, 'ENG',
    @cLine01 = 'TRLRID: %10d01'
   ,@cLine02 = 'STORE#: %10d02'
   ,@cLine03 = 'TOTE# : %10i03'
   ,@cLine04 = '%05d04'
   ,@cLine14 = '%e'