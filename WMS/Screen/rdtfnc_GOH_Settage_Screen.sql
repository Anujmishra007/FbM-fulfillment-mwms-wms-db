-- 1980 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1980 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1980, 'ENG',
    @cLine01 = 'PICK TOID:'
   ,@cLine02 = '%18i01'
   ,@cLine05 = '%e'
 
-- 1981 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1981 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1981, 'ENG',
    @cLine01 = 'SKU:   %11d06'
   ,@cLine02 = '%18d01'
   ,@cLine03 = '%18d02'
   ,@cLine04 = 'QTY: %05d03 %05d04'
   ,@cLine05 = '%20i05'
 
-- 1982 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1982 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1982, 'ENG',
    @cLine01 = '1 = PRINT LABEL'
   ,@cLine02 = '2 = REPRINT LABEL'
   ,@cLine03 = '9 = ESC'
   ,@cLine04 = 'OPTION: %01i01'
   ,@cLine05 = '%e'
 
-- 1983 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1983 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1983, 'ENG',
    @cLine01 = 'SET ID/URN NO:'
   ,@cLine02 = '%40i01'
   ,@cLine05 = '%e'
 
-- 1984 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1984 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1984, 'ENG',
    @cLine01 = 'No more Pick Task'
   ,@cLine02 = ''
   ,@cLine03 = 'Press ENTER or ESC'
   ,@cLine05 = '%e'
 

 
