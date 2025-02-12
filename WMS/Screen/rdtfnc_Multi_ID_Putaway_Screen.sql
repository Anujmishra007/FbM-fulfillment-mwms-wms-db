--rdtfnc_Multi_ID_Putaway
-- 6450 - 6459

IF NOT EXISTS (SELECT 1 FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID = '747')
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES ('747', 'ENG', 'FNC', 'Multi ID Putaway', 'rdtfnc_Multi_ID_Putaway', '0')

-- Screen 1
-- Scn = 6450
DELETE rdt.RDTScn WHERE Scn = 6450 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6450, 'ENG', 
   @cLine01 = 'Multiple ID Putaway',
   @cLine03 = 'Scan Trolley/',
   @cLine04 = 'Location:',
   @cLine05 = '%20i01',
   @cLine14 = '%e'

-- Screen 2
-- Scn = 6451 
DELETE rdt.RDTScn WHERE Scn = 6451 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6451, 'ENG', 
   @cLine01 = 'Choose Action:',
   @cLine03 = '1.Add More IDs to',
   @cLine04 = 'trolley',
   @cLine05 = '9.Continue Putaway',
   @cLine07 = 'Options:%01i01',
   @cLine14 = '%e'

-- Screen 3
-- Scn = 6452
DELETE rdt.RDTScn WHERE Scn = 6452 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6452, 'ENG', 
   @cLine01 = 'Trolley/Cart:',
   @cLine02 = '%20d01',
   @cLine04 = 'ID:',
   @cLine05 = '%20d02',
   @cLine07 = 'Suggested Location:',
   @cLine08 = '%20d03',
   @cLine09 = 'Location:',
   @cLine10 = '%20i04',
   @cLine14 = '%e'

-- Screen 4
-- Scn = 6453
DELETE rdt.RDTScn WHERE Scn = 6453 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6453, 'ENG', 
   @cLine01 = 'ID:%20d01',
   @cLine03 = 'LOC:%20d02',
   @cLine05 = 'ID:',
   @cLine06 = '%20i03',
   @cLine14 = '%e'

-- Screen 5
-- Scn = 6454
DELETE rdt.RDTScn WHERE Scn = 6454 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6454, 'ENG', 
   @cLine01 = 'Putaway Successful!',
   @cLine03 = 'Enter = Next ID',
   @cLine04 = 'ESC   = EXIT',
   @cLine14 = '%e'

-- Screen 6
-- Scn = 6455
DELETE rdt.RDTScn WHERE Scn = 6455 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6455, 'ENG', 
   @cLine01 = 'Scan ID to add to',
   @cLine02 = 'trolley:',
   @cLine03 = '%20i01',
   @cLine14 = '%e'

-- Screen 7
-- Scn = 6456
DELETE rdt.RDTScn WHERE Scn = 6456 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6456, 'ENG', 
   @cLine02 = 'ID added to cart',
   @cLine04 = 'Please press Enter',
   @cLine05 = 'Or ESC to continue',
   @cLine14 = '%e'

-- Screen 8
-- Scn = 6457
DELETE rdt.RDTScn WHERE Scn = 6457 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6457, 'ENG', 
   @cLine01 = 'REASON CODE',
   @cLine02 = '%20i01',
   @cLine14 = '%e'

-- Screen 9
-- Scn = 6458
DELETE rdt.RDTScn WHERE Scn = 6458 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6458, 'ENG', 
   @cLine01 = 'Alternate location',
   @cLine02 = 'could not be',
   @cLine03 = 'determined.',
   @cLine04 = 'ID:%20d02',
   @cLine05 = 'Options:',
   @cLine07 = '1.Go Back',
   @cLine08 = '9.Move to QC',
   @cLine10 = 'Options:%01i01',
   @cLine14 = '%e'
         