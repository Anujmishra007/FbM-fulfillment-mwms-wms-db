-- 820 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 820 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 820, 'ENG',
    @cLine01 = 'SKU Inquiry:'
   ,@cLine02 = ''
   ,@cLine03 = 'SKU:'
   ,@cLine04 = '%60i01'    -- SOS375234
   ,@cLine05 = 'OR'
   ,@cLine06 = ''
   ,@cLine07 = 'LOC:'
   ,@cLine08 = '%10i02'
   ,@cLine14 = '%e'

-- 821 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 821 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 821, 'ENG',
    @cLine01 = 'SKU:          %04d14'
   ,@cLine02 = '%20d01'
   ,@cLine03 = '%20d02'
   ,@cLine04 = '%20d03'
   ,@cLine05 = 'Inv: %15d04'
   ,@cLine06 = 'Avl: %15d05'
   ,@cLine07 = 'CT/PL: %05i06 %04d11'
   ,@cLine08 = 'EA/CT: %05i07 %04d13'
   ,@cLine09 = 'Pick Loc: %10i08'
   ,@cLine10 = 'Min : %05i09 %04d11'
   ,@cLine11 = 'Max : %05i10 %04d11'
   ,@cLine12 = 'Next:'
   ,@cLine13 = '%60i12*'   -- SOS375234
   ,@cLine14 = '%e'