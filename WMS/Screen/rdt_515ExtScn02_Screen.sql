--FCR-9660
--6814-6816

-- 6814 = Qty confirm screen
DELETE rdt.RDTScn WHERE Scn = 6814 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6814, 'ENG'
   ,@cLine01 = 'INPUT QTY > PREALLOC QTY'
   ,@cLine02 = 'Do you want to continue'
   ,@cLine03 = 'the move?'
   ,@cLine04 = ''
   ,@cLine05 = '1 = YES'
   ,@cLine06 = '2 = NO'
   ,@cLine07 = ''
   ,@cLine08 = 'OPTION: %01i01'
   ,@cLine09 = ''
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2","3"],"2":["5","6"],"3":["8"]}'
   ,@nFunc = 515

--6815 dropid screen
DELETE rdt.RDTScn WHERE Scn = 6815 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6815, 'ENG'
   ,@cLine01 = 'CartonType: '
   ,@cLine02 = '%20i01'
   ,@cLine03 = 'Count:'
   ,@cLine04 = '%30i02'
   ,@cLine05 = ''
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2","3","4"]}'
   ,@nFunc = 515

-- 6816 = loc confirm screen
DELETE rdt.RDTScn WHERE Scn = 6816 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6816, 'ENG'
   ,@cLine01 = 'Entered LOC <> Priority LOC'
   ,@cLine02 = 'Do you still want to move?'
   ,@cLine03 = ''
   ,@cLine04 = '1 = YES'
   ,@cLine05 = '2 = NO'
   ,@cLine06 = ''
   ,@cLine07 = ''
   ,@cLine08 = 'OPTION: %01i01'
   ,@cLine09 = ''
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2","3"],"2":["4","5"],"3":["8"]}'
   ,@nFunc = 515

-- 6817 = New To LOC
DELETE rdt.RDTScn WHERE Scn = 6817 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6817, 'ENG',
   @cLine01 = 'FROM LOC: %10d01',
   @cLine02 = 'FROM ID:',
   @cLine03 = '%18d02',
   @cLine04 = 'SKU:',
   @cLine05 = '%20d03',
   @cLine06 = '%20d04',
   @cLine07 = '%20d05',
   @cLine08 = '         %05d06 %05d08',
   @cLine09 = 'QTY MV:  %05d07 %05d09',
   @cLine10 = 'TO ID:',
   @cLine11 = '%18d10',
   @cLine12 = 'TO LOC: %10i11',
   @cLine14 = '%e'
