/*
   Post pick audit rescan
*/

-- Pallet
-- 630 = Pallet ID
DELETE rdt.RDTScn WHERE Scn = 635 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 635, 'ENG', 
   @cLine01 = 'Rescan Pallet ID', 
   @cLine02 = 'Confirm?', 
   @cLine04 = '1 = Yes', 
   @cLine05 = '2 = No', 
   @cLine07 = 'Option %01i01', 
   @cLine14 = '%e'

-- 631 = Message
DELETE rdt.RDTScn WHERE Scn = 636 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 636, 'ENG', 
   @cLine02 = 'Pallet ID reset', 
   @cLine03 = '', 
   @cLine04 = 'You can now rescan', 
   @cLine05 = 'again', 
   @cLine14 = '%e'

-- Case
-- 632 = Case ID
DELETE rdt.RDTScn WHERE Scn = 637 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 637, 'ENG', 
   @cLine01 = 'Rescan Case ID', 
   @cLine02 = 'Confirm?', 
   @cLine04 = '1 = Yes', 
   @cLine05 = '2 = No', 
   @cLine07 = 'Option %01i01', 
   @cLine14 = '%e'

-- 633 = Message
DELETE rdt.RDTScn WHERE Scn = 638 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 638, 'ENG', 
   @cLine02 = 'Case ID reset', 
   @cLine03 = '', 
   @cLine04 = 'You can now rescan', 
   @cLine05 = 'again', 
   @cLine14 = '%e'
