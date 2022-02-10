-- 2410 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2410 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2410, 'ENG',
    @cLine01 = 'TOTE/CASE INQUIRY'
   ,@cLine03 = '1 = SCAN TOTE NO'
   ,@cLine05 = '9 = SCAN CASE ID'
   ,@cLine07 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
	,@nFunc = 1629
 
-- 2411 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2411 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2411, 'ENG',
    @cLine01 = 'TOTE/CASE INQUIRY'
   ,@cLine03 = 'TOTE NO/CASE ID:'
   ,@cLine04 = '%18i01'
   ,@cLine14 = '%e'
	,@nFunc = 1629
	
-- 2412 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2412 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2412, 'ENG',
    @cLine01 = 'TOTE NO/CASE ID:'
   ,@cLine02 = '%18d01'
   ,@cLine03 = 'TASK TYPE:'
   ,@cLine04 = '%10d02'
   ,@cLine05 = 'TM REASON CODE:'
   ,@cLine06 = '%10d03'
   ,@cLine07 = 'LAST USER:'
   ,@cLine08 = '%18d04'
   ,@cLine09 = 'LAST ZONE:'
   ,@cLine10 = '%10d05'
   ,@cLine11 = 'FINAL ZONE:'
   ,@cLine12 = '%10d06'
   ,@cLine14 = '%e'
	,@nFunc = 1629
	
-- 2413 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2413 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2413, 'ENG',
    @cLine01 = 'ORDERKEY: %10d01'
   ,@cLine02 = 'STORE:    REC: %05d11'
   ,@cLine03 = '%20d02'
   ,@cLine04 = '%20d03'
   ,@cLine05 = '%20d04'
   ,@cLine06 = 'SKU:      REC: %05d12'
   ,@cLine07 = '%20d05'
   ,@cLine08 = '%20d06'
   ,@cLine09 = '%20d07'
   ,@cLine10 = 'UOM:%05d08 PREV:%01i14 1/0'
   ,@cLine11 = 'TOTAL QTY : %05d09'
   ,@cLine12 = 'PICKED QTY: %05d10'
   ,@cLine13 = 'SORTED QTY: %05d13'
   ,@cLine14 = '%e'
	,@nFunc = 1629
