-- 6827 CartonType Screen
DELETE rdt.RDTScn WHERE Scn = 6827 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6827, 'ENG'
   ,@cLine01 = 'CartonType:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = '%20i02'
   ,@cLine05 = ''
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"],"2":["3"]}'
   ,@nFunc = 838

-- 6861 = PickSlipNo, DropID screen
DELETE rdt.RDTScn WHERE Scn = 6861 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6861, 'ENG'
   ,@cLine01 = 'PSNO: %10i01'
   ,@cLine02 = ''
   ,@cLine03 = 'FROM DROPID:'
   ,@cLine04 = '%20i02'
   ,@cLine05 = ''
   ,@cLine06 = 'TO DROPID: '
   ,@cLine07 = '%20i03'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1"],"2":["3","4"],"3":["6","7"]}'
   ,@nFunc = 838
