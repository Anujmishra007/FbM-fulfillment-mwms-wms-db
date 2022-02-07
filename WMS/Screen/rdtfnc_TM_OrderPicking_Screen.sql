-- 2350  = Take Empty Pallet Wood
DELETE rdt.RDTScn WHERE Scn = 2350 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2350, 'ENG',
    @cLine01 = 'TASK MANAGER'
   ,@cLine03 = 'Please take an empty'
   ,@cLine04 = 'Pallet'
   ,@cLine06 = 'Press ENTER to'
   ,@cLine07 = 'continue'
   ,@cLine14 = '%e'

-- 2351  = PrinterID , DropID  
DELETE rdt.RDTScn WHERE Scn = 2351 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2351, 'ENG',
    @cLine01 = 'ORDER PICKING    OPK'
   ,@cLine03 = 'PRINTER ID:'
   ,@cLine04 = '%20i01' -- (Vicky05)
	,@cLine06 = 'DROP ID:'
   ,@cLine07 = '%18i02'
   ,@cLine14 = '%e'
   
-- 2352  = FromLOC screen
DELETE rdt.RDTScn WHERE Scn = 2352 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2352, 'ENG',
    @cLine01 = 'ORDER PICKING    OPK'
   ,@cLine03 = 'DROP ID:'
   ,@cLine04 = '%18d01' 
   ,@cLine05 = 'FROM LOC: '
   ,@cLine06 = '%10d02' 
   ,@cLine07 = '%10i03'
   ,@cLine14 = '%e'


-- 2353  = ID screen
DELETE rdt.RDTScn WHERE Scn = 2353 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2353, 'ENG',
    @cLine01 = 'ORDER PICKING    OPK'
   ,@cLine03 = 'DROP ID:'
   ,@cLine04 = '%18d01' 
   ,@cLine05 = 'FROM LOC: '
   ,@cLine06 = '%10d02' 
   ,@cLine07 = 'PALLET ID: '
   ,@cLine08 = '%18d03'
   ,@cLine09 = '%18i04'
   ,@cLine14 = '%e'
   

-- 2354  = QTY screen
DELETE rdt.RDTScn WHERE Scn = 2354 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2354, 'ENG',
    @cLine01 = 'ORDER PICKING    OPK'
   ,@cLine03 = 'PALLET ID:'
   ,@cLine04 = '%18d01'
   ,@cLine05 = 'SKU:'
   ,@cLine06 = '%20d02'
   ,@cLine07 = '%20d03'
   ,@cLine08 = '%20d04'
   ,@cLine09 = '%04d11 %05d05 %05d06'
   ,@cLine10 = 'QTY: %05d07 %05d08'
   ,@cLine11 = 'QTY: %05i09 %05i10'
   ,@cLine14 = '%e'

-- 2355  = Template OPTION
DELETE rdt.RDTScn WHERE Scn = 2355 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2355, 'ENG',
    @cLine01 = 'Template ID Not'
   ,@cLine02 = 'setup:'
   ,@cLine04 = 'Apply generic.btw ?'
   ,@cLine06 = '1 - YES'
   ,@cLine07 = '2 - NO'
   ,@cLine09 = 'Option: %01i01'
   ,@cLine14 = '%e'
   

-- 2356  = Carton Printing screen
DELETE rdt.RDTScn WHERE Scn = 2356 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2356, 'ENG',
    @cLine01 = 'ORDER PICKING    OPK'
   ,@cLine03 = 'DROP ID:'
   ,@cLine04 = '%10d01' 
	,@cLine06 = 'TOTAL CARTON PRINTED:' -- Slight Change on vocab (ChewKP01)
   ,@cLine07 = '%10d02'
   ,@cLine09 = '%12d03'
   ,@cLine10 = '%12d04'
   ,@cLine11 = 'Press ENTER or ESC'
   ,@cLine12 = 'to continue'
   ,@cLine14 = '%e'

-- 2357  = OPTION
DELETE rdt.RDTScn WHERE Scn = 2357 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2357, 'ENG',
    @cLine01 = 'ORDER PICKING    OPK'
   ,@cLine03 = '1 = Close Pallete'
   ,@cLine04 = '2 = Cont Next Task'
   ,@cLine07 = 'Option: %01i01'
   ,@cLine14 = '%e'
   
   
-- 2358  = DROP ID screen
DELETE rdt.RDTScn WHERE Scn = 2358 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2358, 'ENG',
   @cLine01 = 'ORDER PICKING    OPK'
   ,@cLine03 = 'DROP ID:'
   ,@cLine04 = '%18d01' 
   ,@cLine05 = 'FROM LOC: '
   ,@cLine06 = '%10d02' 
   ,@cLine07 = 'PALLET ID: '
   ,@cLine08 = '%18d03'
   ,@cLine09 = 'TO LOC:'
   ,@cLine10 = '%10d04'
   ,@cLine11 = '%10i05'
   ,@cLine14 = '%e'
   
   
-- 2359  = MSG screen
DELETE rdt.RDTScn WHERE Scn = 2359 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2359, 'ENG',
    @cLine01 = 'ORDER PICKING    OPK'
   ,@cLine03 = 'PICKING is'
   ,@cLine04 = 'SUCCESSFUL'
   ,@cLine06 = 'ENTER = Next Task'
   ,@cLine07 = 'ESC = Exit TM'
   ,@cLine14 = '%e'
   
   
-- 2360  = MSG screen
DELETE rdt.RDTScn WHERE Scn = 2360 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2360, 'ENG',
    @cLine01 = 'ORDER PICKING    OPK'
   ,@cLine03 = '%07d01 %05d02 %05d03'
   ,@cLine04 = 'RMNQTY: %05d04 %05d05'
   ,@cLine06 = '1 = Short Pick'
   ,@cLine07 = '2 = New Pallet'
   ,@cLine09 = 'Option: %01i06'
   ,@cLine14 = '%e'
   
   
   
   




   
-- For task manager, need to update rdt.rdtscn with function id   
UPDATE RDT.RDTSCN SET FUNC = 1775 WHERE SCN BETWEEN 2350 AND 2360