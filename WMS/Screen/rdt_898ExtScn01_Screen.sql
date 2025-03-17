-- 6446 = Pallet info screen
DELETE rdt.RDTScn WHERE Scn = 6446 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6446, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'PALLET TYPE: '
   ,@cLine03 = '%20i01'
   ,@cLine04 = ''
   ,@cLine05 = 'WEIGHT: %10i02'
   ,@cLine06 = ''
   ,@cLine07 = 'HEIGHT: %10i03'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["2","3"], "2":["5], "3":["7"]}'
   ,@nFunc = 898
