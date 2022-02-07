
-- Wave, carton, carton
DELETE rdt.RDTScn WHERE Scn = 4603 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4603, 'ENG'
   ,@cLine01 = 'LoadKey:'
   ,@cLine02 = '%20i01'
   ,@cLine03 = 'ORDERKEY:      %05d05'
   ,@cLine04 = '%10d02'
   ,@cLine05 = ''
   ,@cLine06 = 'POSITION:'
   ,@cLine07 = '%10d03'
   ,@cLine08 = ''
   ,@cLine09 = 'CARTON ID:     %05d06'
   ,@cLine10 = '%20i04'
   ,@cLine14 = '%e'
   ,@nFunc = 805
