-- 6893 = Condition Code
DELETE rdt.RDTScn WHERE Scn = 6893 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6893, 'ENG'
   ,@cLine01 = 'UCC:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = ''
   ,@cLine04 = 'COND CODE:'
   ,@cLine05 = '%30i02'
   ,@cLine06 = ''
   ,@cLine07 = ''
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2","3"], "2":["4"]}'
   ,@nFunc = 898
