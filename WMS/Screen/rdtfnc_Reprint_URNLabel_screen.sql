-- 2050 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2050 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2050, 'ENG',
    @cLine01 = 'CASE ID:'
   ,@cLine02 = '%10i01'
   ,@cLine03 = 'OR'
   ,@cLine04 = 'URN LABEL:'
   ,@cLine05 = '%32i02'
   ,@cLine14 = '%e'


