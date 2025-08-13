-- 6623 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 6623 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6623, 'ENG',
    @cLine01 = 'UCC:'
   ,@cLine02 = '%20i01'
   ,@cLine03 = ''
   ,@cLine04 = 'Scanned UCC:'
   ,@cLine05 = '%20d02'
   ,@cLine06 = 'UCC Position:'
   ,@cLine07 = '%20d03'
   ,@cLine14 = '%e'
   ,@nFunc = 1825
