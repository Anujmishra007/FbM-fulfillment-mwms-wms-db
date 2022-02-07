
-- 3770 = Shipment ID screen
DELETE rdt.RDTScn WHERE Scn = 3770 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3770, 'ENG'
   ,@cLine01 = N'OUTBOUND SHIPMENTID:'
   ,@cLine02 = N'%20i01'
   ,@cLine03 = N''
   ,@cLine04 = N'TO SHOP: %04i02'
   ,@cLine14 = N'%e'
   ,@nFunc = 588
 
-- 3771 = Brand, from, to Shop screen
DELETE rdt.RDTScn WHERE Scn = 3771 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3771, 'ENG'
   ,@cLine01 = N'OUTBOUND SHIPMENTID:'
   ,@cLine02 = N'%20d01'
   ,@cLine03 = N''
   ,@cLine04 = N'TO SHOP: %04d02'
   ,@cLine05 = N'%20d03'
   ,@cLine06 = N''
   ,@cLine07 = N'CARTON ID:'
   ,@cLine08 = N'%18i04'
   ,@cLine09 = N''
   ,@cLine10 = N'TOTAL CARTON: %05d05'
   ,@cLine14 = N'%e'
   ,@nFunc = 588
