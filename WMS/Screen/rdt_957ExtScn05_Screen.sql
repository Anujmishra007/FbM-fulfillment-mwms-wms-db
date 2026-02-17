-- 6523 = Confirm Short
DELETE rdt.RDTScn WHERE Scn = 6469 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6469, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'Short the Pick by%05d02Cases?'
   ,@cLine03 = ''
   ,@cLine04 = '1 = YES'
   ,@cLine05 = '0 = NO'
   ,@cLine06 = '9 = Reallocation'
   ,@cLine08 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 957
