--rdtfnc_Pick_CaptureDropID
--5050-5059

IF NOT EXISTS ( SELECT 1 FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID = 955 AND Message_Type = 'FNC')
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES (955, 'ENG', 'FNC', 'Pick (Scan DropID)', 'rdtfnc_Pick_CaptureDropID', '3')


-- 5050 = PickSlipNo
DELETE rdt.RDTScn WHERE Scn = 5050 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5050, 'ENG',
   @cLine01 = 'PSNO: %10i01',
   @cLine14 = '%e'

-- 5051 = LOC, Option
DELETE rdt.RDTScn WHERE Scn = 5051 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5051, 'ENG',
   @cLine01 = 'PSNO: %10d01',
   @cLine02 = '', 
   @cLine03 = 'LOC: %10d02',
   @cLine04 = 'LOC: %10i03',
   @cLine14 = '%e'

-- 5052 = SKU/UPC
DELETE rdt.RDTScn WHERE Scn = 5052 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5052, 'ENG',
   @cLine01 = 'LOC: %10d01',
   @cLine02 = 'ID: %16d02',
   @cLine03 = 'SKU:',
   @cLine04 = '%20d03',
   @cLine05 = '%20d04',
   @cLine06 = '%20d05',
   @cLine07 = 'LOTTABLE 1/2/3/4',
   @cLine08 = '1 %18d10',
   @cLine09 = '2 %18d06',
   @cLine10 = '3 %18d07',
   @cLine11 = '4 %18d08',
   @cLine12 = 'SKU/UPC:',
   @cLine13 = '%60i09',
   @cLine14 = '%e'

-- 5053 = QTY
DELETE rdt.RDTScn WHERE Scn = 5053 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5053, 'ENG',
   @cLine01 = 'ID: %16d02',
   @cLine02 = 'SKU:        PPK: %03d09',
   @cLine03 = '%20d03',
   @cLine04 = '%20d04',
   @cLine05 = '%20d05',
   @cLine06 = 'LOTTABLE 1/2/3/4',
   @cLine07 = '1 %18d01',
   @cLine08 = '2 %18d06',
   @cLine09 = '3 %18d07',
   @cLine10 = '4 %18d08',
   @cLine11 = '         %05d10 %05d12', 
   @cLine12 = 'QTY:     %05d11 %05d13', 
   @cLine13 = 'QTY:     %05i14 %05i15', 
   @cLine14 = '%e'

-- 5054 = Message screen
DELETE rdt.RDTScn WHERE Scn = 5054 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5054, 'ENG',
   @cLine01 = 'DROP ID:    %07d01',
   @cLine02 = '%50i02',
   @cLine14 = '%e'

-- 5055 = Message screen
DELETE rdt.RDTScn WHERE Scn = 5055 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5055, 'ENG',
   @cLine01 = '',
   @cLine02 = 'Skip Current Task?',
   @cLine03 = '',
   @cLine04 = '1 = Yes',
   @cLine05 = '2 = No',
   @cLine06 = '',
   @cLine07 = '',
   @cLine08 = 'Option: %01i01',
   @cLine14 = '%e'

-- 5056 = Message screen
DELETE rdt.RDTScn WHERE Scn = 5056 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5056, 'ENG',
   @cLine01 = '',
   @cLine02 = 'Confirm Short Pick?',
   @cLine04 = '',
   @cLine05 = '1 = Yes',
   @cLine06 = '2 = No',
   @cLine07 = '',
   @cLine08 = 'Option: %01i01',
   @cLine14 = '%e'

-- 5057 = Message screen
DELETE rdt.RDTScn WHERE Scn = 5057 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5057, 'ENG',
   @cLine01 = '',
   @cLine02 = 'No more task(s) in LOC',
   @cLine03 = '%10d01',
   @cLine04 = '',
   @cLine05 = 'Press ENTER or ESC',
   @cLine06 = 'to continue',
   @cLine14 = '%e'

-- 5058 = Match Loc
DELETE rdt.RDTScn WHERE Scn = 5058 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 842, 'ENG',
   @cLine01 = 'LOC NOT MATCH',
   @cLine02 = 'PROCEED?',
   @cLine03 = '',
   @cLine05 = '1 = YES',
   @cLine06 = '2 = NO',
   @cLine07 = '',
   @cLine08 = 'OPTION: %01i01',
   @cLine14 = '%e'

