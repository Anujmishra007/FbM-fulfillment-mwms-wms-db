-- Screen 1
-- Scn = 2500. BOM
DELETE rdt.RDTScn WHERE Scn = 2500 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2500, 'ENG', 
   @cLine01 = 'BOM:',
   @cLine02 = '%20i01',
   @cLine14 = '%e'

-- Screen 2
-- Scn = 2501. BOM screen
DELETE rdt.RDTScn WHERE Scn = 2501 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2501, 'ENG', 
   @cLine01 = 'BOM:',
   @cLine02 = '%20d01',
   @cLine03 = 'STYLE',
   @cLine04 = '%20d02',
   @cLine05 = 'COLOUR:',
   @cLine06 = '%10d03',
   @cLine07 = '# Component',
   @cLine08 = '%05d04',
   @cLine09 = 'CS   IN',
   @cLine10 = '%11d05',
   @cLine13 = 'ENTER = Details',
   @cLine14 = '%e'

-- Screen 3   
-- Scn = 2502. Component SKU
DELETE rdt.RDTScn WHERE Scn = 2502 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2502, 'ENG', 
   @cLine01 = 'BOM:      %05d01',
   @cLine02 = '%20d02',
   @cLine03 = 'STYLE',
   @cLine04 = '%20d03',
   @cLine05 = 'COLOUR:',
   @cLine06 = '%10d04',
   @cLine07 = 'SIZE/MEAS',
   @cLine08 = '%11d05',
   @cLine09 = 'SKU',
   @cLine10 = '%20d06',
   @cLine11 = 'QTY    %05d07',
   @cLine13 = 'ENTER = NEXT',
   @cLine14 = '%e'
   
   