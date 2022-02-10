-- 2060  = Scan-in the MUID screen
DELETE rdt.RDTScn WHERE Scn = 2060 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2060, 'ENG',
    @cLine01 = 'MUID:'
   ,@cLine02 = '%100iV_MAX' -- SOS372493/WMS4127
   ,@cLine13 = 'ENTER = Next Page'
   ,@cLine14 = '%e'
   ,@nFunc   = 864

-- 2061 = Scan-in the STOR screen
DELETE rdt.RDTScn WHERE Scn = 2061 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2061, 'ENG',
    @cLine01 = 'MUID:' 
   ,@cLine02 = '%18d01'
   ,@cLine03 = 'LOC:  %10d02'
   ,@cLine04 = 'STOR: %15d03'
   ,@cLine05 = 'STOR: %40i04' -- SOS372493
   ,@cLine13 = 'ENTER = Next Page'
   ,@cLine14 = '%e'
   ,@nFunc   = 864

-- 2062 = Key-in the ACT QTY picked in its corresponding UOM column screen
DELETE rdt.RDTScn WHERE Scn = 2062 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2062, 'ENG',
    @cLine01 = 'STOR: %15d01' 
   ,@cLine02 = 'SKU:'
   ,@cLine03 = '%20d02'
   ,@cLine04 = '%20d03'
   ,@cLine05 = '%20d04'
   ,@cLine06 = '1 %18d05'
   ,@cLine07 = '2 %18d06'
   ,@cLine08 = '3 %18d07'
   ,@cLine09 = '4 %16d08'
   ,@cLine10 = '1:%05d09  %05d10 %05d11'
   ,@cLine11 = 'BAL QTY: %05d12 %05d13'
   ,@cLine12 = 'ACT QTY: %05i14 %05i15'
   ,@cLine13 = 'ENTER = Next Page'
   ,@cLine14 = '%e'
   ,@nFunc   = 864

-- 2063 = Scan-in the Drop ID screen
DELETE rdt.RDTScn WHERE Scn = 2063 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2063, 'ENG',
    @cLine01 = 'STOR: %15d01' 
   ,@cLine02 = 'SKU:'
   ,@cLine03 = '%20d02'
   ,@cLine04 = '%20d03'
   ,@cLine05 = '%20d04'
   ,@cLine06 = ''
   ,@cLine07 = '1:%05d05  %05d06 %05d07'
   ,@cLine08 = 'BAL QTY: %05d08 %05d09'
   ,@cLine09 = 'ACT QTY: %05d10 %05d11'
   ,@cLine10 = 'DROPID:'
   ,@cLine11 = '%40i12' -- SOS372493
   ,@cLine13 = 'ENTER = Next Page'
   ,@cLine14 = '%e'
   ,@nFunc   = 864

-- 2064 = Enter Option screen
DELETE rdt.RDTScn WHERE Scn = 2064 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2064, 'ENG',
    @cLine01 = 'FINISH DISTRIBUTE?' 
   ,@cLine02 = ''
   ,@cLine03 = 'BAL QTY: %05d01'
   ,@cLine04 = 'ACT QTY: %05d02'
   ,@cLine05 = ''
   ,@cLine06 = '1=YES'
   ,@cLine07 = '2=NO'
   ,@cLine08 = ''
   ,@cLine09 = 'OPTION: %01i03'
   ,@cLine14 = '%e'
   ,@nFunc   = 864

-- 2065 = Key-in the SKU & ACT QTY picked in its corresponding UOM column screen
DELETE rdt.RDTScn WHERE Scn = 2065 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2065, 'ENG',
    @cLine01 = 'STOR: %15d01' 
   ,@cLine02 = 'SKU/UPC:'
   ,@cLine03 = '%40i02'
   ,@cLine14 = '%e'
   ,@nFunc   = 864