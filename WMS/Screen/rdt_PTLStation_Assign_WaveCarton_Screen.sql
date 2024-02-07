
-- 4495 = Wave, LOC, carton ID screen
DELETE rdt.RDTScn WHERE Scn = 4495 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4495, 'ENG'
   ,@cLine01 = N'WAVEKEY:       %05d05'
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
   ,@cWebGroup = '{"1":["1","2"],"2":["4","5"],"3":["7","8"],"4":["10","11"]}'
   ,@nFunc = 805