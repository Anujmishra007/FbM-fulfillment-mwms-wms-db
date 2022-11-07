--rdtfnc_PalletInquiry
--6150-6159

IF NOT EXISTS ( SELECT 1 FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID = 1667 AND Message_Type = 'FNC')
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES (1667, 'ENG', 'FNC', 'Pallet Inquiry', 'rdtfnc_PalletInquiry', '9')

-- 6150 = PalletKey or OrderKey
DELETE rdt.RDTScn WHERE Scn = 6150 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6150, 'ENG',
    @cLine01 = 'PALLET INQUIRY'
   ,@cLine02 = ''
   ,@cLine03 = 'PALLETKEY:'
   ,@cLine04 = '%20i01'
   ,@cLine05 = ''
   ,@cLine06 = 'ORDERKEY:'
   ,@cLine07 = '%10i02'
   ,@cLine08 = ''
   ,@cLine09 = ''
   ,@cLine10 = ''
   ,@cLine11 = ''
   ,@cLine12 = ''
   ,@cLine13 = ''
   ,@cLine14 = '%e'
   ,@nFunc = 1667   

-- 6151 = PalletKey, Carton ID
DELETE rdt.RDTScn WHERE Scn = 6151 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6151, 'ENG',
    @cLine01 = 'PALLETKEY:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = ''
   ,@cLine04 = 'CARTON ID:'
   ,@cLine05 = '%20i02'
   ,@cLine06 = ''
   ,@cLine07 = 'BLANK CARTON ID'
   ,@cLine08 = 'REMOVE ALL'
   ,@cLine09 = ''
   ,@cLine10 = ''
   ,@cLine11 = ''
   ,@cLine12 = ''
   ,@cLine13 = ''
   ,@cLine14 = '%e'
   ,@nFunc = 1667   

-- 6152 = Confirm remove all carton from pallet
DELETE rdt.RDTScn WHERE Scn = 6152 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6152, 'ENG',
    @cLine01 = 'CONFIRM TO REMOVE'
   ,@cLine02 = 'ALL CARTON FROM'
   ,@cLine03 = 'THIS PALLET ?'
   ,@cLine04 = ''
   ,@cLine05 = '1 = YES'
   ,@cLine06 = '2 = NO'
   ,@cLine07 = ''
   ,@cLine08 = 'OPTION: %01i01'
   ,@cLine09 = ''
   ,@cLine10 = ''
   ,@cLine11 = ''
   ,@cLine12 = ''
   ,@cLine13 = ''
   ,@cLine14 = '%e'
   ,@nFunc = 1667   
   
-- 6153 = Orderkey, PalletKey, Carton ID
DELETE rdt.RDTScn WHERE Scn = 6153 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6153, 'ENG',
    @cLine01 = 'ORDERKEY: %10d01'
   ,@cLine02 = 'PALLETKEY:'
   ,@cLine03 = '%20d02'
   ,@cLine04 = '%20d03'
   ,@cLine05 = '%20d04'
   ,@cLine06 = '%20d05'
   ,@cLine07 = '%20d06'
   ,@cLine08 = '%20d07'
   ,@cLine09 = '%20d08'
   ,@cLine10 = 'ENTER FOR NEXT PLT'
   ,@cLine11 = ''
   ,@cLine12 = 'CARTON ID/TRACK NO:'
   ,@cLine13 = '%20i09'
   ,@cLine14 = '%e'
   ,@nFunc = 1667   

-- 6154 = Confirm remove this carton from pallet
DELETE rdt.RDTScn WHERE Scn = 6154 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6154, 'ENG',
    @cLine01 = 'CONFIRM TO REMOVE'
   ,@cLine02 = 'THIS CARTON'
   ,@cLine03 = '%20d01'
   ,@cLine04 = 'FROM THIS PALLET ?'
   ,@cLine05 = '%20d02'
   ,@cLine06 = ''
   ,@cLine07 = '1 = YES'
   ,@cLine08 = '2 = NO'
   ,@cLine09 = 'OPTION: %01i03'
   ,@cLine10 = ''
   ,@cLine11 = ''
   ,@cLine12 = ''
   ,@cLine13 = ''
   ,@cLine14 = '%e'
   ,@nFunc = 1667   

-- 6155 = Message
DELETE rdt.RDTScn WHERE Scn = 6155 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6155, 'ENG',
    @cLine01 = 'CARTON REMOVED'
   ,@cLine02 = ''
   ,@cLine03 = 'PRESS ENTER/ESC'
   ,@cLine04 = 'TO GO BACK'
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
   ,@nFunc = 1667   