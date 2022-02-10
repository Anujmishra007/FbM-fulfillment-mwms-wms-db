--Screen Range 4020 - 4029

DELETE rdt.RDTScn WHERE Scn = 4020 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4020, 'ENG',
    @cLine01 = 'PICK CASE        FCP'
   ,@cLine02 = 'PLEASE TAKE AN EMPTY'
   ,@cLine03 = 'PALLET'
   ,@cLine04 = ''
   ,@cLine05 = 'DROPID:'
   ,@cLine06 = '%20i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1812

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
   ,@cLine09 = '%10i04'
   ,@cLine10 = ''
   ,@cLine11 = ''
   ,@cLine12 = ''
   ,@cLine13 = '%20d10'
   ,@cLine14 = '%e'
   ,@nFunc = 1812

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
   ,@nFunc = 1812

DELETE rdt.RDTScn WHERE Scn = 4023 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4023, 'ENG',
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
   ,@cLine13 = 'ACT QTY: %05i14 %05i15'
   ,@cLine14 = '%e'
   ,@nFunc = 1812

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

DELETE rdt.RDTScn WHERE Scn = 4025 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4025, 'ENG',
    @cLine01 = 'PICK CASE        FCP'
   ,@cLine02 = ''
   ,@cLine03 = 'FROM LOC:'
   ,@cLine04 = '%10d01'
   ,@cLine05 = ''
   ,@cLine06 = 'TO LOC:'
   ,@cLine07 = '%10d02'
   ,@cLine08 = '%10i03'
   ,@cLine09 = ''
   ,@cLine10 = '%20d10'
   ,@cLine14 = '%e'
   ,@nFunc = 1812

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

