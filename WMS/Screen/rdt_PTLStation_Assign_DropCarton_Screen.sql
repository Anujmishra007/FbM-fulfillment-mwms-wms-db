 -- 6390  = PTL Station Assign Drop Carton screen
DELETE rdt.RDTScn WHERE Scn = 6390 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6390, 'ENG'
   ,@cLine01 = N'Drop ID:       %05d05'
   ,@cLine02 = N'%20i01'
   ,@cLine03 = N''
   ,@cLine04 = N'CARTON ID:     %05d06'
   ,@cLine05 = N'%20i04'
   ,@cLine06 = N''
   ,@cLine14 = N'%e'
   ,@cWebGroup = '{"1":["1","2"],"2":["4","5"]}'
 