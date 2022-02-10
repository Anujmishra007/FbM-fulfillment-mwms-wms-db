-- 1970 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1970 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1970, 'ENG',
    @cLine01 = 'LOAD: %10i01'
   ,@cLine02 = 'ZONE: %10i02'
   ,@cLine14 = '%e'
 
-- 1971 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1971 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1971, 'ENG',
    @cLine01 = 'DOOR: %10d01'
   ,@cLine02 = 'PALLET ID:'
   ,@cLine03 = '%18i02'
   ,@cLine14 = '%e'
 
-- 1972 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1972 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1972, 'ENG',
    @cLine01 = 'LOC:'
   ,@cLine02 = '%10d01'
   ,@cLine03 = '%10i02'
   ,@cLine14 = '%e'
 
-- 1973 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1973 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1973, 'ENG',
    @cLine01 = 'SKU:      %11d01'
   ,@cLine02 = '%20d02'
   ,@cLine03 = '%20i03'
   ,@cLine04 = 'QTY %05i04 %03d05'
   ,@cLine14 = '%e'
 
-- 1974 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1974 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1974, 'ENG',
    @cLine01 = '1 = SKIP Task'
   ,@cLine02 = '2 = NEW ID'
   ,@cLine03 = 'Option: %01i01'
   ,@cLine14 = '%e'
 
-- 1975 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1975 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1975, 'ENG',
    @cLine01 = 'No more Pick task'
   ,@cLine02 = 'Press ENTER or ESC'
   ,@cLine14 = '%e'
 

 
