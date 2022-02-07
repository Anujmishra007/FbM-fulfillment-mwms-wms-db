--rdtfnc_PTL_Carton
-- 4210 - 4219


INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
VALUES ('895', 'ENG', 'FNC', 'Replenishment', 'rdtfnc_Replenishment', '0')


DELETE rdt.RDTScn WHERE Scn = 4210 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4210, 'ENG', 
   @cLine01 = 'REPLENISHMENT',
   @cLine03 = 'WAVEKEY:',
   @cLine04 = '%10i01',
   @cLine06 = 'REPLEN TYPE:',
   @cLine07 = '1=ALL',
   @cLine08 = '2=FCP',
   @cLine09 = '3=DPP',
   @cLine10 = '4=FCS',  -- WMS-145296
   @cLine11 = 'Option: %01i02',
   @cLine14 = '%e'

-- Screen 2
-- 4211 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 4211 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4211, 'ENG'
   ,@cLine01 = 'REPLENISHMENT'
   ,@cLine02 = 'SELECT PUTAWAY ZONE'
   ,@cLine03 = '%01i01 ALL'
   ,@cLine05 = '%01i02 %10d07'
   ,@cLine06 = '%01i03 %10d08'
   ,@cLine07 = '%01i04 %10d09'
   ,@cLine08 = '%01i05 %10d10'
   ,@cLine09 = '%01i06 %10d11'
   ,@cLine10 = '1 = Select Zone'
   ,@cLine11 = 'ENTER = Next Record'
   ,@cLine14 = '%e'
 
   
-- Screen 3
DELETE rdt.RDTScn WHERE Scn = 4212 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4212, 'ENG', 
   @cLine01 = 'REPLENISHMENT',
   @cLine03 = 'FROM LOC:',
   @cLine04 = '%10d01',
   @cLine05 = '%10i02',
   @cLine14 = '%e'


-- Screen 4
DELETE rdt.RDTScn WHERE Scn = 4213 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4213, 'ENG', 
   @cLine01 = 'REPLENISHMENT',
   @cLine03 = 'FROM LOC:',
   @cLine04 = '%10d01',
   @cLine06 = 'ID:',
   @cLine07 = '%18d02',
   @cLine08 = '%18i03',
   @cLine14 = '%e'   


-- 4214 = QTY screen
DELETE rdt.RDTScn WHERE Scn = 4214 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4214, 'ENG'
   ,@cLine01 = 'SKU:     CNT:%07d15'
   ,@cLine02 = '%20d02'
   ,@cLine03 = '%20d03'
   ,@cLine04 = '%20d04'
   ,@cLine05 = '%20i01'
   
   ,@cLine06 = '%20d05'
   ,@cLine07 = '%20d06'
   ,@cLine08 = '%20d07'
   ,@cLine09 = '%20d08'
   --,@cLine06 = 'L1:%18d09'
   --,@cLine07 = 'L2:%18d05'
   --,@cLine08 = 'L3:%18d06'
   --,@cLine09 = 'L4:%16d07'
   ,@cLine10 = '%20d14'
   ,@cLine11 = '%20d09'
   ,@cLine12 = 'RPL QTY: %05d10 %05d11'
   ,@cLine13 = 'ACT QTY: %05i12 %05i13'
   ,@cLine14 = '%e'
 
-- 4215 = ToLOC screen
DELETE rdt.RDTScn WHERE Scn = 4215 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4215, 'ENG',
    @cLine01 = 'FROM LOC: %10d01'
   ,@cLine02 = 'FROM ID:'
   ,@cLine03 = '%18d02'
--   ,@cLine04 = 'SKU:'
--   ,@cLine05 = '%20d03'
--   ,@cLine06 = '%20d04'
--   ,@cLine07 = '%20d05'
--   ,@cLine08 = '%08d14 %05d06 %05d07'
--   ,@cLine09 = 'RPL QTY: %05d08 %05d09'
--   ,@cLine10 = 'ACT QTY: %05d10 %05d11'
   ,@cLine12 = 'TO LOC: %10d12'
   ,@cLine13 = 'TO LOC: %10i13'
   ,@cLine14 = '%e'

-- 4216 = Message screen
DELETE rdt.RDTScn WHERE Scn = 4216 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4216, 'ENG',
    @cLine01 = 'REPLENISHMENT'
   ,@cLine03 = 'Replenish'
   ,@cLine04 = 'successfully'
   ,@cLine06 = 'Press ENTER or ESC'
   ,@cLine07 = 'to continue'
   ,@cLine14 = '%e'
 
 -- 4217 = Message screen
DELETE rdt.RDTScn WHERE Scn = 4217 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4217, 'ENG',
    @cLine01 = 'REPLENISHMENT'
   ,@cLine05 = '1=SHORT PICK'
   ,@cLine06 = '9=END REPLENISHMENT'
   ,@cLine08 = 'Option: %01i01'
   ,@cLine14 = '%e'

-- 4218 = Message screen
DELETE rdt.RDTScn WHERE Scn = 4218 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4218, 'ENG',
    @cLine01 = 'REPLENISHMENT'
   ,@cLine03 = 'EXIT REPLENISHMENT'
   ,@cLine04 = 'WITHOUT CONFIRM ?'
   ,@cLine06 = '1=YES'
   ,@cLine07 = '9=NO'
   ,@cLine08 = 'Option: %01i01'
   ,@cLine14 = '%e'

-- (ChewKP03)         
-- 4219 = Message screen
DELETE rdt.RDTScn WHERE Scn = 4219 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 4219, 'ENG',
    @cLine01 = 'REPLENISHMENT'
   ,@cLine03 = 'FROM LOC: %10d01'
   ,@cLine05 = 'FROM ID:'
   ,@cLine06 = '%18d02'
   ,@cLine08 = 'TOTAL CARTON COUNT:'
   ,@cLine09 = '%05i03'
   ,@cLine14 = '%e'
         
UPDATE RDT.RDTScn SET Func = 895 WHERE Scn Between 4210 AND 4219
UPDATE RDT.RDTScnDetail SET Func = 895 WHERE Scn Between 4210 AND 4219 