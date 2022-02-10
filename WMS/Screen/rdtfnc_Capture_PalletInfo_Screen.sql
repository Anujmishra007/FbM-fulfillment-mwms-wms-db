--rdtfnc_Capture_PalletInfo
--5110 - 5119

IF NOT EXISTS ( SELECT 1 FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID = 825 AND Message_Type = 'FNC')
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES (825, 'ENG', 'FNC', 'CAPTURE PALLET INFO', 'rdtfnc_Capture_PalletInfo', '9')

-- 5110 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 5110 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5110, 'ENG'
   ,@cLine01 = N'DEFAULT VALUES'
   ,@cLine02 = N'LENGTH: %10i01'
   ,@cLine04 = N'WIDTH:  %10i02'
   ,@cLine06 = N'HEIGHT: %10i03'
   ,@cLine08 = N'WEIGHT: %10i04'
   ,@cLine10 = N'%10d05  %10i06'
   ,@cLine14 = N'%e'

-- 5111 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 5111 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5111, 'ENG'
   ,@cLine01 = N'PALLETKEY: '
   ,@cLine02 = N'%30i01'
   ,@cLine14 = N'%e'

-- 5112 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 5112 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5112, 'ENG'
   ,@cLine01 = N'PALLETKEY:'
   ,@cLine02 = N'%30d01'
   ,@cLine04 = N'LENGTH: %10i02'
   ,@cLine06 = N'WIDTH:  %10i03'
   ,@cLine08 = N'HEIGHT: %10i04'
   ,@cLine10 = N'WEIGHT: %10i05'
   ,@cLine12 = N'%10d06  %10i07'
   ,@cLine14 = N'%e'
 
