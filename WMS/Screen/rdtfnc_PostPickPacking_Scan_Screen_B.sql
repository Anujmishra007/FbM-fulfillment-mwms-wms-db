/*
   Post pick audit scan
*/

-- Pallet
-- 615 = WorkStation, Batch
DELETE rdt.RDTScn WHERE Scn = 615 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 615, 'ENG', 
   @cLine01 = 'SCANNER B',
   @cLine02 = '',
   @cLine03 = 'WORKSTATION:',
   @cLine04 = '%15i01*', 
   @cLine05 = '',
   @cLine06 = 'BATCH:',
   @cLine07 = '%15i02',
   @cLine14 = '%e'

-- 616 = Batch, Store, Pallet ID
DELETE rdt.RDTScn WHERE Scn = 616 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 616, 'ENG', 
   @cLine01 = 'SCANNER B',
   @cLine02 = 'BATCH:',
   @cLine03 = '%15d01',
   @cLine04 = '',
   @cLine05 = 'STOR:',
   @cLine06 = '%15i02',
   @cLine07 = '',
   @cLine08 = 'PALLET ID: ',
   @cLine09 = '%18i03',
   @cLine14 = '%e'

-- 617 = Batch, Case ID, QTY, SKU, Desc, TotalQTY
DELETE rdt.RDTScn WHERE Scn = 617 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 617, 'ENG', 
   @cLine01 = 'SCANNER B',
   @cLine02 = 'BATCH:',
   @cLine03 = '%15d01',
   @cLine04 = '',
   @cLine05 = 'CASE ID:',
   @cLine06 = '%18i02*',
   @cLine07 = 'QTY: %10d03', 
   @cLine08 = 'SKU:',
   @cLine09 = '%20d04',
   @cLine10 = 'DESC:',
   @cLine11 = '%20d05',
   @cLine12 = '%20d06',
   @cLine13 = 'TOT CASE: %10d07',
   @cLine14 = '%e'

-- Tote
-- 625 = WorkStation, Batch
DELETE rdt.RDTScn WHERE Scn = 625 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 625, 'ENG', 
   @cLine01 = 'SCANNER B',
   @cLine02 = '',
   @cLine03 = 'WORKSTATION:',
   @cLine04 = '%15i01*', 
   @cLine05 = '',
   @cLine06 = 'BATCH:',
   @cLine07 = '%15i02',
   @cLine14 = '%e'

-- 626 = Batch, Stor, case ID
DELETE rdt.RDTScn WHERE Scn = 626 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 626, 'ENG', 
   @cLine01 = 'SCANNER B',
   @cLine02 = 'BATCH:',
   @cLine03 = '%15d01',   
   @cLine04 = '',
   @cLine05 = 'STOR:',
   @cLine06 = '%15i02',
   @cLine07 = '',
   @cLine08 = 'TOTE #: ',
   @cLine09 = '%10i03', 
   @cLine10 = '',
   @cLine14 = '%e'

-- 627 = Ref No 1..5
DELETE rdt.RDTScn WHERE Scn = 627 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 627, 'ENG', 
   @cLine01 = 'SCANNER B',
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
   @cLine14 = '%e'

-- 628 = Batch, SKU (input), QTY (display), Desc, TotalQTY
DELETE rdt.RDTScn WHERE Scn = 628 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 628, 'ENG', 
   @cLine01 = 'SCANNER B',
   @cLine02 = 'BATCH:',
   @cLine03 = '%15d01',
   @cLine04 = 'QTY: %05i02', 
   @cLine05 = 'SKU: ',
   @cLine06 = '%20i03',
   @cLine07 = '',
   @cLine08 = 'DESC:',
   @cLine09 = '%20d04', 
   @cLine10 = '%20d05', 
   @cLine11 = '',
   @cLine12 = 'TOT QTY: %10d06',
   @cLine14 = '%e' 

-- 629 = Option
DELETE rdt.RDTScn WHERE Scn = 629 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 629, 'ENG', 
   @cLine01 = 'SCANNER B',
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
   @cLine14 = '%e'