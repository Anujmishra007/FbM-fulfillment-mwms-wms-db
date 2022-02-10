--Screen Range 3830 - 3839

DELETE rdt.RDTScn WHERE Scn = 3830 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3830, 'ENG',
    @cLine01 = 'MOVE FROM        MVF'
   ,@cLine02 = 'PLEASE TAKE AN EMPTY'
   ,@cLine03 = 'PALLET'
   ,@cLine04 = ''
   ,@cLine05 = 'DROPID:'
   ,@cLine06 = '%20i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1748

DELETE rdt.RDTScn WHERE Scn = 3831 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3831, 'ENG',
    @cLine01 = 'MOVE FROM        MVF'
   ,@cLine02 = 'PICKTYPE: %10d01'
   ,@cLine03 = ''
   ,@cLine04 = 'DROPID:'
   ,@cLine05 = '%20d02'
   ,@cLine06 = ''
   ,@cLine07 = 'FROM LOC:'
   ,@cLine08 = '%10d03'
   ,@cLine09 = '%10i04'
   ,@cLine14 = '%e'
   ,@nFunc = 1748

DELETE rdt.RDTScn WHERE Scn = 3832 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3832, 'ENG',
    @cLine01 = 'MOVE FROM        MVF'
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
   ,@cLine14 = '%e'
   ,@nFunc = 1748

DELETE rdt.RDTScn WHERE Scn = 3833 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3833, 'ENG',
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
   ,@cLine12 = 'MV  QTY: %05d12 %05d13'
   ,@cLine13 = 'ACT QTY: %05i14 %05i15'
   ,@cLine14 = '%e'
   ,@nFunc = 1748

DELETE rdt.RDTScn WHERE Scn = 3834 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3834, 'ENG',
    @cLine01 = 'MOVE FROM        MVF'
   ,@cLine02 = ''
   ,@cLine03 = '1 = CONT NEXT TASK'
   ,@cLine04 = '9 = CLOSE PALLET'
   ,@cLine05 = ''
   ,@cLine06 = ''
   ,@cLine07 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1748

DELETE rdt.RDTScn WHERE Scn = 3835 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3835, 'ENG',
    @cLine01 = 'MOVE FROM        MVF'
   ,@cLine02 = ''
   ,@cLine03 = 'FROM LOC:'
   ,@cLine04 = '%10d01'
   ,@cLine05 = ''
   ,@cLine06 = 'TO LOC:'
   ,@cLine07 = '%10d02'
   ,@cLine08 = '%10i03'
   ,@cLine14 = '%e'
   ,@nFunc = 1748

DELETE rdt.RDTScn WHERE Scn = 3836 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3836, 'ENG',
    @cLine01 = 'MOVE FROM        MVF'
   ,@cLine02 = ''
   ,@cLine03 = 'Pallet is closed and'
   ,@cLine04 = 'moved'
   ,@cLine05 = ''
   ,@cLine06 = 'ENTER = Next Task'
   ,@cLine07 = 'ESC   = Exit to TM'
   ,@cLine08 = ''
   ,@cLine09 = ''
   ,@cLine10 = 'LAST LOC: %10d01'
   ,@cLine14 = '%e'
   ,@nFunc = 1748

DELETE rdt.RDTScn WHERE Scn = 3837 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3837, 'ENG',
    @cLine01 = 'MOVE FROM        MVF'
   ,@cLine02 = ''
   ,@cLine03 = '1 = SHORT PICK'
   ,@cLine04 = '9 = CLOSE PALLET'
   ,@cLine05 = ''
   ,@cLine06 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1748

