
-- Station, position, carton
--DELETE rdt.RDTScn WHERE Scn = 4495 AND Lang_Code = 'ENG'
--EXECUTE rdt.rdtAddScn 4495, 'ENG'
--   ,@cLine01 = 'WAVEKEY:'
--   ,@cLine02 = '%10i01'
--   ,@cLine03 = ''
--   ,@cLine04 = ''
--   ,@cLine05 = ''
--   ,@cLine06 = ''
--   ,@cLine07 = ''
--   ,@cLine08 = ''
--   ,@cLine09 = ''
--   ,@cLine10 = ''
--   ,@cLine11 = ''
--   ,@cLine14 = '%e'
--   ,@nFunc = 805


--DELETE rdt.RDTScn WHERE Scn = 4495 AND Lang_Code = 'ENG'
--EXECUTE rdt.rdtAddScn 4495, 'ENG'
--   ,@cLine01 = 'WAVEKEY:'
--   ,@cLine02 = '%10i01'
--   ,@cLine03 = ''
--   ,@cLine04 = ''
--   ,@cLine05 = ''
--   ,@cLine06 = 'ORDERKEY:'
--   ,@cLine07 = '%10d02'
--   ,@cLine08 = 'POSITION:'
--   ,@cLine09 = '%10d03'
--   ,@cLine10 = 'CARTON ID:     %05d04'
--   ,@cLine11 = '%20i05'
--   ,@cLine14 = '%e'
--   ,@nFunc = 805
   
-- Order, station, position, carton
--DELETE rdt.RDTScn WHERE Scn = 4495 AND Lang_Code = 'ENG'
--EXECUTE rdt.rdtAddScn 4495, 'ENG'
--   ,@cLine01 = 'WAVEKEY:      %05d05'
--   ,@cLine02 = '%10i01'
--   ,@cLine03 = ''
--   ,@cLine04 = 'ORDERKEY:'
--   ,@cLine05 = '%10d02'
--   ,@cLine06 = ''
--   ,@cLine07 = 'POSITION:'
--   ,@cLine08 = '%10d03'
--   ,@cLine09 = ''
--   ,@cLine10 = 'CARTON ID:     %05d06'
--   ,@cLine11 = '%20i04'
--   ,@cLine14 = '%e'
--   ,@nFunc = 805
   
-- 4492 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4495 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4495, 'ENG'
   ,@cLine01 = N'WaveKey:       %05d05'
   ,@cLine02 = N'%10i01'
   ,@cLine03 = N''
   ,@cLine04 = N'STATION:'
   ,@cLine05 = N'%10d02'
   ,@cLine06 = N''
   ,@cLine07 = N'LOCATION:      '
   ,@cLine08 = N'%10i03'
   ,@cLine09 = N''
   ,@cLine10 = N'CARTON ID:     %05d06'
   ,@cLine11 = N'%20i04'
   ,@cLine14 = N'%e'
 
   