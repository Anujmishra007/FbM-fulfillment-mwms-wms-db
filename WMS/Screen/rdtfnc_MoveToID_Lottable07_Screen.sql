
IF NOT EXISTS (SELECT 1 FROM rdt.rdtmsg (NOLOCK) WHERE Message_ID=648 AND Message_Type='fnc')
BEGIN 
   INSERT INTO rdt.rdtmsg(Message_ID,Lang_Code,Message_Type,Message_Text,StoredProcName)
   VALUES('648','ENG','FNC','MOVETOID lottable07', 'rdtfnc_MoveToID_Lottable07')

END


--rdtfnc_MoveToID_Lottable07
-- 3390 = TO ID
DELETE rdt.RDTScn WHERE Scn = 5960 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5960, 'ENG'
   ,@cLine01 = 'TO ID:'
   ,@cLine02 = '%18i01'
   ,@cLine14 = '%e'
   ,@nFunc = 648

-- 3391 = FROM LOC
DELETE rdt.RDTScn WHERE Scn = 5961 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5961, 'ENG'
   ,@cLine01 = 'TO ID:'
   ,@cLine02 = '%18d01'
   ,@cLine03 = 'FROM LOC: %10i02'
   ,@cLine14 = '%e'
   ,@nFunc = 648

-- 3392 = SKU, QTY
DELETE rdt.RDTScn WHERE Scn = 5962 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5962, 'ENG'
   ,@cLine01 = 'FROM LOC: %10d01'
   ,@cLine02 = 'SKU/UPC:'
   ,@cLine03 = '%60i02'
   ,@cLine14 = '%e'
   ,@nFunc = 648

-- 3392 = SKU, QTY
DELETE rdt.RDTScn WHERE Scn = 5963 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5963, 'ENG'
   ,@cLine01 = 'FROM LOC: %10d01'
   ,@cLine02 = 'SKU/UPC:'
   ,@cLine03 = '%60d02'
   ,@cLine04 = '%20d03'
   ,@cLine05 = '%20d04'
   ,@cLine06 = '%20d05'
   ,@cLine07 = ''
   ,@cLine08 = '%08d12 %05d06 %05d09'
   ,@cLine09 = 'QTY AVL: %05d07 %05d10'
   ,@cLine10 = 'QTY MV:  %05i08 %05i11'
   ,@cLine11 = ''
   ,@cLine12 = 'QTY ID: %05d13'
   ,@cLine14 = '%e'
   ,@nFunc = 648

 -- 3393 = Close ToID screen
DELETE rdt.RDTScn WHERE Scn = 5964 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5964, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'CLOSE TO ID?'
   ,@cLine03 = ''
   ,@cLine04 = '1 = YES'
   ,@cLine05 = '2 = NO'
   ,@cLine07 = ''
   ,@cLine08 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 648

-- 3394 = To LOC
DELETE rdt.RDTScn WHERE Scn = 5965 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5965, 'ENG'
   ,@cLine01 = 'TO LOC: %10i01'
   ,@cLine14 = '%e'
   ,@nFunc = 648
