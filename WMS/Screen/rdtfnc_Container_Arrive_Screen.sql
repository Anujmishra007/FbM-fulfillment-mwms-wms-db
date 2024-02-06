-- 2130 = Container screen
DELETE rdt.RDTScn WHERE Scn = 2130 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2130, 'ENG'
   ,@cLine01 = N'CONTAINER ARRIVE '
   ,@cLine03 = N'CONTAINER NO:'
   ,@cLine04 = N'%20i01'
   ,@cLine05 = N'TRAILER NO:'
   ,@cLine06 = N'%20i02'
   ,@cLine07 = N'DRIVER LICENSE NO:'
   ,@cLine08 = N'%20i03'
   ,@cLine12 = N'ENTER = Confirm'
   ,@cLine14 = N'%e'
   ,@cWebGroup = '{"1":["3","4"],"2":["5","6"],"3":["7","8"]}'
   ,@nFunc = 856