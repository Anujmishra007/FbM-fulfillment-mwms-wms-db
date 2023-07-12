
-- Drop ID, carton ID
DELETE rdt.RDTScn WHERE Scn = 6162 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6162, 'ENG'
   ,@cLine01 = 'DROP ID:'
   ,@cLine02 = '%20i01'
   ,@cLine03 = ''
   ,@cLine04 = 'ORDERKEY:      %05d05'
   ,@cLine05 = '%10d02'
   ,@cLine06 = ''
   ,@cLine07 = 'POSITION:'
   ,@cLine08 = '%10d03'
   ,@cLine09 = ''
   ,@cLine10 = 'CARTON ID:     %05d06'
   ,@cLine11 = '%20i04'
   ,@cLine14 = '%e'
   ,@nFunc = 805
