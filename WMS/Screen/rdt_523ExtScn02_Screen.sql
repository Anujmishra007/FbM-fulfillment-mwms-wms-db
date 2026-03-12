DELETE rdt.RDTScn WHERE Scn = 6843 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6843, 'ENG'
   ,@cLine01 = 'SKU:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = '%20d02'
   ,@cLine04 = '%20d03'
   ,@cLine05 = 'LOTTABLES:     %20d09'
   ,@cLine06 = '%20d04'
   ,@cLine07 = '%20d05'
   ,@cLine08 = '%20d06'
   ,@cLine09 = '%20d07'
   --,@cLine10 = '%08d08 %05d09 %05d10'
   ,@cLine10 = '%20d08'    -- WMS-15820
   ,@cLine11 = N'QTY PWY: %06d11 %06d12' --(ws01)
   ,@cLine12 = N'QTY ACT: %06i13^DT:INT %06i14^DT:INT' --(ws01)
   ,@cLine13 = '%20d15'    -- WMS-15820
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2","3","4"],"2":["5","6","7","8","9"],"3":["10","11","12"],"4":["13"]}'
   ,@nFunc = 523