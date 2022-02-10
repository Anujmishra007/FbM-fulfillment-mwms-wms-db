-- 3430 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 3430 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3430, 'ENG'
   ,@cLine01 = 'MBOLKEY:  %10i01'
   ,@cLine02 = ''
   ,@cLine03 = 'LOADKEY:  %10i02'
   ,@cLine04 = ''
   ,@cLine05 = 'ORDERKEY: %10i03'
   ,@cLine06 = ''
   ,@cLine07 = 'REF NO:'      -- WMS-15718
   ,@cLine08 = '%20i04'       -- WMS-15718
   ,@cLine14 = '%e'
   ,@nFunc = 922

-- 3431 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 3431 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3431, 'ENG'
   ,@cLine01 = 'MBOLKEY:  %10d01'
   ,@cLine02 = 'LOADKEY:  %10d02'
   ,@cLine03 = 'ORDERKEY: %10d03'
   ,@cLine04 = 'REF NO:'      -- WMS-15718
   ,@cLine05 = '%20d08'       -- WMS-15718
   ,@cLine06 = 'LABELNO/DROPID:'
   ,@cLine07 = '%20i04'
   ,@cLine08 = '%20d05'
   ,@cLine09 = ''
   ,@cLine10 = 'SCANNED: %10d06'
   ,@cLine11 = 'TOTAL:   %10d07'
   ,@cLine14 = '%e'
   ,@nFunc = 922

-- 3432 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 3432 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3432, 'ENG'
   ,@cLine01 = 'LABELNO/DROPID:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = ''
   ,@cLine04 = 'WEIGHT: %10i02'
   ,@cLine05 = ''
   ,@cLine06 = 'CUBE:   %10i03'
   ,@cLine07 = ''
   ,@cLine08 = 'CARTON: %10i04'
   ,@cLine14 = '%e'
   ,@nFunc = 922

-- 3433 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 3433 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3433, 'ENG'
   ,@cLine01 = 'REFNO1: %10i01'
   ,@cLine02 = ''
   ,@cLine03 = 'REFNO2:'
   ,@cLine04 = '%40i02'
   ,@cLine14 = '%e'
   ,@nFunc = 922