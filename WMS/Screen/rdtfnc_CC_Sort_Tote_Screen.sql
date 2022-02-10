-- 2660 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2660 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2660, 'ENG',
    @cLine01 = 'C&C TOTE SORT'
   ,@cLine03 = 'LABEL NO:'
   ,@cLine04 = '%20i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1782
 
-- 2661 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2661 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2661, 'ENG',
    @cLine01 = 'C&C TOTE SORT'
   ,@cLine03 = 'LABEL NO:'
   ,@cLine04 = '%20d01'
   ,@cLine05 = 'STORE'
   ,@cLine06 = '%15d02'
   ,@cLine07 = 'TOTE NO:'
   ,@cLine08 = '%10i03'
   ,@cLine10 = 'TOTE FULL ?'
   ,@cLine11 = '1 = YES 9 = NO'
   ,@cLine12 = '%01i04'
   ,@cLine14 = '%e'
   ,@nFunc = 1782
