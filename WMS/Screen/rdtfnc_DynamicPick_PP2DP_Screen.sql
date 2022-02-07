-- 1590 = Repl screen
DELETE rdt.RDTScn WHERE Scn = 1590 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1590, 'ENG',
    @cLine01 = 'REPL GRP: %10i01'
   ,@cLine14 = '%e'

-- 1591 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1591 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1591, 'ENG',
    @cLine01 = 'REPL GRP: %10d01'
   ,@cLine02 = 'SKU/UPC:'
   ,@cLine03 = '%20i02'
   ,@cLine14 = '%e'

-- 1592 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1592 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1592, 'ENG',
    @cLine01 = 'SKU:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = '%20d02'
   ,@cLine04 = '%20d03'
   ,@cLine05 = 'Lottable 2/3/4:'
   ,@cLine06 = '2 %18d04'
   ,@cLine07 = '3 %18d05'
   ,@cLine08 = '4 %16d06'
   ,@cLine09 = '%08d13 %05d07 %05d08'
   ,@cLine10 = 'RPL QTY: %05d09 %05d10'
   ,@cLine11 = 'ACT QTY: %05i11 %05i12'
   ,@cLine14 = '%e'

-- 1593 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1593 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1593, 'ENG',
    @cLine01 = 'REPL GRP: %10d01'
   ,@cLine02 = 'FROM LOC: %10d02'
   ,@cLine03 = 'FROM ID:'
   ,@cLine04 = '%18d03'
   ,@cLine05 = 'SKU:'
   ,@cLine06 = '%20d04'
   ,@cLine07 = '%20d05'
   ,@cLine08 = '%20d06'
   ,@cLine09 = '%08d14 %05d07 %05d08'
   ,@cLine10 = 'RPL QTY: %05d09 %05d10'
   ,@cLine11 = 'ACT QTY: %05d11 %05d12'
   ,@cLine12 = 'TO LOC:'
   ,@cLine13 = '%18i13'
   ,@cLine14 = '%e'