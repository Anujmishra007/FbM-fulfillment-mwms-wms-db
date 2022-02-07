--rdtfnc_PreReceiveSort2
--4980 - 4989

IF NOT EXISTS ( SELECT 1 FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID = 1829 AND Message_Type = 'FNC')
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES (1829, 'ENG', 'FNC', 'PRE RECEIVE SORT', 'rdtfnc_PreReceiveSort2', '9')

-- 4980 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4980 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4980, 'ENG',
    @cLine01 = 'PRE RECEIVE SORT'
   ,@cLine02 = '%20d01'
   ,@cLine03 = '%20i02'
   ,@cLine04 = '%20d03'
   ,@cLine05 = '%20i04'
   ,@cLine06 = '%20d05'
   ,@cLine07 = '%20i06'
   ,@cLine08 = '%20d07'
   ,@cLine09 = '%20i08'
   ,@cLine10 = '%20d09'
   ,@cLine11 = '%20i10'
   ,@cLine13 = 'END SORTING?(1=YES)%01i11'
   ,@cLine14 = '%e'
   ,@nFunc = 1829

-- 4981 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4981 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4981, 'ENG',
    @cLine01 = 'UCC OR SKU/UPC:' -- (james02)
   ,@cLine02 = '%20i01'
   ,@cLine03 = '%20d02'
   ,@cLine04 = '%20d03'
   ,@cLine05 = '%20d04'
   ,@cLine06 = '%20d05'
   ,@cLine07 = '%20d06'
   ,@cLine08 = '%20d07'
   ,@cLine09 = '%20d08'
   ,@cLine10 = '%20d09'
   ,@cLine11 = '%20d10'
   ,@cLine12 = '%20d11'
   ,@cLine13 = '%20d12'
   ,@cLine14 = '%e'
   ,@nFunc = 1829

-- 4982 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4982 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4982, 'ENG',
    @cLine01 = 'UCC:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = ''
   ,@cLine04 = '%20d02'
   ,@cLine05 = '%20d03'
   ,@cLine06 = '%20d04'
   ,@cLine07 = '%20d05'
   ,@cLine08 = '%20d06'
   ,@cLine09 = '%20d07'
   ,@cLine10 = '%20d08'
   ,@cLine11 = '%20d09'
   ,@cLine12 = '%20d10'
   ,@cLine13 = '%20i11'
   ,@cLine14 = '%e'   
   ,@nFunc = 1829

-- 4983 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4983 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4983, 'ENG',
    @cLine01 = 'END PRE SORTING?'
   ,@cLine02 = ''
   ,@cLine03 = '1 = YES'
   ,@cLine04 = '2 = NO'
   ,@cLine05 = 'OPTION: %01i01'
   ,@cLine14 = '%e'   
   ,@nFunc = 1829

-- 4984 = ?? screen (WMS-8010)
DELETE rdt.RDTScn WHERE Scn = 4984 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4984, 'ENG',
    @cLine01 = 'Qty: %05i01 %05d02'
   ,@cLine13 = '%20d15'
   ,@cLine14 = '%e'   
   ,@nFunc = 1829
