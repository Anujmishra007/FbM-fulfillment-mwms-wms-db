-- 4150 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4150 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4150, 'ENG',
    @cLine01 = 'PALLET ID: '
   ,@cLine02 = '%18i01'
   ,@cLine14 = '%e'
   ,@nFunc   = 733

-- 4151 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4151 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4151, 'ENG',
    @cLine01 = '%20d08'    -- SKU
   ,@cLine02 = '%20d09'    -- DESCR1
   ,@cLine03 = '%20d10'    -- DESCR1
   ,@cLine04 = '%20d01'    -- L1
   ,@cLine05 = '%20d02'    -- L2
   ,@cLine06 = '%20d03'    -- L3
   ,@cLine07 = '%20d04'    -- L4
   ,@cLine08 = '%20d05'    -- L5
   ,@cLine09 = '%20d06'    -- L6
   ,@cLine10 = '%20d07'    -- L7
   ,@cLine11 = '%20d11'    -- Pref UOM
   ,@cLine12 = '%20d12'    -- UOM
   ,@cLine13 = '1=ADD 2=EDIT 3=CFM %01i13'
   ,@cLine14 = '%e'
   ,@nFunc   = 733

-- 4152 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4152 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4152, 'ENG',
    @cLine01 = 'QTY: '
   ,@cLine02 = '%05d01 %05d02'
   ,@cLine03 = '      %05i03'
   ,@cLine04 = '%05d04 %07d05'
   ,@cLine05 = '      %07i06'
   ,@cLine14 = '%e'
   ,@nFunc   = 733

-- 4153 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4153 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4153, 'ENG',
    @cLine01 = 'SKU: '
   ,@cLine02 = '%20i01'
   ,@cLine14 = '%e'
   ,@nFunc   = 733

-- 4154 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4154 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4154, 'ENG',
    @cLine01 = '%20d01'
   ,@cLine02 = '%20i02'
   ,@cLine03 = '%20d03'
   ,@cLine04 = '%20i04'
   ,@cLine05 = '%20d05'
   ,@cLine06 = '%20i06'
   ,@cLine07 = '%20d07'
   ,@cLine08 = '%20i08'
   ,@cLine09 = '%20d09'
   ,@cLine10 = '%20i10'
   ,@cLine14 = '%e'
   ,@nFunc   = 733

-- 4155 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4155 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4155, 'ENG',
    @cLine01 = '%20d01'
   ,@cLine02 = '%20d02'
   ,@cLine03 = '%20d03'
   ,@cLine05 = 'QTY:'
   ,@cLine06 = '%05d04 %05i05'
   ,@cLine07 = '%05d06 %07i07'
   ,@cLine14 = '%e'
   ,@nFunc   = 733