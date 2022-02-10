-- 1490 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1490 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1490, 'ENG',
    @cLine01 = 'SKU/LOC Integrity'
   ,@cLine02 = ''
   ,@cLine03 = 'LOC:'
   ,@cLine04 = '%10i01'
   ,@cLine13 = ''
   ,@cLine14 = '%e'
 
-- 1491 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1491 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1491, 'ENG',
    @cLine01 = 'SKU/BOM  %10d01'
   ,@cLine02 = 'LOC: %10d02'
   ,@cLine03 = '%20d03'
   ,@cLine04 = '%20d04'
   ,@cLine05 = '%20d05'
   ,@cLine06 = '%10d06      %05d07'
   ,@cLine07 = 'ID: %18d08'
   ,@cLine08 = '         CTNS    PCS'
   ,@cLine09 = 'QTY AVL: %05d09 %05d10'
   ,@cLine10 = 'SKU/BOM/CODE:'
   ,@cLine11 = '%20i11'
   ,@cLine12 = 'Qty Ctn: %05i12'
   ,@cLine14 = '%e' 