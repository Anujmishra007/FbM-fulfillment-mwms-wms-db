-- 5990 = SSCC screen
DELETE rdt.RDTScn WHERE Scn = 5990 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5990, 'ENG'
   ,@cLine01 = N'SSCC:'
   ,@cLine02 = N'%30d01'
   ,@cLine03 = N'ASN: %10d02'
   ,@cLine04 = N'SKU:'
   ,@cLine05 = N'%20d03'
   ,@cLine06 = N'%20d04'
   ,@cLine07 = N'%20d05'
   ,@cLine08 = N'TTL/SCANNED: %07d06'
   ,@cLine10 = N'SSCC:'
   ,@cLine11 = N'%30i07'
   ,@cLine13 = N'%20d08' --WMS-19352 (yeekung01)
   ,@cLine14 = N'%e'
 
-- 5991 = Confirm finalize screen
DELETE rdt.RDTScn WHERE Scn = 5991 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5991, 'ENG'
   ,@cLine01 = N'ASN: %10d01'
   ,@cLine02 = N'RECEIVED. FINALIZE ?'
   ,@cLine04 = N'OPTION %01i02'
   ,@cLine06 = N'1 = YES'
   ,@cLine07 = N'9 = NO'
   ,@cLine13 = N'%20d03' --WMS-19352 (yeekung01)
   ,@cLine14 = N'%e'
 
