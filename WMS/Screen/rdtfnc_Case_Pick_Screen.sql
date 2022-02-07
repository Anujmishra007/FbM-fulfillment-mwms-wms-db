-- rdtfnc_Case_Pick

-- 1960 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1960 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1960, 'ENG',
    @cLine01 = 'LOAD: %10i01'
   ,@cLine02 = 'ZONE: %10i02'
   ,@cLine14 = '%e'
 
-- 1961 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1961 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1961, 'ENG',
    @cLine01 = 'DOOR: %10d01'
   ,@cLine02 = 'PALLET ID:'
   ,@cLine03 = '%18i02'
   ,@cLine14 = '%e'
 
-- 1962 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1962 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1962, 'ENG',
    @cLine01 = 'LOC:'
   ,@cLine02 = '%10d01'
   ,@cLine03 = '%10i02'
   ,@cLine14 = '%e'
 
-- 1963 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1963 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1963, 'ENG',
    @cLine01 = 'SKU:          %11d01'
   ,@cLine02 = '%20d02'
   ,@cLine03 = '%20d03'
   ,@cLine04 = 'QTY 1  %05d04'
   ,@cLine05 = '%20i05'
   ,@cLine14 = '%e'
 
-- 1964 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1964 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1964, 'ENG',
    @cLine01 = 'SKU:'
   ,@cLine02 = '%18d01'
   ,@cLine03 = 'CASE ID:'
   ,@cLine04 = '%10i02'
   ,@cLine14 = '%e'
 
-- 1965 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1965 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1965, 'ENG',
    @cLine01 = '1 = SKIP Task'
   ,@cLine02 = '2 = NEW ID'
   ,@cLine03 = 'Option: %01i01'
   ,@cLine14 = '%e'
 
-- 1966 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1966 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1966, 'ENG',
    @cLine01 = 'No more Pick task'
   ,@cLine02 = 'Press ENTER or ESC'
   ,@cLine14 = '%e'
 
-- 1967 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1967 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1967, 'ENG',
    @cLine01 = 'SKU:          '
   ,@cLine02 = '%20d01'
   ,@cLine03 = '%20d02'
   ,@cLine04 = '%20i03'
   ,@cLine05 = 'UOM: %10d04'
   ,@cLine06 = 'QTY TO PICK: %05d05'
   ,@cLine07 = 'QTY PICKED:  %05d06'
   ,@cLine08 = 'QTY: %05i07'
   ,@cLine14 = '%e'

-- 1968 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1968 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1968, 'ENG',
    @cLine01 = 'LOAD: %10d01'
   ,@cLine02 = 'ZONE: %10d02'
   ,@cLine03 = 'LOC:  %10d03'
   ,@cLine04 = 'SKU:'
   ,@cLine05 = '%20d04'
   ,@cLine06 = 'UOM:  %10d05'
   ,@cLine07 = 'QTY:  %05d06'
   ,@cLine09 = 'CONFIRM SHORT PICK ??'
   ,@cLine10 = '1 = YES ; 2 = NO'
   ,@cLine11 = 'OPTION:  %01i07'
   ,@cLine14 = '%e'