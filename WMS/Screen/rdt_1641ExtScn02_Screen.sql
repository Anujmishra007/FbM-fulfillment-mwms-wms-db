-- rdt_1641ExtScn02
-- FCR-10354
-- 6825 = From Drop ID Screen
DELETE rdt.RDTScn WHERE Scn = 6825 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6825, 'ENG',
    @cLine01 = 'From Drop ID:'
   ,@cLine02 = '%20i01'
   ,@cLine03 = ''
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"]}'
   ,@nFunc = 1641

-- 6826 = From Drop ID Detail Screen
DELETE rdt.RDTScn WHERE Scn = 6826 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6826, 'ENG',
    @cLine01 = 'From Drop ID:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = ''
   ,@cLine05 = 'Shipping VAS Task '
   ,@cLine06 = 'Code: '
   ,@cLine07 = '%20d02'
   ,@cLine08 = ''
   ,@cLine09 = 'Shipping VAS Task '
   ,@cLine10 = 'Description: '
   ,@cLine11 = '%20d03'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"],"2":["5","6","7"],"3":["9","10","11"]}'
   ,@nFunc = 1641