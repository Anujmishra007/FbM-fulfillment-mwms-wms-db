
-- 5130 = Criteria screen
DELETE rdt.RDTScn WHERE Scn = 5130 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5130, 'ENG',
    @cLine01 = 'REFNO:    %10i01'
   ,@cLine02 = ''
   ,@cLine03 = 'PSNO:     %10i02'
   ,@cLine04 = ''
   ,@cLine05 = 'LOADKEY:  %10i03'
   ,@cLine06 = ''
   ,@cLine07 = 'ORDERKEY: %10i04'
   ,@cLine08 = ''
   ,@cLine09 = 'CARTON ID:'
   ,@cLine10 = '%20i05'
   ,@cLine11 = ''
   ,@cLine14 = '%e'
   ,@nFunc = 903

-- 5131 = SKU screen
DELETE rdt.RDTScn WHERE Scn = 5131 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5131, 'ENG',
    @cLine01 = 'REFNO:    %10d01'
   ,@cLine02 = 'PSNO:     %10d02'
   ,@cLine03 = 'LOADKEY:  %10d03'
   ,@cLine04 = 'ORDERKEY: %10d04'
   ,@cLine05 = 'CARTON ID: '
   ,@cLine06 = '%20d05'
   ,@cLine07 = ''
   ,@cLine08 = 'SKU:'
   ,@cLine09 = '%60i06'
   ,@cLine14 = '%e'
   ,@nFunc = 903

-- Scn = 3940. Dynamic lottables

-- 5132 = QTY screen
DELETE rdt.RDTScn WHERE Scn = 5132 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5132, 'ENG',
    @cLine01 = 'SKU:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = '%20d02'
   ,@cLine04 = '%20d03'
   ,@cLine05 = 'LOTTABLES:'
   ,@cLine06 = '%20d04'
   ,@cLine07 = '%20d05'
   ,@cLine08 = '%20d06'
   ,@cLine09 = '%20d07'
   ,@cLine10 = ''
   ,@cLine11 = '%04d08     %05d09 %05d10'
   ,@cLine12 = 'QTY CHK: %05i11 %05i12'
   ,@cLine13 = '%20d13'
   ,@cLine14 = '%e'
   ,@nFunc = 903

-- 5133 = ststistic screen
DELETE rdt.RDTScn WHERE Scn = 5133 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5133, 'ENG',
    @cLine01 = 'REFNO:    %10d01'
   ,@cLine02 = 'PSNO:     %10d02'
   ,@cLine03 = 'LOADKEY:  %10d03'
   ,@cLine04 = 'ORDERKEY: %10d04'
   ,@cLine05 = 'CARTON ID:'
   ,@cLine06 = '%20d05'
   ,@cLine08 = ''
   ,@cLine09 = 'SKU CHK: %11d06'
   ,@cLine10 = 'QTY CHK: %11d07'
   ,@cLine11 = ''
   ,@cLine12 = '%20d08'
   ,@cLine14 = '%e'
   ,@nFunc = 903
