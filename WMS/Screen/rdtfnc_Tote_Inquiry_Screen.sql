-- 2180 = Tote # screen
DELETE rdt.RDTScn WHERE Scn = 2180 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2180, 'ENG',
    @cLine01 = 'TOTE #:'
   ,@cLine02 = '%10i01'
   ,@cLine14 = '%e'
 
-- 2181 = Result
DELETE rdt.RDTScn WHERE Scn = 2181 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2181, 'ENG',
    @cLine01 = 'TOTE #: %10d01'
   ,@cLine02 = 'STORE#: %10d02'
   ,@cLine03 = 'STATUS: %10d03'
   ,@cLine04 = 'PICK #: %10d04'
   ,@cLine05 = 'DATE  : %08d05'
   ,@cLine14 = '%e'
 
