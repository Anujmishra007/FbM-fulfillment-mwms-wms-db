-- 5200 = ID screen
DELETE rdt.RDTScn WHERE Scn = 5200 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5200, 'ENG'
   ,@cLine01 = 'CARTON ID:'
   ,@cLine02 = '%20i01'
   ,@cLine14 = '%e'
   ,@nFunc = 881

-- 5201 = Info screen
DELETE rdt.RDTScn WHERE Scn = 5201 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5201, 'ENG'
   ,@cLine01 = 'CARTON ID:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = ''
   ,@cLine04 = 'TOTAL SKU: %05d02'
   ,@cLine05 = ''
   ,@cLine06 = 'QTY SHORT: %05d03'
   ,@cLine07 = 'QTY ALLOC: %05d04'
   ,@cLine08 = 'QTY PICK:  %05d05'
   ,@cLine09 = ''
   ,@cLine10 = 'PRESS ENTER TO'
   ,@cLine11 = 'CONFIRM SHORT PICK'
   ,@cLine14 = '%e'
   ,@nFunc = 881

-- 5202 = Option screen
DELETE rdt.RDTScn WHERE Scn = 5202 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5202, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'CONFIRM SHORT PICK?'
   ,@cLine03 = ''
   ,@cLine04 = '1 = YES'
   ,@cLine05 = '9 = NO'
   ,@cLine06 = ''
   ,@cLine07 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 881
