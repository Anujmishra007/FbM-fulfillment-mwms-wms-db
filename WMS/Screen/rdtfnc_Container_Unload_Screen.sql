-- 2137 = Container no/appointment no screen
DELETE rdt.RDTScn WHERE Scn = 2137 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2137, 'ENG'
   ,@cLine01 = N'LOADING-UNLOADING'
   ,@cLine03 = N'CONTAINER NO:'
   ,@cLine04 = N'%20i01'
   ,@cLine05 = N'OR'
   ,@cLine06 = N'APPT NO:'
   ,@cLine07 = N'%20i02'
   ,@cLine09 = N'1 = LOADING '
   ,@cLine10 = N'9 = UNLOADING'
   ,@cLine11 = N'OPTION: %01i03'
   ,@cLine14 = N'%e'
   ,@cWebGroup = '{"1":["3","4"],"2":["6","7"],"3":["9","10","11"]}'
   ,@nFunc = 858
 
-- 2138 = Additional info screen
DELETE rdt.RDTScn WHERE Scn = 2138 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2138, 'ENG'
   ,@cLine01 = N'LOADING-UNLOADING'
   ,@cLine03 = N'%20d01'
   ,@cLine04 = N'%20d02'
   ,@cLine05 = N'%20d03'
   ,@cLine06 = N'%20d04'
   ,@cLine07 = N'%20d05'
   ,@cLine08 = N'%20d06'
   ,@cLine09 = N'%20d07'
   ,@cLine10 = N'%20d08'
   ,@cLine11 = N'%20d09'
   ,@cLine12 = N'%20d10'
   ,@cLine14 = N'%e'
   ,@nFunc = 858
 