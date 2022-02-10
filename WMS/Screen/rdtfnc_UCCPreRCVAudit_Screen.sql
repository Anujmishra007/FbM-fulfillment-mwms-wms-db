-- 4370 = UCC screen
DELETE rdt.RDTScn WHERE Scn = 4370 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4370, 'ENG',
    @cLine01 = 'UCC PRE RCV AUDIT'
   ,@cLine02 = ''
   ,@cLine03 = 'UCC:'
   ,@cLine04 = '%20i01'
   ,@cLine05 = ''
   ,@cLine06 = 'CLOSE/RESET UCC:'
   ,@cLine07 = '%20i02'
   ,@cLine14 = '%e'
   ,@nFunc = 845
 
-- 4371 = Statistic screen
DELETE rdt.RDTScn WHERE Scn = 4371 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4371, 'ENG',
    @cLine01 = 'UCC:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = ''
   ,@cLine04 = 'TYPE: %10d02'
   ,@cLine05 = ''
   ,@cLine06 = 'CHK SKU: %10d03'
   ,@cLine07 = 'CHK QTY: %10d04'
   ,@cLine14 = '%e'
   ,@nFunc = 845

-- 4372 = SKU screen
DELETE rdt.RDTScn WHERE Scn = 4372 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4372, 'ENG',
    @cLine01 = 'SKU/UPC:'
   ,@cLine02 = '%20i01'
   ,@cLine03 = '%20d02'
   ,@cLine04 = '%20d03'
   ,@cLine05 = '%20d04'
   ,@cLine06 = '%20d05'
   ,@cLine07 = '%20d06'
   ,@cLine08 = ''
   ,@cLine09 = 'QTY: %05d07'
   ,@cLine14 = '%e'
   ,@nFunc = 845

-- 4373 = new UCC screen
DELETE rdt.RDTScn WHERE Scn = 4373 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4373, 'ENG',
    @cLine01 = 'SKU:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = '%20d02'
   ,@cLine04 = '%20d03'
   ,@cLine05 = '%20d04'
   ,@cLine06 = '%20d05'
   ,@cLine07 = ''
   ,@cLine08 = 'QTY: %05d06'
   ,@cLine09 = ''
   ,@cLine10 = 'NEW UCC:'
   ,@cLine11 = '%20d07'
   ,@cLine12 = '%20i08'
   ,@cLine14 = '%e'
   ,@nFunc = 845
    
 -- 4374 = Option screen
DELETE rdt.RDTScn WHERE Scn = 4374 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4374, 'ENG',
    @cLine01 = ''
   ,@cLine02 = 'CLOSE/RESET UCC'
   ,@cLine03 = ''
   ,@cLine04 = '1 = CLOSE'
   ,@cLine05 = '2 = RESET'
   ,@cLine06 = ''
   ,@cLine07 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 845
   
 -- 4375 = Variance screen
DELETE rdt.RDTScn WHERE Scn = 4375 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4375, 'ENG',
    @cLine01 = ''
   ,@cLine02 = 'VARIANCE FOUND.'
   ,@cLine03 = 'CONFIRM?'
   ,@cLine04 = ''
   ,@cLine05 = '1 = YES'
   ,@cLine06 = '2 = NO'
   ,@cLine07 = ''
   ,@cLine08 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 845