-- 6776 - Post Pack Sorting - Close Pallet Screen with Print Option
DELETE rdt.RDTScn WHERE Scn = 6776 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6776, 'ENG'
   ,@cLine01 = 'POST PACK SORTING'
   ,@cLine02 = ''
   ,@cLine03 = 'CLOSE PALLET ?'
   ,@cLine04 = '1 = YES'
   ,@cLine05 = '2 = NO'
   ,@cLine06 = '3 = YES + PRINT'
   ,@cLine07 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1837