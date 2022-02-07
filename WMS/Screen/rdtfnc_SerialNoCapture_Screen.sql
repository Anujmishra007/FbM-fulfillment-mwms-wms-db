-- 870 = PickSlipNo screen
DELETE rdt.RDTScn WHERE Scn = 870 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 870, 'ENG',
    @cLine01 = 'Serial No Capture'
   ,@cLine02 = ''
   ,@cLine03 = 'Pick Slip No:'
   ,@cLine04 = '%10i01'
   ,@cLine14 = '%e'
 
-- 871 = SKU/UPC screen
DELETE rdt.RDTScn WHERE Scn = 871 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 871, 'ENG',
    @cLine01 = 'Serial No Capture'
   ,@cLine02 = ''
   ,@cLine03 = 'Pick Slip No:'
   ,@cLine04 = '%10d01'
   ,@cLine05 = ''
   ,@cLine06 = 'SKU/UPC:'
   ,@cLine07 = '%20i02'
   ,@cLine08 = ''
   ,@cLine09 = ''
   ,@cLine10 = ''
   ,@cLine11 = ''
   ,@cLine12 = ''
   ,@cLine13 = 'Remaining: %10d05'
   ,@cLine14 = '%e'

-- 872 = LOT screen
DELETE rdt.RDTScn WHERE Scn = 872 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 872, 'ENG',
    @cLine01 = 'Serial No Capture'
   ,@cLine02 = 'Pick Slip No:'
   ,@cLine03 = '%10d01'
   ,@cLine04 = ''
   ,@cLine05 = 'SKU/UPC:'
   ,@cLine06 = '%20d02'
   ,@cLine07 = ''
   ,@cLine08 = 'Lot No:'
   ,@cLine09 = '%20i03'
   ,@cLine10 = ''
   ,@cLine11 = ''
   ,@cLine12 = ''
   ,@cLine13 = 'Remaining: %10d05'
   ,@cLine14 = '%e'
   
-- 873 = SerialNo screen
DELETE rdt.RDTScn WHERE Scn = 873 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 873, 'ENG',
    @cLine01 = 'Serial No Capture'
   ,@cLine02 = 'Pick Slip No:'
   ,@cLine03 = '%10d01'
   ,@cLine04 = ''
   ,@cLine05 = 'SKU/UPC:'
   ,@cLine06 = '%20d02'
   ,@cLine07 = ''
   ,@cLine08 = 'Lot No:'
   ,@cLine09 = '%20d03'
   ,@cLine10 = ''
   ,@cLine11 = 'Serial No:'
   ,@cLine12 = '%30i04'       -- (Modified for SOS#315487 - extend field length to 30 char)
   ,@cLine13 = 'Remaining: %10d05'
   ,@cLine14 = '%e'

-- 874 = QTY screen
DELETE rdt.RDTScn WHERE Scn = 874 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 874, 'ENG',
    @cLine01 = 'Serial No Capture'
   ,@cLine02 = ''
   ,@cLine03 = 'QTY: %05i01'
   ,@cLine14 = '%e'
 
-- 875 = Short screen
DELETE rdt.RDTScn WHERE Scn = 875 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 875, 'ENG',
    @cLine01 = 'Serial No Capture'
   ,@cLine02 = ''
   ,@cLine03 = '%20d01'
   ,@cLine04 = 'is short picked.'
   ,@cLine05 = ''
   ,@cLine06 = 'Pls scan again'
   ,@cLine07 = 'or unallocated.'
   ,@cLine08 = ''
   ,@cLine09 = '1 = scan again'
   ,@cLine10 = '2 = unallocated'
   ,@cLine11 = ''
   ,@cLine12 = 'Option: %01i02'
   ,@cLine14 = '%e'

UPDATE RDT.RDTSCN SET FUNC = 872 WHERE SCN BETWEEN 870 AND 875
