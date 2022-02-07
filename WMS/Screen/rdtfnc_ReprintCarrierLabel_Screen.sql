-- 3060 = From DropID screen
DELETE rdt.RDTScn WHERE Scn = 3060 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3060, 'ENG'
   ,@cLine01 = 'DROPID:'
   ,@cLine02 = '%20i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1792
   
-- 3061 = To DropID screen
DELETE rdt.RDTScn WHERE Scn = 3061 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3061, 'ENG'
   ,@cLine01 = 'DROPID:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = ''
   ,@cLine04 = 'CHILDID:'
   ,@cLine05 = '%20i02'
   ,@cLine06 = ''
   ,@cLine07 = 'REMAIN TO SCAN:'
   ,@cLine08 = '%10d03'
   ,@cLine14 = '%e'
   ,@nFunc = 1792
