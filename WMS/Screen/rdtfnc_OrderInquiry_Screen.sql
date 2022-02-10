--scn 4120 - 4129

INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
VALUES ('596', 'ENG', 'FNC', 'Order Inquiry', 'rdtfnc_OrderInquiry', '0')


-- 4120 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4120 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4120, 'ENG',
    @cLine01 = 'ORDER INQUIRY'
   ,@cLine03 = 'ORDERKEY:'
   ,@cLine04 = '%10i01'
   ,@cLine14 = '%e'
   ,@nFunc = 596

-- 4121 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4121 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4121, 'ENG',
    @cLine01 = 'ORDER INQUIRY'
   ,@cLine03 = '%20d01'
   ,@cLine04 = '%20d02'
   ,@cLine05 = '%20d03'
   ,@cLine06 = '%20d04'
   ,@cLine07 = '%20d05'
   ,@cLine08 = '%20d06'
   ,@cLine09 = '%20d07'
   ,@cLine10 = '%20d08'
   ,@cLine11 = '%20d09'
   ,@cLine12 = '%20d10'
   ,@cLine14 = '%e'
   ,@nFunc = 596



select * from rdt.rdtscn with (nolock) where scn between 4120 and 4129 
