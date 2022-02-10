--Screen# 2520 - 2529


-- 2520 = Printer ID , PickSlip Screen
DELETE rdt.RDTScn WHERE Scn = 2520 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2520, 'ENG',
    @cLine01 = 'PACKING'
   ,@cLine03 = 'PRINTER ID:'
   ,@cLine04 = '%20i01'
   ,@cLine06 = 'PSNO:'
   ,@cLine07 = '%10i02'
   ,@cLine09 = 'TTL CARTONS:'
   ,@cLine10 = '%10i03'
   ,@cLine14 = '%e'

 
-- 2521 = WEIGHT screen
DELETE rdt.RDTScn WHERE Scn = 2521 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2521, 'ENG',
    @cLine01 = 'PACKING'
   ,@cLine03 = 'PSNO: %10d01'
   ,@cLine04 = 'CARTON NO:'
   ,@cLine05 = '%05d02 / %05d04'
   ,@cLine06 = 'WEIGHT:'
   ,@cLine07 = '%05i03'
   ,@cLine14 = '%e'
   
-- 2522 = OPTION screen
DELETE rdt.RDTScn WHERE Scn = 2522 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2522, 'ENG',
   @cLine01 = 'PACKING'
   ,@cLine03 = 'PSNO: %10d01'
   ,@cLine05 = 'There are pending'
   ,@cLine06 = 'cartons packed.'
   ,@cLine07 = 'Confirm to abort'
   ,@cLine08 = 'Packing?'
   ,@cLine10 = '1= Yes (delete all'
   ,@cLine11 = 'prev pack info)'
   --,@cLine12 = '2= No (Pack confirm)'      --requested to be removed
   ,@cLine13 = 'OPTION: %01i02 '
   ,@cLine14 = '%e'

   
 -- 2523  = MSG screen
DELETE rdt.RDTScn WHERE Scn = 2523 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2523, 'ENG',
    @cLine01 = 'PACKING'
   ,@cLine03 = 'Packing done for'
   ,@cLine04 = 'PickSlip'
   ,@cLine05 = '%10d01'
   ,@cLine07 = 'Press ENTER or ESC'
   ,@cLine08 = 'to continue'
   ,@cLine14 = '%e'
   
 
   
   