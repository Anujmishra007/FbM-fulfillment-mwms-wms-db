-- rdtfnc_Scan_And_Pack

-- 1931 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1931 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1931, 'ENG',
    @cLine01 = 'PRINTER ID:'
   ,@cLine02 = '%20i01'
   ,@cLine04 = 'PSNO:'
   ,@cLine05 = '%10i02'
   ,@cLine14 = '%e'

-- 1932 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1932 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1932, 'ENG',
    @cLine01 = 'PSNO: %10d01'
   ,@cLine02 = 'LOADKEY: %10d02'
   ,@cLine03 = 'ORDKEY: %10d03'
   ,@cLine04 = 'LAST LABEL #:'
   ,@cLine05 = '%20d04'
   ,@cLine06 = 'LAST CARTON #: %05d05'
   ,@cLine07 = 'SKU/UPC:'
   ,@cLine08 = '%20i06'
   ,@cLine14 = '%e'

-- 1933 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1933 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1933, 'ENG',
    @cLine01 = 'PSNO: %10d01'
   ,@cLine02 = 'LAST LABEL #:'
   ,@cLine03 = '%20d02'
   ,@cLine04 = 'LAST CARTON #: %05d03'
   ,@cLine05 = 'SKU:     QTY: %05i04'
   ,@cLine06 = '%20d05'
   ,@cLine07 = '%20d06'
   ,@cLine08 = 'QTY SCN/QTY ALLOC:'
   ,@cLine09 = '%11d07'
   ,@cLine10 = 'QTY REMAIN: %05d08'
   ,@cLine12 = '1= CHECK SKU IN ORD'
   ,@cLine13 = 'OPTION: %01i09'
   ,@cLine14 = '%e'

-- 1934 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1934 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1934, 'ENG',
    @cLine01 = 'SKU:        %08d01'
   ,@cLine02 = '%20d02'
   ,@cLine03 = '%20d03'
   ,@cLine04 = 'QTY ALLOC: %05d04'
   ,@cLine05 = 'QTY SCAN: %05d05'
   ,@cLine07 = '%20d06'
   ,@cLine08 = '%20d07'
   ,@cLine09 = 'QTY ALLOC: %05d08'
   ,@cLine10 = 'QTY SCAN: %05d09'
   ,@cLine12 = '1 = NEXT PAGE OPT %01i10'
   ,@cLine13 = '2 = PREV PAGE'
   ,@cLine14 = '%e'

-- 1935 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1935 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1935, 'ENG',
    @cLine01 = 'Template ID Not'
   ,@cLine02 = 'Setup'
   ,@cLine04 = 'Apply Generic.btw?'
   ,@cLine06 = '1 = YES'
   ,@cLine07 = '2 = NO'
   ,@cLine09 = 'Option: %01i01'
   ,@cLine14 = '%e'

-- 1936 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1936 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1936, 'ENG',
    @cLine01 = 'Skip current task?'
   ,@cLine03 = '1 = YES'
   ,@cLine04 = '2 = NO'
   ,@cLine06 = 'Option: %01i01'
   ,@cLine14 = '%e'

-- 1937 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1937 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1937, 'ENG',
    @cLine01 = 'Short Pack?'
   ,@cLine03 = '1 = YES'
   ,@cLine04 = '2 = NO'
   ,@cLine06 = 'Option: %01i01'
   ,@cLine14 = '%e'   

-- 1938 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1938 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1938, 'ENG',
    @cLine01 = 'No more Pack task'
   ,@cLine03 = 'Press ENTER or ESC '
   ,@cLine04 = 'to continue'
   ,@cLine14 = '%e'   

-- 1939 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1939 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1939, 'ENG',
    @cLine01 = 'No more task'
   ,@cLine02 = 'for Pickslip No'
   ,@cLine04 = 'Press ENTER or ESC '
   ,@cLine05 = 'to continue'
   ,@cLine14 = '%e'      