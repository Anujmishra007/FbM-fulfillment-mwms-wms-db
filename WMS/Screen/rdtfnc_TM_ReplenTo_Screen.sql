--scn 2780 --- 2789


INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
VALUES ('1765', 'ENG', 'FNC', 'TM Move', 'rdtfnc_TM_ReplenTo', '0')

Insert Into rdt.rdttaskmanagerconfig ( TaskType, TaskDesc, Function_ID, Step)
Values ( 'RPT', 'Replenishment To', 1765, '0' )

INSERT INTO CODELKUP ( ListName , Code)
VALUES ( 'TTMST' , 'nspTTMRT01')

INSERT INTO Codelkup (ListName , Code , Description , Short , Long ) 
Values ( 'PERMTYPE' , 'RPT', 'Replenisment To' , 'RPT' , 'Replenishment To' ) 

INSERT INTO Codelkup (ListName , Code , Description , Short , Long ) 
Values ( 'TASKTYPE ' , 'RPT', 'Replenisment To' , 'RPT' , 'Replenishment To' ) 

-- 2780  = FromLOC screen
DELETE rdt.RDTScn WHERE Scn = 2780 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2780, 'ENG',
    @cLine01 = 'TM REPLEN TO     RPT'
   ,@cLine03 = 'FROM LOC: '
   ,@cLine04 = '%10d01'
   ,@cLine05 = '%10i02'
   ,@cLine14 = '%e'

-- 2781  = ID screen
DELETE rdt.RDTScn WHERE Scn = 2781 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2781, 'ENG'
   ,@cLine01 = 'TM REPLEN TO     RPT'
   ,@cLine03 = 'FROM LOC: '
   ,@cLine04 = '%10d01'
   ,@cLine05 = 'ID: '
   ,@cLine06 = '%18d02'
   ,@cLine07 = '%40i03'
   ,@cLine14 = '%e'  



-- 2782  = TO LOC screen
DELETE rdt.RDTScn WHERE Scn = 2782 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2782, 'ENG',
    @cLine01 = 'TM REPLEN TO     RPT'
   ,@cLine03 = 'FROM LOC: '
   ,@cLine04 = '%10d01'
   ,@cLine05 = 'ID: '
   ,@cLine06 = '%18d02'
   ,@cLine07 = '%20d05'
   ,@cLine08 = '%20d06'
   ,@cLine09 = '%20d07'
   ,@cLine10 = 'TO LOC:'
   ,@cLine11 = '%10d03'
   ,@cLine12 = '%10i04'
   ,@cLine14 = '%e'
      


-- 2783  = SKU screen
--DELETE rdt.RDTScn WHERE Scn = 2783 AND Lang_Code = 'ENG'
--EXECUTE rdt.rdtAddScn 2783, 'ENG',
--    @cLine01 = 'TM REPLEN TO     RPT'
--   ,@cLine03 = 'FROM LOC: '
--   ,@cLine04 = '%10d01'
--   ,@cLine05 = 'ID: '
--   ,@cLine06 = '%18d02'
--   ,@cLine07 = 'TO LOC:'
--   ,@cLine08 = '%10d03'
--   ,@cLine09 = 'SKU/UPC/UCC:'
--   ,@cLine10 = '%20d04'
--   ,@cLine11 = '%20i05'
--   ,@cLine14 = '%e'   


-- 2784  = QTY, REASON CODE screen
DELETE rdt.RDTScn WHERE Scn = 2783 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2783, 'ENG',
   @cLine01 = 'TO LOC: %10d01'
   ,@cLine02 = '%20d02' 
   ,@cLine03 = '%20d03' 
   ,@cLine04 = '%20d04' 
   ,@cLine05 = '%20d05' 
   ,@cLine06 = '%20d06' 
   ,@cLine07 = '%20d07' 
   ,@cLine08 = '%20d08'
   ,@cLine09 = '%20d09' 
   ,@cLine10 = '%20i10'
   ,@cLine11 = '%20d11'
   ,@cLine12 = 'QTY: %05d12 %05d13'
   ,@cLine13 = 'QTY: %05i14 %05i15'
   ,@cLine14 = '%e'   


-- 2785  = Msg screen
DELETE rdt.RDTScn WHERE Scn = 2784 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2784, 'ENG',
    @cLine01 = 'TM REPLEN TO     RPT'
   ,@cLine03 = 'Inventory is '
   ,@cLine04 = 'successfully move'
   ,@cLine06 = 'ENTER = Next Task'
   ,@cLine07 = 'ESC   = Exit TM'
   ,@cLine14 = '%e'

      

-- For task manager, need to update rdt.rdtscn with function id   
UPDATE RDT.RDTSCN SET FUNC = 1765 WHERE SCN BETWEEN 2780 AND 2789