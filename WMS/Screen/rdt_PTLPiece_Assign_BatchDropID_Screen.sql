
-- Batch, position, drop ID
DELETE rdt.RDTScn WHERE Scn = 4603 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4603, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'BATCH:       %05d04'
   ,@cLine03 = '%20i01'
   ,@cLine04 = ''
   ,@cLine05 = 'POSITION:'
   ,@cLine06 = '%10d02'
   ,@cLine07 = ''
   ,@cLine08 = 'DROP ID:     %05d05'
   ,@cLine09 = '%20i03'
   ,@cLine14 = '%e'
   ,@nFunc = 803
