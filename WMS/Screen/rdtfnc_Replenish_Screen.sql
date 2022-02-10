
-- 1226 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1226 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1226, 'ENG',
    @cLine01 = 'FROM LOC:'
   ,@cLine02 = '%10i01'
   ,@cLine03 = 'FROM ID:'
   ,@cLine04 = '%18i02'
   ,@cLine05 = ''
   ,@cLine06 = 'OR'
   ,@cLine07 = ''
   ,@cLine08 = 'RPL KEY:'
   ,@cLine09 = '%10i03'
   ,@cLine14 = '%e'
    
-- 1227 = SKU screen
DELETE rdt.RDTScn WHERE Scn = 1227 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1227, 'ENG',
    @cLine01 = 'FROM LOC:'
   ,@cLine02 = '%10d01'
   ,@cLine03 = 'FROM ID:'
   ,@cLine04 = '%18D02'
   ,@cLine05 = 'SKU/UPC:'
   ,@cLine06 = '%20i03'
   ,@cLine14 = '%e'
 
-- 1228 = QTY screen
DELETE rdt.RDTScn WHERE Scn = 1228 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1228, 'ENG',
    @cLine01 = 'RPL KEY: %10d01'
   ,@cLine02 = 'SKU:'
   ,@cLine03 = '%20d02'
   ,@cLine04 = '%20d03'
   ,@cLine05 = '%20d04'
   ,@cLine06 = 'LOTTABLE 2/3/4:'
   ,@cLine07 = '2 %18d05'
   ,@cLine08 = '3 %18d06'
   ,@cLine09 = '4 %16d07'
   ,@cLine10 = '%08d14 %05d08 %05d09'
   ,@cLine11 = 'RPL QTY: %05d10 %05d11'
   ,@cLine12 = 'ACT QTY: %05i12 %05i13'
   ,@cLine13 = '%20d14'   -- WMS6778
   ,@cLine14 = '%e'
 
-- 1229 = ToLOC screen
DELETE rdt.RDTScn WHERE Scn = 1229 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1229, 'ENG',
    @cLine01 = 'FROM LOC: %10d01'
   ,@cLine02 = 'FROM ID:'
   ,@cLine03 = '%18d02'
   ,@cLine04 = 'SKU:'
   ,@cLine05 = '%20d03'
   ,@cLine06 = '%20d04'
   ,@cLine07 = '%20d05'
   ,@cLine08 = '%08d14 %05d06 %05d07'
   ,@cLine09 = 'RPL QTY: %05d08 %05d09'
   ,@cLine10 = 'ACT QTY: %05d10 %05d11'
   ,@cLine11 = 'ID%18i15'     -- (james01)
   ,@cLine12 = 'TO LOC: %10d12'
   ,@cLine13 = 'TO LOC: %10i13'
   ,@cLine14 = '%e'

-- 1230 = Dialog screen
DELETE rdt.RDTScn WHERE Scn = 1230 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1230, 'ENG',
    @cLine01 = 'Replenish to'
   ,@cLine02 = 'different location'
   ,@cLine04 = 'Proceed?'
   ,@cLine06 = '1 = YES'
   ,@cLine07 = '2 = NO'
   ,@cLine09 = 'OPTION: %01i01'
   ,@cLine14 = '%e'

-- 1231 = Message screen
DELETE rdt.RDTScn WHERE Scn = 1231 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1231, 'ENG',
    @cLine01 = 'Replenish'
   ,@cLine02 = 'successfully'
   ,@cLine04 = 'Press ENTER or ESC'
   ,@cLine05 = 'to continue'
   ,@cLine14 = '%e'
 
