-- 3560 = WAVEKEY screen
DELETE rdt.RDTScn WHERE Scn = 3560 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3560, 'ENG'
   ,@cLine01 = 'WAVEKEY:  %10i01'
   ,@cLine02 = 'PWAYZONE: %10i02'
   ,@cLine03 = ''
   ,@cLine04 = 'FROM LOC: %10i03'
   ,@cLine05 = 'TO LOC:   %10i04'
   ,@cLine14 = '%e'
   ,@nFunc = 949

-- 3561 = LOC screen
DELETE rdt.RDTScn WHERE Scn = 3561 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3561, 'ENG'
   ,@cLine01 = 'LOC: %10d01'
   ,@cLine02 = 'LOC: %10i02'
   ,@cLine14 = '%e'
   ,@nFunc = 949
 
-- 3562 = QTY screen
DELETE rdt.RDTScn WHERE Scn = 3562 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3562, 'ENG'
   ,@cLine01 = 'SKU:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = '%20d02'
   ,@cLine04 = '%20d03'
   ,@cLine05 = '1 %18d04'
   ,@cLine06 = '2 %18d05'
   ,@cLine07 = '3 %18d06'
   ,@cLine08 = '4 %10d07'
   ,@cLine09 = 'UCC:'
   ,@cLine10 = '%20i08'
   ,@cLine11 = 'QTY: %05d09'
   ,@cLine12 = 'BAL: %15d10'
   ,@cLine14 = '%e'
   ,@nFunc = 949

-- 3563 = OPTION screen
DELETE rdt.RDTScn WHERE Scn = 3563 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3563, 'ENG'
   ,@cLine01 = 'CONFIRM SHORT PICK? '
   ,@cLine03 = '1 = YES'
   ,@cLine04 = '2 = NO'
   ,@cLine06 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 949
