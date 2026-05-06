DELETE RDT.RDTMsg WHERE Message_ID = 1812 AND Lang_Code = 'ENG' AND Message_Type = 'FNC'
INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES (1812, 'ENG', 'FNC', 'TM Case Pick', 'rdtfnc_TM_CasePick', '4')


-- Drop ID
DELETE rdt.RDTScn WHERE Scn = 4020 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4020, 'ENG',
    @cLine01 = 'PICK CASE        FCP'
   ,@cLine02 = 'PLEASE TAKE AN EMPTY'
   ,@cLine03 = 'PALLET'
   ,@cLine04 = ''
   ,@cLine05 = 'DROPID:'
   ,@cLine06 = '%20i01'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["5","6"]}'
   ,@nFunc = 1812

-- From LOC
DELETE rdt.RDTScn WHERE Scn = 4021 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4021, 'ENG',
    @cLine01 = 'PICK CASE        FCP'
   ,@cLine02 = 'PICKTYPE: %10d01'
   ,@cLine03 = ''
   ,@cLine04 = 'DROPID:'
   ,@cLine05 = '%20d02'
   ,@cLine06 = ''
   ,@cLine07 = 'FROM LOC:'
   ,@cLine08 = '%10d03'
   ,@cLine09 = '%20i04' --FCR-3959 Extend length to 20 to adapt with loc digit check
   ,@cLine10 = ''
   ,@cLine11 = ''
   ,@cLine12 = ''
   ,@cLine13 = '%20d10'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["4","5"],"2":["7","8"],"3":["9"],"4":["13"]}'
   ,@nFunc = 1812

-- From ID
DELETE rdt.RDTScn WHERE Scn = 4022 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4022, 'ENG',
    @cLine01 = 'PICK CASE        FCP'
   ,@cLine02 = 'PICKTYPE: %10d01'
   ,@cLine03 = ''
   ,@cLine04 = 'DROPID:'
   ,@cLine05 = '%20d02'
   ,@cLine06 = ''
   ,@cLine07 = 'FROM LOC:'
   ,@cLine08 = '%10d03'
   ,@cLine09 = ''
   ,@cLine10 = 'FROM ID:'
   ,@cLine11 = '%18d04'
   ,@cLine12 = '%18i05'
   ,@cLine13 = '%20d10'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["4","5"],"1":["7","8"],"3":["10","11","12"],"4":["13]"}'
   ,@nFunc = 1812

-- SKU
DELETE rdt.RDTScn WHERE Scn = 4023 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4023, 'ENG',
    @cLine01 = 'SKU:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = '%20d02'
   ,@cLine04 = '%20d03'
   ,@cLine05 = '%20d04'
   ,@cLine06 = '%20d05'
   ,@cLine07 = '%20d06'
   ,@cLine08 = '%20d07'
   ,@cLine09 = '%20d10'
   ,@cLine10 = '%200iV_Barcode'
   ,@cLine11 = '%20d11'
   ,@cLine12 = 'PK  QTY: %05d12 %05d13'
   ,@cLine13 = 'ACT QTY: %05i14^DT:INT %05i15^DT:INT'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["1","2","3","4"],"1":["5","6","7","8"],"3":["9","10"],"4":["11","12","13]"}'
   ,@nFunc = 1812

-- Close pallet
DELETE rdt.RDTScn WHERE Scn = 4024 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4024, 'ENG',
    @cLine01 = 'PICK CASE        FCP'
   ,@cLine02 = ''
   ,@cLine03 = '1 = CONT NEXT TASK'
   ,@cLine04 = '9 = CLOSE PALLET'
   ,@cLine05 = ''
   ,@cLine06 = ''
   ,@cLine07 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1812

-- To LOC
DELETE rdt.RDTScn WHERE Scn = 4025 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4025, 'ENG',
    @cLine01 = 'PICK CASE        FCP'
   ,@cLine02 = ''
   ,@cLine03 = 'FROM LOC:'
   ,@cLine04 = '%10d01'
   ,@cLine05 = ''
   ,@cLine06 = 'TO LOC:'
   ,@cLine07 = '%10d02'
   ,@cLine08 = '%20i03' --FCR-3959 Extend length to 20 to adapt with loc digit check
   ,@cLine09 = ''
   ,@cLine10 = '%20d10'
   ,@cLine14 = '%e'
   ,@cWebGroup = '{"1":["3","4"],"1":["6","7","8"],"3":["10"]"}'
   ,@nFunc = 1812

-- Exit TM
DELETE rdt.RDTScn WHERE Scn = 4026 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4026, 'ENG',
    @cLine01 = 'PICK CASE        FCP'
   ,@cLine02 = ''
   ,@cLine03 = 'Pallet is closed and'
   ,@cLine04 = 'moved'
   ,@cLine05 = ''
   ,@cLine06 = 'ENTER = Next Task'
   ,@cLine07 = 'ESC   = Exit to TM'
   ,@cLine08 = ''
   ,@cLine09 = ''
   ,@cLine10 = 'LAST LOC: %10d01'
   ,@cLine11 = ''
   ,@cLine12 = '%20d10'
   ,@cLine14 = '%e'
   ,@nFunc = 1812

-- Short pick
DELETE rdt.RDTScn WHERE Scn = 4027 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4027, 'ENG',
    @cLine01 = 'PICK CASE        FCP'
   ,@cLine02 = ''
   ,@cLine03 = '1 = SHORT PICK'
   ,@cLine04 = '9 = CLOSE PALLET'
   ,@cLine05 = ''
   ,@cLine06 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1812

-- Is the location completely empty?
DELETE rdt.RDTScn WHERE Scn = 4028 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4028, 'ENG',
    @cLine01 = 'PICK CASE        FCP'
   ,@cLine02 = ''
   ,@cLine03 = 'Is the location'
   ,@cLine04 = 'completely empty?'
   ,@cLine05 = ''
   ,@cLine06 = '1 = YES'
   ,@cLine07 = '9 = NO'
   ,@cLine08 = ''
   ,@cLine09 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1812

-- 6620  = Reason Code screen
DELETE rdt.RDTScn WHERE Scn = 6620 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6620, 'ENG',
   @cLine02 = 'REASON CODE: '
   ,@cLine03 = '%10i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1812