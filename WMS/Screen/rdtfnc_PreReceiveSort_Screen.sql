--rdtfnc_PreReceiveSort
--4800 - 4809

IF NOT EXISTS ( SELECT 1 FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID = 1825 AND Message_Type = 'FNC')
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES (1825, 'ENG', 'FNC', 'PRE RECEIVE SORT', 'rdtfnc_PreReceiveSort', '9')

-- 4800 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4800 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4800, 'ENG',
    @cLine01 = 'PRE RECEIVE SORT'
   ,@cLine02 = ''
   ,@cLine03 = 'ASN:'
   ,@cLine04 = '%10i01'
   ,@cLine05 = ''
   ,@cLine06 = 'LANE:'
   ,@cLine07 = '%10i02'
   ,@cLine14 = '%e'
   ,@nFunc = 1825

-- 4801 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4801 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4801, 'ENG',
    @cLine01 = 'ASN:  %10d01'
   ,@cLine02 = 'LANE: %10d02'
   ,@cLine03 = 'UCC:'
   ,@cLine04 = '%20i03'
   ,@cLine14 = '%e'
   ,@nFunc = 1825

-- 4802 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4802 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4802, 'ENG',
    @cLine01 = 'UCC:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = ''
   ,@cLine04 = 'POSITION:'
   ,@cLine05 = '%20d02'
   ,@cLine06 = '%20d15'
   ,@cLine07 = '%20d03'
   ,@cLine14 = '%e'
   ,@nFunc = 1825
