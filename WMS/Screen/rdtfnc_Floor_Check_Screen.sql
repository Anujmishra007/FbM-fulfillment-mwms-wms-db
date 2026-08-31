--rdtfnc_ScanToTruck_Barry
-- 6580 - 6586

IF NOT EXISTS (SELECT 1 FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID = '927')
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES ('927', 'ENG', 'FNC', 'Floor Check', 'rdtfnc_Floor_Check', '0')

-- Screen 1
-- Scn = 6580 
DELETE rdt.RDTScn WHERE Scn = 6580 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6580, 'ENG'
   ,@cLine01 = 'FromLOC:'
   ,@cLine02 = '%10i01'
   ,@cLine14 = '%e'
   ,@nFunc = 927

-- Screen 2
-- Scn = 6581
DELETE rdt.RDTScn WHERE Scn = 6581 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6581, 'ENG'
   ,@cLine01 = 'From LOC:'
   ,@cLine02 = '%10d01'
   ,@cLine04 = 'From ID:'
   ,@cLine05 = '%10i02'
   ,@cLine14 = '%e'
   ,@nFunc = 927

-- Screen 3
-- Scn = 6582. CARTON ID
DELETE rdt.RDTScn WHERE Scn = 6582 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6582, 'ENG'
   ,@cLine01 = 'FROM LOC: %10d01'
   ,@cLine02 = 'FROM ID:'
   ,@cLine03 = '%20d02'
   ,@cLine04 = 'CARTON ID:'
   ,@cLine05 = '%20i03'
   ,@cLine14 = '%e'
   ,@nFunc = 927

-- Screen 4
-- Scn = 6583. UCC List
DELETE rdt.RDTScn WHERE Scn = 6583 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6583, 'ENG'
   ,@cLine01 = 'FROM LOC: %10d01'
   ,@cLine02 = 'FROM ID:'
   ,@cLine03 = '%20d02'
   ,@cLine04 = 'CARTON ID: %20d03'
   ,@cLine05 = 'UCC:'
   ,@cLine06 = '%20d04'
   ,@cLine07 = '%20d05'
   ,@cLine08 = '%20d06'
   ,@cLine09 = '%20d07'
   ,@cLine10 = '%20d08'
   ,@cLine11 = '%5d09'
   ,@cLine14 = '%e'
   ,@nFunc = 927

-- Screen 5
-- Scn = 6584. Msg (pallet-level result)
DELETE rdt.RDTScn WHERE Scn = 6584 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6584, 'ENG'
   ,@cLine01 = 'FROM LOC: %10d01'
   ,@cLine02 = 'FROM ID:'
   ,@cLine03 = '%20d02'
   ,@cLine04 = ''
   ,@cLine05 = '%20d03'
   ,@cLine06 = ''
   ,@cLine07 = 'ENT: next ID'
   ,@cLine08 = 'ESC: next LOC'
   ,@cLine14 = '%e'
   ,@nFunc = 927

-- Screen 6
-- Scn = 6585. Carton Msg (carton-level result)
DELETE rdt.RDTScn WHERE Scn = 6585 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6585, 'ENG'
   ,@cLine01 = 'FROM LOC: %10d01'
   ,@cLine02 = 'FROM ID:'
   ,@cLine03 = '%20d02'
   ,@cLine04 = 'CARTON ID:'
   ,@cLine05 = '%20d03'
   ,@cLine06 = '%20d04'
   ,@cLine07 = '%20d05'
   ,@cLine08 = 'ENT: next CTN/ID'
   ,@cLine09 = 'ESC: next LOC'
   ,@cLine14 = '%e'
   ,@nFunc = 927
