
IF NOT EXISTS( SELECT 1 FROM rdt.rdtmsg WITH (NOLOCK) WHERE Message_ID = 1878 AND Message_Type = 'FNC' AND Lang_Code = 'ENG')
   INSERT INTO rdt.rdtMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, EventType) 
   VALUES (1878, 'ENG', 'FNC', 'Pallet Consolidate BESE', 'rdtfnc_PalletConsolidate_BESE', 0)
GO

-- Fn1878 = 6850 screen
DELETE rdt.RDTScn WHERE Scn = 6850 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6850, 'ENG',
    @cLine01 = 'TO PALLET ID: '
   ,@cLine02 = '%20i01'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"]}'
   ,@nFunc = 1878

-- Fn1878 = 6851 screen
DELETE rdt.RDTScn WHERE Scn = 6851 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6851, 'ENG',
    @cLine01 = 'TO PALLET Not Found.'
   ,@cLine02 = 'Create New?'
   ,@cLine04 = '1 = YES  2 = NO'
   ,@cLine06 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1"]}'
   ,@nFunc = 1878

-- Fn1878 = 6852 screen
DELETE rdt.RDTScn WHERE Scn = 6852 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6852, 'ENG',
    @cLine01 = 'TO PALLET ID: '
   ,@cLine02 = '%20d01'
   ,@cLine03 = 'FROM PALLET ID'
   ,@cLine04 = '%20i02' 
   ,@cLine06 = 'SCANNED: %05d03'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2"],"2":["3","4"]}'
   ,@nFunc = 1878

-- Fn1878 = 6853 screen
DELETE rdt.RDTScn WHERE Scn = 6853 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6853, 'ENG',
    @cLine01 = 'PALLET ID(s) MOVED '
   ,@cLine02 = 'SUCCESSFULLY'
   ,@cLine04 = 'Press ENTER or ESC '
   ,@cLine05 = 'to continue '
   ,@cLine14 = '%e'
   ,@cAutoDisappear = '1'
   ,@nFunc = 1878

-- Fn1878 = 6854 screen
DELETE rdt.RDTScn WHERE Scn = 6854 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6854, 'ENG',
    @cLine01 = 'Print pallet label'
   ,@cLine02 = ''
   ,@cLine03 = '1 = YES  2 = NO'
   ,@cLine04 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1"],"2":["3","4"]}'
   ,@nFunc = 6854
