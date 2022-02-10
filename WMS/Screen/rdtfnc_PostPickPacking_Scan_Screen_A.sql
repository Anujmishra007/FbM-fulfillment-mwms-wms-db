/*
   Post pick audit scan
*/

-- Pallet
-- 610 = WorkStation
DELETE rdt.RDTScn WHERE Scn = 610 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 610, 'ENG', 
   @cLine01 = 'SCANNER A',
   @cLine02 = '',
   @cLine03 = 'WORKSTATION:',
   @cLine04 = '%15i01*', 
   @cLine05 = '',
   @cLine06 = '%e'

-- 611 = Store, Pallet ID
DELETE rdt.RDTScn WHERE Scn = 611 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 611, 'ENG', 
   @cLine01 = 'SCANNER A',
   @cLine02 = '',
   @cLine03 = 'STOR:',
   @cLine04 = '%15i01',
   @cLine05 = '',
   @cLine06 = 'PALLET ID: ',
   @cLine07 = '%18i02', 
   @cLine08 = '',
   @cLine09 = '%e'

-- 612 = Case ID, QTY, SKU, Desc, TotalQTY
DELETE rdt.RDTScn WHERE Scn = 612 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 612, 'ENG', 
   @cLine01 = 'SCANNER A',
   @cLine02 = '',
   @cLine03 = 'CASE ID:',
   @cLine04 = '%18i01*',
   @cLine05 = 'QTY: %10d02', 
   @cLine06 = 'SKU:',
   @cLine07 = '%20d03',
   @cLine08 = 'DESC:',
   @cLine09 = '%20d04', 
   @cLine10 = '%20d05', 
   @cLine11 = '',
   @cLine12 = 'TOT CASE: %10d06', 
   @cLine13 = '%e'

-- Tote
-- 620 = WorkStation
DELETE rdt.RDTScn WHERE Scn = 620 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 620, 'ENG', 
   @cLine01 = 'SCANNER A',
   @cLine02 = '',
   @cLine03 = 'WORKSTATION:',
   @cLine04 = '%15i01*', 
   @cLine05 = '',
   @cLine06 = '%e'

-- 621 = Store, case ID
DELETE rdt.RDTScn WHERE Scn = 621 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 621, 'ENG', 
   @cLine01 = 'SCANNER A',
   @cLine02 = '',
   @cLine03 = 'STOR:',
   @cLine04 = '%15i01',
   @cLine05 = '',
   @cLine06 = 'TOTE #: ',
   @cLine07 = '%10i02', 
   @cLine08 = '',
   @cLine09 = '%e'

-- 622 = Ref No 1..5
DELETE rdt.RDTScn WHERE Scn = 622 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 622, 'ENG', 
   @cLine01 = 'SCANNER A',
   @cLine02 = '',
   @cLine03 = 'REF NO1:',
   @cLine04 = '%20i01',
   @cLine05 = 'REF NO2:',
   @cLine06 = '%20i02',
   @cLine07 = 'REF NO3:', 
   @cLine08 = '%20i03',
   @cLine09 = 'REF NO4:', 
   @cLine10 = '%20i04',   
   @cLine11 = 'REF NO5:', 
   @cLine12 = '%20i05',   
   @cLine13 = '%e'
   
-- 623 = SKU (input), QTY (display), Desc, TotalQTY
DELETE rdt.RDTScn WHERE Scn = 623 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 623, 'ENG', 
   @cLine01 = 'SCANNER A',
   @cLine02 = '',
   @cLine03 = 'QTY: %05i01', 
   @cLine04 = 'SKU: ',
   @cLine05 = '%20i02',
   @cLine06 = '',
   @cLine07 = 'DESC:',
   @cLine08 = '%20d03', 
   @cLine09 = '%20d04', 
   @cLine10 = '',
   @cLine11 = 'TOT QTY: %10d05', 
   @cLine12 = '%e'

-- 624 = Option
DELETE rdt.RDTScn WHERE Scn = 624 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 624, 'ENG', 
   @cLine01 = 'SCANNER A',
   @cLine02 = '',
   @cLine03 = 'QTY reach checking',
   @cLine04 = 'level', 
   @cLine05 = '', 
   @cLine06 = 'Confirm?', 
   @cLine07 = '1 = Yes', 
   @cLine08 = '2 = No', 
   @cLine09 = '', 
   @cLine10 = 'Option %01i01', 
   @cLine11 = '', 
   @cLine12 = '%e'
   