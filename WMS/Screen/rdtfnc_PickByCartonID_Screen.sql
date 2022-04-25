IF NOT EXISTS( SELECT 1 FROM rdt.rdtMsg WITH (NOLOCK) WHERE Message_ID = 831)
   INSERT INTO rdt.rdtMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName)
   VALUES (831, 'ENG', 'FNC', 'Pick By CartonID', 'rdtfnc_PickByCartonID')
GO

-- WaveKey screen
DELETE rdt.RDTScn WHERE Scn = 5350 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5350, 'ENG'
   ,@cLine01 = 'WAVEKEY:  %10i01'
   ,@cLine14 = '%e'
   ,@nFunc = 831

-- Putawayzone screen
DELETE rdt.RDTScn WHERE Scn = 5351 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5351, 'ENG'
   ,@cLine01 = 'WAVEKEY:  %10d01'
   ,@cLine02 = 'PWAYZONE: %10i02'
   ,@cLine14 = '%e'
   ,@nFunc = 831

-- Carton ID screen
DELETE rdt.RDTScn WHERE Scn = 5352 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5352, 'ENG'
   ,@cLine01 = 'CARTON ID (1..9):'
   ,@cLine02 = '%20i01'
   ,@cLine03 = '%20i02'
   ,@cLine04 = '%20i03'
   ,@cLine05 = '%20i04'
   ,@cLine06 = '%20i05'
   ,@cLine07 = '%20i06'
   ,@cLine08 = '%20i07'
   ,@cLine09 = '%20i08'
   ,@cLine10 = '%20i09'
   ,@cLine14 = '%e'
   ,@nFunc = 831
 
-- LOC screen
DELETE rdt.RDTScn WHERE Scn = 5353 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5353, 'ENG'
   ,@cLine01 = 'LOC: %10d01'
   ,@cLine02 = 'LOC: %10i02'
   ,@cLine14 = '%e'
   ,@nFunc = 831

-- SKU, QTY screen
DELETE rdt.RDTScn WHERE Scn = 5354 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5354, 'ENG'
   ,@cLine01 = 'ID%18d01'
   ,@cLine02 = 'SKU:          POS:%02d13'
   ,@cLine03 = '%20d02'
   ,@cLine04 = '%20d03'
   ,@cLine05 = '%20d04'
   ,@cLine06 = '1 %18d05'
   ,@cLine07 = '2 %18d06'
   ,@cLine08 = '3 %18d07'
   ,@cLine09 = '4 %10d08'
   ,@cLine10 = 'PICK:%05d09 ACT:%05d10'
   ,@cLine11 = 'SKU/UPC:'
   ,@cLine12 = '%20i11'
   ,@cLine13 = 'TASK QTY: %11d12'
   ,@cLine14 = '%e'
   ,@nFunc = 831

-- Carton ID screen
DELETE rdt.RDTScn WHERE Scn = 5355 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5355, 'ENG'
   ,@cLine01 = 'POSITION: %01d01'
   ,@cLine03 = 'CARTON ID:'
   ,@cLine04 = '%20d02'
   ,@cLine05 = '%20i03'
   ,@cLine06 = ''
   ,@cLine07 = ''
   ,@cLine08 = '%20d15'
   ,@cLine14 = '%e'
   ,@nFunc = 831

-- Confirm short pick screen
DELETE rdt.RDTScn WHERE Scn = 5356 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5356, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'CONFIRM SHORT PICK?'
   ,@cLine03 = ''
   ,@cLine04 = '1 = YES'
   ,@cLine05 = '2 = NO'
   ,@cLine06 = ''
   ,@cLine07 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 831

