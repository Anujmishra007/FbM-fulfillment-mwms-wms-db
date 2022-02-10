--5790 - 5799
-- 5790 = WaveKey
DELETE rdt.RDTScn WHERE Scn = 5790 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5790, 'ENG'
   ,@cLine01 = 'WAVEPK:'
   ,@cLine02 = '%20i01'
   ,@cLine03 = ''
   ,@cLine04 = 'TOTE ID'
   ,@cLine05 = '%15i02'
   ,@cLine14 = '%e'
   ,@nFunc = 1844

-- 5791 = WavePk
DELETE rdt.RDTScn WHERE Scn = 5791 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5791, 'ENG'
   ,@cLine01 = 'WAVEPK:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = ''
   ,@cLine04 = 'ASSIGNED TOTE ID:'
   ,@cLine05 = '%20d02'
   ,@cLine06 = '%20d03'
   ,@cLine07 = '%20d04'
   ,@cLine08 = '%20d05'
   ,@cLine09 = '%20d06'
   ,@cLine10 = '%20d07'
   ,@cLine13 = '%20d08' --ENTER TO NEXT PAGE
   ,@cLine14 = '%e'
   ,@nFunc = 1844

-- 5792 = ToteID
DELETE rdt.RDTScn WHERE Scn = 5792 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5792, 'ENG'
   ,@cLine01 = 'TOTE ID:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = 'WAVEPK:'
   ,@cLine04 = '%20d02'
   ,@cLine05 = 'SKU/QTY/ALTSKU:'
   ,@cLine06 = '%20d03'
   ,@cLine07 = '%20d04'
   ,@cLine08 = '%20d05'
   ,@cLine09 = '%20d06'
   ,@cLine10 = '%20d07'
   ,@cLine11 = '%20d08'
   ,@cLine13 = '%20d09' --ENTER TO NEXT PAGE
   ,@cLine14 = '%e'
   ,@nFunc = 1844