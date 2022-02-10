-- 1471 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1471 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1471, 'ENG',
    @cLine01 = 'LOTTABLE02:'
   ,@cLine02 = '%18i01'
   ,@cLine14 = '%e'
 
-- 1472 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1472 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1472, 'ENG',
    @cLine01 = 'LOTTABLE02:'
   ,@cLine02 = '%18d01'
   ,@cLine03 = 'LOC:'
   ,@cLine04 = '%10i02'
   ,@cLine14 = '%e'
 
-- 1473 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1473 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1473, 'ENG',
    @cLine01 = 'LOTTABLE02:'
   ,@cLine02 = '%18d01'
   ,@cLine03 = 'LOC:'
   ,@cLine04 = '%10d02'
   ,@cLine06 = 'UCC:'
   ,@cLine07 = '%20i03'
   ,@cLine14 = '%e'
 
-- 1474 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1474 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1474, 'ENG',
    @cLine02 = 'CREATE NEW UCC?'
   ,@cLine04 = '1=YES'
   ,@cLine05 = '2=NO'
   ,@cLine07 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
 
-- 1475 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1475 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1475, 'ENG',
    @cLine01 = 'UCC:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = 'SKU/UPC:'
   ,@cLine04 = '%20i02'
   ,@cLine14 = '%e'
 
-- 1476 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1476 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1476, 'ENG',
    @cLine01 = 'UCC:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = 'SKU:'
   ,@cLine04 = '%20d02'
   ,@cLine05 = '%20d03'
   ,@cLine06 = '%20d04'
   ,@cLine07 = 'PPK/DU: %12d05'
   ,@cLine09 = 'QTY: %05i10'
   ,@cLine14 = '%e'
 
-- 1477 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1477 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1477, 'ENG',
    @cLine01 = 'UCC:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = 'SKU:'
   ,@cLine04 = '%20d02'
   ,@cLine05 = '%20d03'
   ,@cLine06 = '%20d04'
   ,@cLine07 = 'PPK/DU: %12d05'
   ,@cLine09 = 'QTY: %05d10'
   ,@cLine14 = '%e'
 
