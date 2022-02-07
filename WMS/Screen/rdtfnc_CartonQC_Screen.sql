
-- 5460 = SKU Info screen
DELETE rdt.RDTScn WHERE Scn = 5460 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5460, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'EXP QTY: %05i01'
   ,@cLine14 = '%e'
   ,@nFunc = 879

-- 5461 = SKU QTY screen
DELETE rdt.RDTScn WHERE Scn = 5461 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5461, 'ENG'
   ,@cLine01 = 'SKU:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = '%20d02'
   ,@cLine04 = '%20d03'
   ,@cLine05 = ''
   ,@cLine06 = 'SIZE: %10d04'
   ,@cLine07 = ''
   ,@cLine08 = 'SKU/UPC:'
   ,@cLine09 = '%30i05'
   ,@cLine10 = ''
   ,@cLine11 = 'EXP QTY: %05d06'
   ,@cLine12 = 'ACT QTY: %05d07'
   ,@cLine14 = '%e'
   ,@nFunc = 879

-- 5462 = Message screen
DELETE rdt.RDTScn WHERE Scn = 5462 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5462, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'QTY CORRECT'
   ,@cLine14 = '%e'
   ,@nFunc = 879
   
-- 5463 = Confirm screen
DELETE rdt.RDTScn WHERE Scn = 5463 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5463, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'CONFIRM ABORT?'
   ,@cLine03 = ''
   ,@cLine04 = '1 = YES'
   ,@cLine05 = '2 = YES, BAD SCAN'
   ,@cLine06 = '3 = NO'
   ,@cLine07 = ''
   ,@cLine08 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 879