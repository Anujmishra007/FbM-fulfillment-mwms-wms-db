-- 2670 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2670 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2670, 'ENG',
    @cLine01 = 'C&C TOTE DESPATCH'
   ,@cLine03 = 'TOTE NO:'
   ,@cLine04 = '%10i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1783
 

