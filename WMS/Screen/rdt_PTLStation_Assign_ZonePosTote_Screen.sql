-- 4498 = OrderKey, station, position, carton ID screen
DELETE rdt.RDTScn WHERE Scn = 4498 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4498, 'ENG'
   ,@cLine01 = 'WAVEKEY:'
   ,@cLine02 = '%10i01'
   ,@cLine03 = ''
   ,@cLine04 = 'STATION:'
   ,@cLine05 = '%10d02'
   ,@cLine06 = ''
   ,@cLine07 = 'LOCATION:    %02d05'
   ,@cLine08 = '%10i03'
   ,@cLine09 = ''
   ,@cLine10 = 'CARTON ID:'
   ,@cLine11 = '%20i04'
   ,@cLine14 = '%e'
   ,@nFunc = 805
 