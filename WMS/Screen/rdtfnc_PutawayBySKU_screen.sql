-- 2880 = ID, LOC
DELETE rdt.RDTScn WHERE Scn = 2880 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2880, 'ENG'
   ,@cLine01 = 'ID:'
   ,@cLine02 = '%20i01'
   ,@cLine03 = 'OR'
   ,@cLine04 = ''
   ,@cLine05 = 'UCC:'
   ,@cLine06 = '%200iV_Barcode' --FCR-2961
   ,@cLine07 = ''
   ,@cLine08 = 'LOC:'
   ,@cLine09 = '%10i03'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"],"2":["5","6"],"3":["8","9"]}'
   ,@nFunc = 523
 
-- 2881 = SKU
DELETE rdt.RDTScn WHERE Scn = 2881 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2881, 'ENG',
    @cLine01 = 'ID:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = 'UCC:'
   ,@cLine04 = '%20d02'
   ,@cLine05 = 'LOC:'
   ,@cLine06 = '%10d03'
   ,@cLine07 = 'SKU/UPC/LPN:'
   ,@cLine08 = '%20d04'
   ,@cLine09 = '%100i05'   --wms23078
   ,@cLine10 = '%20d06'
   ,@cLine11 = '%20d07'
   ,@cLine12 = 'QTY: %10d08'
   ,@cLine13 = '%20d15'    -- ExtendedInfo WMS-21307
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"],"2":["3","4"],"3":["5","6"],"4":["7","8","9","10","11"],"5":["12"],"5":["13"]}'
   ,@nFunc = 523
   
-- 2882 = QTY
DELETE rdt.RDTScn WHERE Scn = 2882 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2882, 'ENG'
   ,@cLine01 = 'SKU:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = '%20d02'
   ,@cLine04 = '%20d03'
   ,@cLine05 = 'LOTTABLES:     %20d09'
   ,@cLine06 = '1 %20d04'
   ,@cLine07 = '2 %20d05'
   ,@cLine08 = '3 %20d06'
   ,@cLine09 = '4 %20d07'
   --,@cLine10 = '%08d08 %05d09 %05d10'
   ,@cLine10 = '%20d08'    -- WMS-15820
   ,@cLine11 = N'QTY PWY: %06d11 %06d12' --(ws01)
   ,@cLine12 = N'QTY ACT: %06i13^DT:INT %06i14^DT:INT' --(ws01)
   ,@cLine13 = '%20d15'    -- WMS-15820
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2","3","4"],"2":["5","6","7","8","9"],"3":["10","11","12"],"4":["13"]}'
   ,@nFunc = 523
   
-- 2883 = Suggested LOC, final LOC
DELETE rdt.RDTScn WHERE Scn = 2883 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2883, 'ENG'
   ,@cLine01 = 'SUGGESTED LOC:'
   ,@cLine02 = '%10d01'
   ,@cLine03 = ''
   ,@cLine04 = 'QTY AVAIL: %05d03'
   ,@cLine05 = 'QTY ALLOC: %05d04'
   ,@cLine06 = 'QTY MOVIN: %05d05'
   ,@cLine07 = ''
   ,@cLine08 = 'FINAL LOC:'
   ,@cLine09 = '%10i02'
   ,@cLine10 = ''
   ,@cLine11 = '%20d15'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"],"2":["4","5","6"],"3":["8","9"],"4":["11"]}'
   ,@nFunc = 523
   
-- 2884 = Message screen
DELETE rdt.RDTScn WHERE Scn = 2884 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2884, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'Successful putaway'
   ,@cLine03 = ''
   ,@cLine04 = ''
   ,@cLine05 = 'Press ENTER to'
   ,@cLine06 = 'putaway next item'
   ,@cLine14 = '%e'
   ,@cAutoDisappear = '1'
   ,@nFunc = 523

DELETE rdt.RDTScn WHERE Scn = 2885 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2885, 'ENG', 
   @cLine01 = '',
   @cLine02 = 'LOC NOT MATCH.',
   @cLine03 = 'PROCEED?',
   @cLine04 = '',
   @cLine05 = '1 = YES',
   @cLine06 = '2 = NO',
   @cLine07 = '',
   @cLine08 = 'OPTION: %01i01',
   @cLine14 = '%e',     
   @nFunc   = 523