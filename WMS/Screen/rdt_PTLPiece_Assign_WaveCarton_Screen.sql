
-- Wave, carton, carton
DELETE rdt.RDTScn WHERE Scn = 4601 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4601, 'ENG'
   ,@cLine01 = 'WAVEKEY: %10i01'
   ,@cLine02 = ''
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
