
-- Station, position, carton
DELETE rdt.RDTScn WHERE Scn = 4492 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4492, 'ENG'
   ,@cLine01 = 'LOADKEY:       %05d05'
   ,@cLine02 = '%10i01'
   ,@cLine03 = ''
   ,@cLine04 = 'STATION:'
   ,@cLine05 = '%10d02'
   ,@cLine06 = ''
   ,@cLine07 = 'POSITION:      '
   ,@cLine08 = '%10d03'
   ,@cLine09 = ''
   ,@cLine10 = 'CARTON ID:     %05d06'
   ,@cLine11 = '%20i04'
   ,@cLine14 = '%e'
   ,@nFunc = 805
