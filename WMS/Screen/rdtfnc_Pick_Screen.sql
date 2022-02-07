-- 831 = PickSlipNo
DELETE rdt.RDTScn WHERE Scn = 831 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 831, 'ENG',
   @cLine01 = 'PSNO: %10i01',
   @cLine14 = '%e'

-- 832 = LOC, Option
DELETE rdt.RDTScn WHERE Scn = 832 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 832, 'ENG',
   @cLine01 = 'PSNO: %10d01',
   @cLine02 = '', 
   @cLine03 = 'LOC: %10d02',
   @cLine04 = 'LOC: %10i03',
   @cLine05 = '', 
   @cLine06 = 'DROP ID:',
   @cLine07 = '%40i04',
   @cLine14 = '%e'

-- 833 = SKU/UPC
DELETE rdt.RDTScn WHERE Scn = 833 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 833, 'ENG',
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

-- 834 = QTY
DELETE rdt.RDTScn WHERE Scn = 834 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 834, 'ENG',
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
   
-- 835 = UCC
DELETE rdt.RDTScn WHERE Scn = 835 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 835, 'ENG',
   @cLine01 = 'ID: %16d02',
   @cLine02 = 'SKU:',
   @cLine03 = '%20d03',
   @cLine04 = '%20d04',
   @cLine05 = '%20d05',
   @cLine06 = 'LOTTABLE 1/2/3/4:',
   @cLine07 = '1 %18d11',
   @cLine08 = '2 %18d06',
   @cLine09 = '3 %18d07',
   @cLine10 = '4 %18d08',
   @cLine11 = '',
   @cLine12 = 'UCC: %10d09', -- 9999/9999
   @cLine13 = '%20i10',
   @cLine14 = '%e'

-- 836 = ID
DELETE rdt.RDTScn WHERE Scn = 836 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 836, 'ENG',
   @cLine01 = 'ID%18d02',
   @cLine02 = 'SKU:',
   @cLine03 = '%20d03',
   @cLine04 = '%20d04',
   @cLine05 = '%20d05',
   @cLine06 = '1 %18d15',
   @cLine07 = '2 %18d06',
   @cLine08 = '3 %18d07',
   @cLine09 = '4 %18d08',
   @cLine10 = '         %05d10 %05d12', 
   @cLine11 = 'QTY:     %05d11 %05d13', 
   @cLine12 = 'ID%18i14',
   @cLine13 = '%20d01',
   @cLine14 = '%e'
   
-- 837 = Message screen
DELETE rdt.RDTScn WHERE Scn = 837 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 837, 'ENG',
   @cLine01 = '',
   @cLine02 = 'Skip Current Task?',
   @cLine03 = '',
   @cLine04 = '1 = Yes',
   @cLine05 = '2 = No',
   @cLine06 = '',
   @cLine07 = '',
   @cLine08 = 'Option: %01i01',
   @cLine14 = '%e'

-- 838 = Message screen
DELETE rdt.RDTScn WHERE Scn = 838 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 838, 'ENG',
   @cLine01 = '',
   @cLine02 = 'Confirm Short Pick?',
   @cLine04 = '',
   @cLine05 = '1 = Yes',
   @cLine06 = '2 = No',
   @cLine07 = '',
   @cLine08 = 'Option: %01i01',
   @cLine14 = '%e'

-- 839 = Message screen
DELETE rdt.RDTScn WHERE Scn = 839 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 839, 'ENG',
   @cLine01 = '',
   @cLine02 = 'No more task(s) in LOC',
   @cLine03 = '%10d01',
   @cLine04 = '',
   @cLine05 = 'Press ENTER or ESC',
   @cLine06 = 'to continue',
   @cLine14 = '%e'

-- 840 = Message screen
DELETE rdt.RDTScn WHERE Scn = 840 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 840, 'ENG',
   @cLine01 = '',
   @cLine02 = 'Abort Task?',
   @cLine03 = '',
   @cLine04 = '1 = Yes',
   @cLine05 = '2 = No',
   @cLine06 = '',
   @cLine07 = 'Option: %01i01',
   @cLine14 = '%e'

-- 841 = Message screen
DELETE rdt.RDTScn WHERE Scn = 841 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 841, 'ENG',
     @cLine01 = 'Print Pallet'
    ,@cLine02 = 'Manifest'
    ,@cLine03 = 'Report/Label'
    ,@cLine05 = '1 = Pallet Man Rpt'
    ,@cLine06 = '2 = Pallet Man Lbl'
    ,@cLine07 = 'ESC = No Printing'    
    ,@cLine09 = 'Option: %01i01'
    ,@cLine14 = '%e'

-- 842 = Message screen
DELETE rdt.RDTScn WHERE Scn = 842 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 842, 'ENG',
   @cLine01 = 'LOC NOT MATCH',
   @cLine02 = 'PROCEED?',
   @cLine03 = '',
   @cLine05 = '1 = YES',
   @cLine06 = '2 = NO',
   @cLine07 = '',
   @cLine08 = 'OPTION: %01i01',
   @cLine14 = '%e'

-- 843 = Message screen
DELETE rdt.RDTScn WHERE Scn = 843 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 843, 'ENG',
   @cLine01 = '%20d01',
   @cLine02 = '%20d02',
   @cLine03 = '%20d03',
   @cLine04 = '%20d04',
   @cLine05 = '%20d05',
   @cLine06 = '%20d06',
   @cLine07 = '%20d07',
   @cLine08 = '%20d08',
   @cLine09 = '%20d09',
   @cLine10 = '%20d10',
   @cLine11 = '%20d11',
   @cLine12 = '%20d12',
   @cLine13 = '%20d13',
   @cLine14 = '%e'