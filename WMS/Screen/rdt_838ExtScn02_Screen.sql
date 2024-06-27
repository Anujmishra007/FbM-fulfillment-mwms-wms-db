-- 6385 = CartonNo Screen
DELETE rdt.RDTScn WHERE Scn = 6385 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6385, 'ENG'
   ,@cLine01 = 'Carton No:'
   ,@cLine02 = '%20i02'
   ,@cLine03 = ''
   ,@cLine04 = ''
   ,@cLine05 = ''
   ,@cLine06 = ''
   ,@cLine07 = ''
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"],"2":["3","4"],"3":["6","7"]}'
   ,@nFunc = 838
