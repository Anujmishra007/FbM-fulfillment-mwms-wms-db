DELETE RDT.RDTMSG WHERE Message_ID = 896 AND Message_Type = 'FNC' AND Lang_Code = 'ENG'
INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES (896, 'ENG', 'FNC', 'REPLENISHMENT V7', 'rdtfnc_Replenish_V7', '5')

-- 5370 = FROM LOC,ID or RPLKEY screen
DELETE rdt.RDTScn WHERE Scn = 5370 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5370, 'ENG',
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
   ,@cWebGroup = '{"1":["1","2"],"2":["3","4"],"3":["8","9"]}'
   ,@nFunc = 896

-- 5371 = SKU screen
DELETE rdt.RDTScn WHERE Scn = 5371 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5371, 'ENG',
    @cLine01 = 'FROM LOC:'
   ,@cLine02 = '%10d01'
   ,@cLine03 = 'FROM ID:'
   ,@cLine04 = '%18D02'
   ,@cLine05 = 'SKU/UPC:'
   ,@cLine06 = '%20i03'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"],"2":["3","4"],"3":["5","6"]}'
   ,@nFunc = 896

-- 5372 = QTY screen
DELETE rdt.RDTScn WHERE Scn = 5372 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5372, 'ENG',
    @cLine01 = 'RPL KEY: %10d01'
   ,@cLine02 = 'SKU:'
   ,@cLine03 = '%20d02'
   ,@cLine04 = '%20d03'
   ,@cLine05 = '%20d04'
   ,@cLine06 = '%20d05'    -- Lottablenn 
   ,@cLine07 = '%20d06'    -- Lottablenn 
   ,@cLine08 = '%20d07'    -- Lottablenn 
   ,@cLine09 = '%20d08'    -- Lottablenn 
   ,@cLine10 = '%20d09'
   ,@cLine11 = 'RPL QTY: %05d10 %05d11'
   ,@cLine12 = 'ACT QTY: %05i12^DT:INT %05i13^DT:INT'
   ,@cLine13 = '%20d14'   -- WMS6778
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1"],"2":["2","3","4","5"],"3":["6","7","8","9"],"4":["10","11","12"],"5":["13"]}'
   ,@nFunc = 896

-- 5373 = ToLOC screen
DELETE rdt.RDTScn WHERE Scn = 5373 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5373, 'ENG',
    @cLine01 = 'FROM LOC: %10d01'
   ,@cLine02 = 'FROM ID:'
   ,@cLine03 = '%18d02'
   ,@cLine04 = 'SKU:'
   ,@cLine05 = '%20d03'
   ,@cLine06 = '%20d04'
   ,@cLine07 = '%20d05'
   ,@cLine08 = '%20d06'
   ,@cLine09 = 'RPL QTY: %05d07 %05d08'
   ,@cLine10 = 'ACT QTY: %05d09 %05d10'
   ,@cLine11 = 'ID%18i11'     
   ,@cLine12 = 'TO LOC: %10d12'
   ,@cLine13 = 'TO LOC: %10i13'
   ,@cWebGroup = '{"1":["1"],"2":["2","3"],"3":["4","5","6","7"],"4":["8","9","10"],"5":["11"],"6":["12","13"]}'
   ,@cLine14 = '%e'

-- 5374 = Confirm LOC screen
DELETE rdt.RDTScn WHERE Scn = 5374 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5374, 'ENG',
    @cLine01 = 'REPLENISH TO'
   ,@cLine02 = 'DIFFERENT LOC'
   ,@cLine03 = ''
   ,@cLine04 = 'PROCEED?'
   ,@cLine05 = ''
   ,@cLine06 = '1 = YES'
   ,@cLine07 = '9 = NO'
   ,@cLine08 = ''
   ,@cLine09 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 896

-- 5375 = Message screen
DELETE rdt.RDTScn WHERE Scn = 5375 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5375, 'ENG',
    @cLine01 = 'Replenish'
   ,@cLine02 = 'successfully'
   ,@cLine03 = ''
   ,@cLine04 = 'Press ENTER or ESC'
   ,@cLine05 = 'to continue'
   ,@cLine14 = '%e'
   ,@cAutoDisappear = '1'
   ,@nFunc = 896

-- 5376 = UCC screen
DELETE rdt.RDTScn WHERE Scn = 5376 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5376, 'ENG',
    @cLine01 = 'FROM LOC:'
   ,@cLine02 = '%10d01'
   ,@cLine03 = 'FROM ID:'
   ,@cLine04 = '%18D02'
   ,@cLine05 = 'UCC:'
   ,@cLine06 = '%60i03' -- FCR-7454
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"],"2":["3","4"],"3":["5","6"]}'
   ,@nFunc = 896
