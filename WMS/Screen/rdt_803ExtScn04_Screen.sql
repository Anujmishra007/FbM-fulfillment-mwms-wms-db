--FCR-13139 Screen 6920 (3b): SortTote Scan
DELETE rdt.RDTScn WHERE Scn = 6920 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6920, 'ENG',
    @cLine01 = 'TOTE ID IN SORTER SLOT:'
   ,@cLine02 = '%20i01'
   ,@cLine03 = 'LOC:%10d02'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1"],"2":["2"],"3":["3"]}'
   ,@nFunc = 803

--FCR-13139 Screen 6921 (3c): Confirm LOC
DELETE rdt.RDTScn WHERE Scn = 6921 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6921, 'ENG',
    @cLine01 = 'CONFIRM LOC:'
   ,@cLine02 = '%10d01'
   ,@cLine03 = '%10i02'
   ,@cLine14 = '%e'
   ,@nFunc = 803

--FCR-13139 Screen 6922 (3a): SKU Scan (simplified from Screen 4592)
DELETE rdt.RDTScn WHERE Scn = 6922 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6922, 'ENG',
    @cLine01 = '%20d01'
   ,@cLine02 = '%20d02'
   ,@cLine03 = '%20d03'
   ,@cLine04 = '%20d04'
   ,@cLine10 = 'SKU/UPC:'
   ,@cLine11 = '%60i11'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1"],"2":["2"],"3":["3"],"4":["4"],"5":["10","11"]}'
   ,@nFunc = 803

-- Drop ID, counter
DELETE rdt.RDTScn WHERE Scn = 6924 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6924, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'DROP ID: '
   ,@cLine03 = '%20i01'
   ,@cLine04 = ''
   ,@cLine05 = ''
   ,@cLine06 = '%05d02'
   ,@cLine07 = '%20d03'  --WMS-17331
   ,@cLine08 = '%20d04'  --WMS-17331
   ,@cLine09 = '%20d05'  --WMS-17331
   ,@cLine10 = '%20d06'  --WMS-17331
   ,@cLine11 = '%20d07'  --WMS-17331
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["2","3"],"2":["6"],"3":["7"],"4":["8"]}'
   ,@nFunc = 803
