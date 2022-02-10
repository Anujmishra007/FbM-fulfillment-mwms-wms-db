
-- 3390 = TO ID
DELETE rdt.RDTScn WHERE Scn = 3390 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3390, 'ENG'
   ,@cLine01 = 'TO ID:'
   ,@cLine02 = '%18i01'
   ,@cLine14 = '%e'
   ,@nFunc = 534

-- 3391 = FROM LOC
DELETE rdt.RDTScn WHERE Scn = 3391 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3391, 'ENG'
   ,@cLine01 = 'TO ID:'
   ,@cLine02 = '%18d01'
   ,@cLine03 = 'FROM LOC: %10i02'
   ,@cLine14 = '%e'
   ,@nFunc = 534

-- 3392 = SKU, QTY
DELETE rdt.RDTScn WHERE Scn = 3392 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3392, 'ENG'
   ,@cLine01 = 'FROM LOC: %10d01'
   ,@cLine02 = 'SKU/UPC:'
   ,@cLine03 = '%60i02'
   ,@cLine04 = '%20d03'
   ,@cLine05 = '%20d04'
   ,@cLine06 = '%20d05'
   ,@cLine07 = ''
   ,@cLine08 = '%08d12 %05d06 %05d09'
   ,@cLine09 = 'QTY AVL: %05d07 %05d10'
   ,@cLine10 = 'QTY MV:  %05i08 %05i11'
   ,@cLine11 = ''
   ,@cLine12 = 'QTY ID: %05d13'
   ,@cLine14 = '%e'
   ,@nFunc = 534

 -- 3393 = Close ToID screen
DELETE rdt.RDTScn WHERE Scn = 3393 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3393, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'CLOSE TO ID?'
   ,@cLine03 = ''
   ,@cLine04 = '1 = YES'
   ,@cLine05 = '2 = NO'
   ,@cLine07 = ''
   ,@cLine08 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 534

-- 3394 = To LOC
DELETE rdt.RDTScn WHERE Scn = 3394 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3394, 'ENG'
   ,@cLine01 = 'TO LOC: %10i01'
   ,@cLine14 = '%e'
   ,@nFunc = 534
