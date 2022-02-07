-- 936 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 936 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 936, 'ENG',
    @cLine01 = 'ID:'
   ,@cLine02 = '%18i01'
   ,@cLine04 = 'STORER:'
   ,@cLine05 = '%15d02'
   ,@cLine07 = 'FROM LOC'
   ,@cLine08 = '%10i03'
   ,@cLine14 = '%e'
	,@nfunc = 522 
	
-- 937 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 937 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 937, 'ENG',
    @cLine01 = 'ID:'
   ,@cLine02 = '%18d01'
   ,@cLine03 = 'STORER:'
   ,@cLine04 = '%15d02'
   ,@cLine05 = 'SKU:'
   ,@cLine06 = '%20d03'
   ,@cLine07 = '%20d04'
   ,@cLine08 = '%20d05'
   ,@cLine09 = 'QTY: %05d06'
   ,@cLine10 = 'UOM: %10d07'
   ,@cLine12 = 'FROM LOC: %10d08'
   ,@cLine13 = 'TO LOC:   %10d09'
   ,@cLine14 = '%e'
	,@nfunc = 522 
	
-- 938 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 938 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 938, 'ENG',
    @cLine01 = 'SUGGESTED LOC:'
   ,@cLine02 = '%10d01'
   ,@cLine04 = 'TO LOC:'
   ,@cLine05 = '%10i02'
   ,@cLine07 = '%20d03'
   ,@cLine08 = '%20d04'
   ,@cLine09 = '%20d05'
   ,@cLine14 = '%e'
	,@nfunc = 522 
	
-- 939 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 939 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 939, 'ENG',
    @cLine01 = 'Successfully Putaway'
   ,@cLine02 = ''
   ,@cLine03 = 'Press ENTER to'
   ,@cLine04 = 'putaway next item'
   ,@cLine05 = ''
   ,@cLine06 = ''
   ,@cLine07 = ''
   ,@cLine08 = '%20d15'
   ,@cLine14 = '%e'
	,@nfunc = 522 
	
-- 940 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 940 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 940, 'ENG',
    @cLine01 = 'PUTAWAY TO PICKLOC'
   ,@cLine03 = 'SKU:'
   ,@cLine04 = '%20i01'
   ,@cLine14 = '%e'
	,@nfunc = 522 
	
-- 941 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 941 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 941, 'ENG',
    @cLine01 = 'PUTAWAY TO PICKLOC'
   ,@cLine03 = 'SKU:'
   ,@cLine04 = '%20d01'
   ,@cLine05 = '%20d02'
   ,@cLine06 = '%20d03'
   ,@cLine07 = 'UOM: %10d04'
   ,@cLine08 = 'QTY: %05d05'
   ,@cLine09 = 'CASE ID:'
   ,@cLine10 = '%10i06'
   ,@cLine13 = '%20d15' -- SOS348695
   ,@cLine14 = '%e'
	,@nfunc = 522 
	
-- 942 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 942 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 942, 'ENG'
   ,@cLine01 = 'TO LOC: %10d01'
   ,@cLine02 = 'LPN#:'
   ,@cLine03 = '%20d02'
   ,@cLine04 = 'SKU:'
   ,@cLine05 = '%20d03'
   ,@cLine06 = '%20d04'
   ,@cLine07 = '%20d05'
   ,@cLine08 = 'UOM: %10d06'
   ,@cLine09 = 'QTY: %05d07'
   ,@cLine10 = 'LPN#:'
   ,@cLine11 = '%20i08'
   ,@cLine14 = '%e'	
