
-- extscn pickslip
DELETE rdt.RDTScn WHERE Scn = 6675 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6675, 'ENG'
   ,@cLine01 = 'Pickslip No'
   ,@cLine02 = '%20d01'
   ,@cLine03 = ''
   ,@cLine04 = 'Tracking Req:'
   ,@cLine05 = '1 = YES'
   ,@cLine06 = '9 = NO'
   ,@cLine07 = ''
   ,@cLine08 = 'OPTION: %02i02'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"],"2":["4","5","6"],"3":["8"]}'
   ,@nFunc = 832


-- extscn pickslip
DELETE rdt.RDTScn WHERE Scn = 6676 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6676, 'ENG'
   ,@cLine01 = 'Carton ID:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = ''
   ,@cLine04 = 'Different Tracking'
   ,@cLine05 = 'Already Assigned.'
   ,@cLine06 = ''
   ,@cLine07 = 'Overwrite?'
   ,@cLine08 = '1 = YES'
   ,@cLine09 = '9 = NO'
   ,@cLine10 = ''
   ,@cLine11 = 'OPTION: %02i02'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"],"2":["4","5"],"3":["7","8","9"]}'
   ,@nFunc = 832

