-- 1020 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1020 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1020, 'ENG',
    @cLine01 = 'LOC: %10iV_LOC'
   ,@cLine02 = 'ID:'
   ,@cLine03 = '%18iV_ID'
   ,@cLine04 = ''
   ,@cLine05 = 'UCC:'
   ,@cLine06 = '%20iV_UCC'
   ,@cLine07 = 'SKU:'
   ,@cLine08 = '%15iV_SKU'
   ,@cLine09 = 'QTY:'
   ,@cLine10 = '%05iV_QTY'
   ,@cLine13 = ''
   ,@cLine14 = '%e'
   
-- 1021 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1021 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1021, 'ENG',
    @cLine01 = 'L02:'
   ,@cLine02 = '%20iV_Lottable02'
   ,@cLine03 = 'L04:'
   ,@cLine04 = '%16iV_Lottable04'
 
   
   