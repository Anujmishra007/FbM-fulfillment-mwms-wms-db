-- FCR-3830
IF NOT EXISTS(SELECT 1 FROM rdt.RDTMsg WITH(NOLOCK) WHERE Message_ID = 664 AND Lang_Code = 'ENG' AND Message_Type = 'FNC')
   INSERT INTO rdt.RDTMsg(Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, EventType, Func, URL, Message_Text_Long)
   VALUES( 664, 'ENG', 'FNC', 'Move ID Before Finalization', 'rdtfnc_MoveIDBeforeFinalization', '0', '0', '', '' )

-- 6600 = FromID
DELETE rdt.RDTScn WHERE Scn = 6600 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6600, 'ENG'
   ,@cLine01 = 'From ID'
   ,@cLine02 = '%20i01' -- %20i01 (FromID)
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"]}'
   ,@nFunc = 664

-- 6601 = FromLoc
DELETE rdt.RDTScn WHERE Scn = 6601 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6601, 'ENG'
   ,@cLine01 = 'From ID'
   ,@cLine02 = '%20d01' -- %20i01 (FromID)
   ,@cLine03 = 'From Loc'
   ,@cLine04 = '%10i02' -- %10i03 (From Loc)
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"],"2":["3","4"]}'
   ,@nFunc = 664

-- 6602 = ToLoc
DELETE rdt.RDTScn WHERE Scn = 6602 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6602, 'ENG'
   ,@cLine01 = 'From ID'
   ,@cLine02 = '%18d01'          -- %18d01 (FromID)
   ,@cLine03 = 'From Loc:%10d02' -- %10d01 (FromLoc)
   ,@cLine04 = ''
   ,@cLine05 = 'SKU:%10d03'      -- %10d03 (CurrentSkuQty/TotalSkuQty)
   ,@cLine06 = '%20d04'          -- %20d04 (SKU Code)
   ,@cLine07 = '%20d05'          -- %20d04 (SKU Desc1)
   ,@cLine08 = '%20d06'          -- %20d04 (SKU Desc2)
   ,@cLine09 = 'UOM: %05d07 %05d09' -- %05d07 (UOM1)  %05d09 (UOM2)
   ,@cLine10 = 'QTY: %05d08 %05d10' -- %05d08 (Qty)   %05d10 (Qty)
   ,@cLine11 = '%20d12'    -- %10d12 (SuggLoc)
   ,@cLine12 = 'To Loc:%10i11'    -- %10i11 (ToLoc)
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2","3","4"],"2":["5","6","7","8"],"3":["9","10","11"],"4":["12"]}'
   ,@nFunc = 664

-- 6603 = Msg screen
DELETE rdt.RDTScn WHERE Scn = 6603 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6603, 'ENG'
   ,@cLine01 = 'ID Moved'
   ,@cLine02 = 'successfully' 
   ,@cLine03 = 'To Loc:%10d01'
   ,@cLine04 = '' 
   ,@cLine05 = 'Press Enter or ESC'
   ,@cLine06 = 'to continue'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2","3","4"],"2":["5","6"]}'
   ,@nFunc = 664
