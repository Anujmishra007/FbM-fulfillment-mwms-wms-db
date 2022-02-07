-- 2150 = Tote# screen
DELETE rdt.RDTScn WHERE Scn = 2150 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2150, 'ENG',
    @cLine01 = 'TOTE #'
   ,@cLine02 = '%10i01'
   ,@cLine14 = '%e'
 
-- 2151 = Tote#, Store  screen
DELETE rdt.RDTScn WHERE Scn = 2151 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2151, 'ENG',
    @cLine01 = 'TOTE # :'
   ,@cLine02 = '%10d01'
   ,@cLine03 = 'STORE #:'
   ,@cLine04 = '%10i02'
   ,@cLine14 = '%e'
 
