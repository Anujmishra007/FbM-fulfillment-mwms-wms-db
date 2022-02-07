
-- 5230 = ADJ screen
DELETE rdt.RDTScn WHERE Scn = 5230 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5230, 'ENG'
   ,@cLine01 = 'ADJ KEY:'
   ,@cLine02 = '%10i01'
   ,@cLine14 = '%e'
   ,@nFunc = 619

-- 5231 = Parent LOT screen
DELETE rdt.RDTScn WHERE Scn = 5231 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5231, 'ENG'
   ,@cLine01 = 'ADJ KEY:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = ''
   ,@cLine04 = 'PARENT SKU:'
   ,@cLine05 = '%20d02'
   ,@cLine06 = '%20d03'
   ,@cLine07 = '%20d04'
   ,@cLine08 = '%20d05'
   ,@cLine09 = ''
   ,@cLine10 = 'PARENT LOT:'
   ,@cLine11 = '%60i06'
   ,@cLine12 = ''
   ,@cLine14 = '%e'
   ,@nFunc = 619

-- 5232 = Child LOT screen
DELETE rdt.RDTScn WHERE Scn = 5232 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5232, 'ENG'
   ,@cLine01 = 'CHILD SKU:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = '%20d02'
   ,@cLine04 = '%20d03'
   ,@cLine05 = '%20d04'
   ,@cLine06 = ''
   ,@cLine07 = 'CHILD LOT:'
   ,@cLine08 = '%60i05'
   ,@cLine09 = ''
   ,@cLine10 = 'QTY: %05i06'
   ,@cLine11 = ''
   ,@cLine12 = 'SCAN/TOTAL: %08d07'
   ,@cLine14 = '%e'
   ,@nFunc = 619
   
-- 5233 = Abort scan screen
DELETE rdt.RDTScn WHERE Scn = 5233 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5233, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'ABORT SCAN?'
   ,@cLine03 = ''
   ,@cLine04 = '1 = YES'
   ,@cLine05 = '9 = NO'
   ,@cLine06 = ''
   ,@cLine07 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 619
   
-- 5234 = Close ADJ screen
DELETE rdt.RDTScn WHERE Scn = 5234 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5234, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'CLOSE ADJ?'
   ,@cLine03 = ''
   ,@cLine04 = '1 = YES'
   ,@cLine05 = '9 = NO'
   ,@cLine06 = ''
   ,@cLine07 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 619
   
   
-- 5235 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 5235 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5235, 'ENG'
   ,@cLine01 = N'SKU 1/2:      OPT:%02i13'
   ,@cLine02 = N''
   ,@cLine03 = N'%20d02'
   ,@cLine04 = N'%20d03'
   ,@cLine05 = N'%20d04'
   ,@cLine06 = N'%20d05'
   ,@cLine07 = N''
   ,@cLine08 = N'%20d07'
   ,@cLine09 = N'%20d08'
   ,@cLine10 = N'%20d09'
   ,@cLine11 = N'%20d10'
   ,@cLine12 = N''
   ,@cLine13 = N'(1-2=SKU ENTER=NEXT)'
   ,@cLine14 = N'%e'
   ,@nFunc = 619
 
