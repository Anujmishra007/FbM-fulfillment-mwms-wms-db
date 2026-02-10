-- rdt_1819ExtScn04
-- 6824 = PreQty List

DELETE rdt.RDTScn WHERE Scn = 6824 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6824, 'ENG',
    @cLine01 = 'CLEAR PR ALLO QTY FROM'
   ,@cLine02 = 'Pallet: %20d01'
   ,@cLine03 = 'SKU: '
   ,@cLine04 = '%20d02'
   ,@cLine05 = '%20d03'
   ,@cLine06 = '%20d04'
   ,@cLine07 = '%20d05'
   ,@cLine08 = '%20d06'
   ,@cLine09 = ''
   ,@cLine10 = 'ENTER OR ESC to BACK'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"],"2":["3","4","5","6","7","8"]}'
   ,@nFunc = 1819