-- rdt_1812ExtScn05
-- 6520 = To Lane screen
DELETE rdt.RDTScn WHERE Scn = 6520 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6520, 'ENG',
    @cLine01 = ''
   ,@cLine02 = 'SUGGESTED LANE: '
   ,@cLine03 = '%20d01'
   ,@cLine05 = 'TO LANE: '
   ,@cLine06 = '%20i02'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["2","3"],"2":["5","6"]}'
   ,@nFunc = 1812