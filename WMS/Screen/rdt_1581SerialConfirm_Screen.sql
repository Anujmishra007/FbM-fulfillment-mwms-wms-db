-- 1581 
DELETE rdt.RDTScn WHERE Scn = 6413 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6413, 'ENG'
   ,@cLine01 = 'SERIAL NO:'
   ,@cLine02 = '%30d01'
   ,@cLine03 = ''
   ,@cLine04 = 'INVALID SERIAL NO'
   ,@cLine05 = 'CONFIRM?'
   ,@cLine06 = ''
   ,@cLine07 = '1 = YES'
   ,@cLine08 = '9 = NO'
   ,@cLine10 = 'OPTION: %1i02'
   ,@cLine14 = '%e'
   ,@nFunc = 1581
   

