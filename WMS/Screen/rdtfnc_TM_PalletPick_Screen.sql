if not exists(select 1 from rdt.RDTMsg where Message_ID = 1770 and Message_Type = 'FNC' and Lang_Code = 'ENG')
   insert into rdt.RDTMsg(Message_ID,Lang_Code,Message_Type,Message_Text,StoredProcName,EventType)
   values(1770,'ENG','FNC','Reserve for TM','rdtfnc_TM_PalletPick',0)
IF EXISTS(select 1 from rdt.RDTMsg where Message_ID = 1770 and Message_Type = 'FNC' and Lang_Code = 'ENG' AND StoredProcName = '')
   UPDATE rdt.RDTMsg SET StoredProcName = 'rdtfnc_TM_PalletPick' where Message_ID = 1770 and Message_Type = 'FNC' and Lang_Code = 'ENG'
GO

--Screen Range 3700 - 3709

DELETE rdt.RDTScn WHERE Scn = 3700 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3700, 'ENG',
    @cLine01 = 'PICK PALLET      FPK'
   ,@cLine02 = ''
   ,@cLine03 = 'FROM LOC:'
   ,@cLine04 = '%10d01'
   ,@cLine05 = '%10i02'
   ,@cLine06 = ''
   ,@cLine07 = '%20d10'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["3","4","5"],"2":["7"]}'
   ,@nFunc = 1770

DELETE rdt.RDTScn WHERE Scn = 3701 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3701, 'ENG',
    @cLine01 = 'FROM ID:'
   ,@cLine02 = '%18d01'
   ,@cLine03 = '%18i02'
   ,@cLine04 = 'SKU:'
   ,@cLine05 = '%20d03'
   ,@cLine06 = '%20d04'
   ,@cLine07 = '%20d05'
   ,@cLine08 = '1 %18d06'
   ,@cLine09 = '2 %18d07'
   ,@cLine10 = '3 %18d08'
   ,@cLine11 = '4 %10d09'
   ,@cLine12 = '%20d10'
   ,@cLine13 = 'PK  QTY: %05d11 %05d12'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2","3"],"2":["4","5","6","7"],"3":["8","9","10","11"],"4":["12"],"5":["13"]}'
   ,@nFunc = 1770

DELETE rdt.RDTScn WHERE Scn = 3702 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3702, 'ENG',
    @cLine01 = 'SKU:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = '%20d02'
   ,@cLine04 = '%20d03'
   ,@cLine05 = '1 %18d04'
   ,@cLine06 = '2 %18d05'
   ,@cLine07 = '3 %18d06'
   ,@cLine08 = '4 %10d07'
   ,@cLine09 = '%20d10'
   ,@cLine10 = '%32i08'
   ,@cLine11 = '%20d11'
   ,@cLine12 = 'PK  QTY: %05d12 %05d13'
   ,@cLine13 = 'ACT QTY: %05i14^DT:INT %05i15^DT:INT'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2","3","4"],"2":["5","6","7","8"],"3":["9","10"],"4":["11","12","13"]}'
   ,@nFunc = 1770

DELETE rdt.RDTScn WHERE Scn = 3703 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3703, 'ENG',
    @cLine01 = 'PICK PALLET      FPK'
   ,@cLine02 = ''
   ,@cLine03 = 'FROM LOC:'
   ,@cLine04 = '%10d01'
   ,@cLine05 = ''
   ,@cLine06 = 'TO LOC:'
   ,@cLine07 = '%10d02'
   ,@cLine08 = '%10i03'
   ,@cLine09 = ''
   ,@cLine10 = 'DROPID:'
   ,@cLine11 = '%20i04'
   ,@cLine12 = ''
   ,@cLine13 = '%20d10'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["3","4"],"2":["6","7","8"],"3":["10","11"],"4":["13"]}'
   ,@nFunc = 1770

DELETE rdt.RDTScn WHERE Scn = 3704 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3704, 'ENG',
    @cLine01 = 'PICK PALLET      FPK'
   ,@cLine02 = ''
   ,@cLine03 = 'Pallet is closed and'
   ,@cLine04 = 'picked'
   ,@cLine05 = ''
   ,@cLine06 = 'ENTER = Next Task'
   ,@cLine07 = 'ESC   = Exit to TM'
   ,@cLine08 = ''
   ,@cLine09 = ''
   ,@cLine10 = 'LAST LOC: %10d01'
   ,@cLine11 = ''
   ,@cLine12 = '%20d10'
   ,@cLine14 = '%e'
   ,@nFunc = 1770

