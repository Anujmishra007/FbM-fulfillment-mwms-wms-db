
-- Station, method
DELETE rdt.RDTScn WHERE Scn = 4590 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4590, 'ENG'
   ,@cLine01 = 'STATION:  %10i01'
   ,@cLine02 = ''
   ,@cLine03 = 'METHOD:   %01i02'
   ,@cLine14 = '%e'
   ,@nFunc = 803

-- Dynamic assign screens (4500 to 4509)

-- Matrix, SKU screen
DELETE rdt.RDTScn WHERE Scn = 4592 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4592, 'ENG'
   ,@cLine01 = '%20d01' -- Result01
   ,@cLine02 = '%20d02' 
   ,@cLine03 = '%20d03'
   ,@cLine04 = '%20d04'
   ,@cLine05 = '%20d05'
   ,@cLine06 = '%20d06'
   ,@cLine07 = '%20d07'
   ,@cLine08 = 'SKU/UPC:'
   ,@cLine09 = '%30i11'
   ,@cLine10= 'LAST POS: %05d12'
   ,@cLine11= 'Option: %05i13'
   ,@cLine12= '9=CLOSE'
   ,@cLine14 = '%e'
   ,@nFunc = 803
   
-- Unassign station
DELETE rdt.RDTScn WHERE Scn = 4593 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4593, 'ENG'
   ,@cLine01 = 'UNASSIGN STATION?'
   ,@cLine02 = ''
   ,@cLine03 = '1 = YES' 
   ,@cLine04 = '9 = NO' 
   ,@cLine05 = '' 
   ,@cLine06 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 803
   
   
-- Close Carton
DELETE rdt.RDTScn WHERE Scn = 4594 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4594, 'ENG'
   ,@cLine01 = 'LOC:'
   ,@cLine02 = '%20i01'
   ,@cLine04 = 'Carton ID'
   ,@cLine05 = '%20i02'
   ,@cLine14 = '%e'
   ,@nFunc = 803
   