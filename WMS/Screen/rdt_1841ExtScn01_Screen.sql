--  FCR-9027
-- 6705 = Carton ID screen
DELETE rdt.RDTScn WHERE Scn = 6705 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6705, 'ENG',
    @cLine01 = 'ASN:  %10d01'
   ,@cLine02 = 'LANE: %10d02'
   ,@cLine03 = 'UCC:'
   ,@cLine04 = '%20d03'
   ,@cLine05 = 'CARTON ID:'
   ,@cLine06 = '%20i04'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1"],"2":["2"],"3":["3","4"],"4":["5","6"]}'
   ,@nFunc = 1841
