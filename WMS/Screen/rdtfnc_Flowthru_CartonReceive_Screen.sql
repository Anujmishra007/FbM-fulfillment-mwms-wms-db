
-- 3760 = Shipment ID screen
DELETE rdt.RDTScn WHERE Scn = 3760 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3760, 'ENG'
   ,@cLine01 = N'INBOUND SHIPMENT ID:'
   ,@cLine02 = N'%20i01'
   ,@cLine14 = N'%e'
   ,@nFunc = 587
 
-- 3761 = Brand, from, to Shop screen
DELETE rdt.RDTScn WHERE Scn = 3761 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3761, 'ENG'
   ,@cLine01 = N'INBOUND SHIPMENT ID:'
   ,@cLine02 = N'%20d01'
   ,@cLine03 = N''
   ,@cLine04 = N'BRAND: %10i02'
   ,@cLine05 = N''
   ,@cLine06 = N'FROM SHOP: %04i03'
   ,@cLine08 = N''
   ,@cLine09 = N'TO SHOP:   %04i04'
   ,@cLine14 = N'%e'
   ,@nFunc = 587

-- 3762 = Carton ID screen
DELETE rdt.RDTScn WHERE Scn = 3762 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3762, 'ENG'
   ,@cLine01 = N'INBOUND SHIPMENT ID:'
   ,@cLine02 = N'%20d01'
   ,@cLine03 = N'BRAND: %10d02'
   ,@cLine04 = N'FROM SHOP: %04d03'
   ,@cLine05 = N'%20d04'
   ,@cLine06 = N'TO SHOP:   %04d05'
   ,@cLine07 = N'%20d06'
   ,@cLine08 = N''
   ,@cLine09 = N'CARTON ID:'
   ,@cLine10 = N'%18i07'
   ,@cLine11 = N''
   ,@cLine12 = N'TOTAL CARTON: %05d08'
   ,@cLine14 = N'%e'
   ,@nFunc = 587
