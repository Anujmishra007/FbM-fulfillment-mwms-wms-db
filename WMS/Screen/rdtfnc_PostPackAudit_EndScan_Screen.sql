/*
   Post pick audit end scan
*/

-- Pallet
-- 630 = Pallet ID
DELETE rdt.RDTScn WHERE Scn = 630 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 630, 'ENG', 
   @cLine01 = 'Once pallet closed,', 
   @cLine02 = 'cannot revert back', 
   @cLine03 = 'Confirm?', 
   @cLine04 = '', 
   @cLine05 = '1 = Yes', 
   @cLine06 = '2 = No', 
   @cLine07 = '', 
   @cLine08 = 'Option %01i01', 
   @cLine09 = '', 
   @cLine14 = '%e'

-- 631 = Message
DELETE rdt.RDTScn WHERE Scn = 631 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 631, 'ENG', 
   @cLine02 = 'Pallet ID closed', 
   @cLine03 = '', 
   @cLine04 = 'You can now scan a', 
   @cLine05 = 'new pallet / case', 
   @cLine06 = 'again', 
   @cLine14 = '%e'

-- Case
-- 632 = Case ID
DELETE rdt.RDTScn WHERE Scn = 632 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 632, 'ENG', 
   @cLine01 = 'Once case closed,', 
   @cLine02 = 'cannot revert back', 
   @cLine03 = 'Confirm?', 
   @cLine04 = '', 
   @cLine05 = '1 = Yes', 
   @cLine06 = '2 = No', 
   @cLine07 = '', 
   @cLine08 = 'Option %01i01', 
   @cLine09 = '', 
   @cLine14 = '%e'

-- 633 = Message
DELETE rdt.RDTScn WHERE Scn = 633 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 633, 'ENG', 
   @cLine02 = 'Case ID closed', 
   @cLine03 = '', 
   @cLine04 = 'You can now scan a', 
   @cLine05 = 'new pallet / case', 
   @cLine06 = 'again', 
   @cLine14 = '%e'
