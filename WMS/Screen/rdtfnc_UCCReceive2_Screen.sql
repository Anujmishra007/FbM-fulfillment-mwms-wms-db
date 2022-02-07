--rdtfnc_UCCReceive2
--4950 - 4959

IF NOT EXISTS ( SELECT 1 FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID = 1582 AND Message_Type = 'FNC')
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES (1582, 'ENG', 'FNC', 'CARTON RECEIVE ', 'rdtfnc_UCCReceive2', '1')

-- 4950 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4950 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4950, 'ENG',
    @cLine01 = 'CARTON ID RECEIVE'
   ,@cLine02 = ''
   ,@cLine03 = 'CARTON ID:'
   ,@cLine04 = '%20i01'
   ,@cLine05 = ''
   ,@cLine06 = 'ASN: %10i02'
   ,@cLine07 = 'PO:  %10i03'
   ,@cLine14 = '%e'
   ,@nFunc = 1582

-- 4951 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4951 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4951, 'ENG',
    @cLine01 = 'CARTON ID:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = 'ASN: %10d02'
   ,@cLine04 = 'SKU/UPC:'
   ,@cLine05 = '%20i03'
   ,@cLine06 = '%20d09'
   ,@cLine07 = '%20d04'
   ,@cLine08 = '%20d05'
   ,@cLine09 = 'EXP:  %05d06'
   ,@cLine10 = 'RCV:  %05d07'
   ,@cLine11 = 'QTY:  %05i08'
   ,@cLine14 = '%e'
   ,@nFunc = 1582

-- 4952 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4952 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4952, 'ENG',
    @cLine01 = 'CARTON ID:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = 'ASN: %10d02'
   ,@cLine04 = 'QTY: %05d03 %05d04'
   ,@cLine06 = 'TO ID:'
   ,@cLine07 = '%18i05'
   ,@cLine08 = 'TO ID Qty: %05d06'
   ,@cLine09 = 'TO LOC: %10i07'
   ,@cLine14 = '%e'   
   ,@nFunc = 1582