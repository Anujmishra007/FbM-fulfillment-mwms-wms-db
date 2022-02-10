--rdtfnc_CartPicking_PrintLabel
--5740-5749

IF NOT EXISTS ( SELECT 1 FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID = 646 AND Message_Type = 'FNC')
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES (646, 'ENG', 'FNC', 'Cart Picking Label', 'rdtfnc_CartPicking_PrintLabel', '9')

-- 5740 = Lock user task screen
DELETE rdt.RDTScn WHERE Scn = 5740 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5740, 'ENG',
    @cLine01 = 'CART PICKING LABEL'
   ,@cLine02 = ''
   ,@cLine03 = 'AREA: %10i01'
   ,@cLine04 = ''
   ,@cLine05 = 'CART ID: %10i02'
   ,@cLine06 = ''
   ,@cLine07 = 'USER ID:'
   ,@cLine08 = '%20i03'
   ,@cLine09 = ''
   ,@cLine10 = 'TASK TYPE: %10i04'
   ,@cLine11 = ''
   ,@cLine12 = 'NO OF CARTON: %02i05'
   ,@cLine13 = ''
   ,@cLine14 = '%e'
   ,@nFunc = 5740

-- 5741 = lABEL PRINTED screen
DELETE rdt.RDTScn WHERE Scn = 5741 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5741, 'ENG',
    @cLine01 = 'CART PICKING LABEL'
   ,@cLine02 = ''
   ,@cLine03 = 'PLEASE TAKE LABEL'
   ,@cLine04 = 'NO OF LABEL: %02d01'
   ,@cLine05 = ''
   ,@cLine06 = ''
   ,@cLine07 = ''
   ,@cLine08 = ''
   ,@cLine09 = ''
   ,@cLine10 = ''
   ,@cLine11 = ''
   ,@cLine12 = ''
   ,@cLine13 = ''
   ,@cLine14 = '%e'
   ,@nFunc = 5741
