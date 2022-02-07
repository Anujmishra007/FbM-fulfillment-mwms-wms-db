-- 1910 = PSNO screen
DELETE rdt.RDTScn WHERE Scn = 1910 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1910, 'ENG',
    @cLine01 = 'PSNO: %10i01'
   ,@cLine14 = '%e'

-- 1911 = LOC screen
DELETE rdt.RDTScn WHERE Scn = 1911 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1911, 'ENG',
    @cLine01 = 'PSNO: %10d01'
   ,@cLine03 = 'TOTAL LOC: %05d02'
   ,@cLine04 = 'PICKEDLOC: %05d03'
   ,@cLine06 = 'LOC: %10d04'
   ,@cLine07 = 'LOC: %10i05'
   ,@cLine14 = '%e'

-- 1912 = SKU screen
DELETE rdt.RDTScn WHERE Scn = 1912 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1912, 'ENG',
    @cLine01 = 'SKU: '
   ,@cLine02 = '%20d01'
   ,@cLine03 = '%20d02'
   ,@cLine04 = '%20d03'
   ,@cLine06 = 'SKU/UPC:'
   ,@cLine07 = '%20i04'
   ,@cLine14 = '%e'

-- 1913 = ID screen
DELETE rdt.RDTScn WHERE Scn = 1913 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1913, 'ENG',
    @cLine01 = 'SKU: '
   ,@cLine02 = '%20d01'
   ,@cLine03 = '%20d02'
   ,@cLine04 = '%20d03'
   ,@cLine06 = '%08d04 %05d05 %05d06'
   ,@cLine07 = 'BAL QTY: %05d07 %05d08'
   ,@cLine09 = 'ID:'
   ,@cLine10 = '%18i09'
   ,@cLine14 = '%e'

-- 1914 = QTY screen
DELETE rdt.RDTScn WHERE Scn = 1914 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1914, 'ENG',
    @cLine01 = 'ID: '
   ,@cLine02 = '%18d01'
   ,@cLine03 = ''
   ,@cLine04 = 'LOTTABLES 1/2/3/4:'
   ,@cLine05 = '1 %18d02'
   ,@cLine06 = '2 %18d03'
   ,@cLine07 = '3 %18d04'
   ,@cLine08 = '4 %16d05'
   ,@cLine09 = '%08d06 %05d07 %05d08'
   ,@cLine10 = 'BAL QTY: %05d09 %05d10'
   ,@cLine11 = 'PICKQTY: %05i11 %05i12'
   ,@cLine12 = 'DROPID:'
   ,@cLine13 = '%20i13'
   ,@cLine14 = '%e'

-- 1915 = Message screen
DELETE rdt.RDTScn WHERE Scn = 1915 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1915, 'ENG',
    @cLine01 = 'Picked successfully'
   ,@cLine03 = 'Press ENTER or ESC'
   ,@cLine04 = 'to continue'
   ,@cLine14 = '%e'

-- 1916 = Option screen
DELETE rdt.RDTScn WHERE Scn = 1916 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1916, 'ENG',
    @cLine01 = 'Remaining %05d01'
   ,@cLine02 = 'task not completed'
   ,@cLine04 = 'Press ENTER or ESC'
   ,@cLine05 = 'to continue'
   ,@cLine14 = '%e'
