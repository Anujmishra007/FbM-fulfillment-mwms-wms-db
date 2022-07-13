--rdtfnc_TM_ClusterPick
--5920-5929

IF NOT EXISTS ( SELECT 1 FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID = 1855)
BEGIN
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES (1855, 'ENG', 'FNC', 'TM Assist CPK', 'rdtfnc_TM_Assist_ClusterPick', '3')
END

-- 5920 = CART ID screen
DELETE rdt.RDTScn WHERE Scn = 5920 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5920, 'ENG'
   ,@cLine01 = 'TM Assist CPK'
   ,@cLine02 = 'PICKZONE: %10i01'
   ,@cLine04 = 'CART ID:  %10i02'
   ,@cLine06 = 'METHOD:   %01i03'
   ,@cLine14 = '%e'
   ,@nFunc = 1855
 
-- 5921 = CART MATRIX screen
DELETE rdt.RDTScn WHERE Scn = 5921 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5921, 'ENG'
   ,@cLine01 = 'TM Assist CPK'
   ,@cLine02 = '%20d01'
   ,@cLine03 = 'CART ID: %10d02'
   ,@cLine04 = ''
   ,@cLine05 = '%20d03'
   ,@cLine06 = '%20d04'
   ,@cLine07 = '%20d05'
   ,@cLine08 = '%20d06'
   ,@cLine09 = '%20d07'
   ,@cLine10 = 'TOTE ID:'
   ,@cLine11 = '%20i08'
   ,@cLine12 = 'ASSIGNED: %03d09'
   ,@cLine13 = ''
   ,@cLine14 = '%e'
   ,@nFunc = 1855

-- 5922 = LOC screen
DELETE rdt.RDTScn WHERE Scn = 5922 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5922, 'ENG'
   ,@cLine01 = 'TM Assist CPK'
   ,@cLine02 = '%20d01'
   ,@cLine03 = 'LOC: %10d02'
   ,@cLine04 = '%10i03'
   ,@cLine14 = '%e'
   ,@nFunc = 1855

-- 5923 = SKU/UPC, Qty screen
DELETE rdt.RDTScn WHERE Scn = 5923 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5923, 'ENG'
   ,@cLine01 = 'TM Assist CPK'
   ,@cLine02 = '%20d01'
   ,@cLine03 = 'LOC: %10d02'
   ,@cLine04 = 'SKU/UPC'
   ,@cLine05 = '%20d03'
   ,@cLine06 = '%20d04'
   ,@cLine07 = '%20d05'
   ,@cLine08 = '%20i06'
   ,@cLine09 = ''
   ,@cLine10 = 'PICK QTY: %03i07'
   ,@cLine11 = 'PICKED/TOTAL: %03d08 / %03d09'
   ,@cLine14 = '%e'
   ,@nFunc = 1855

-- 5924 = CONFIRM TOTE ID screen
DELETE rdt.RDTScn WHERE Scn = 5924 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5924, 'ENG'
   ,@cLine01 = 'TM Assist CPK'
   ,@cLine02 = '%20d01'
   ,@cLine03 = 'LOC: %10d02'
   ,@cLine04 = 'CONFIRM TOTE ID:'
   ,@cLine05 = '%20d03'
   ,@cLine06 = '%20i04'
   ,@cLine07 = 'POSITION:'
   ,@cLine08 = '%20d05'
   ,@cLine14 = '%e'
   ,@nFunc = 1855 

-- 5925 = OPTION screen
DELETE rdt.RDTScn WHERE Scn = 5925 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5925, 'ENG'
   ,@cLine01 = 'TM Assist CPK'
   ,@cLine02 = '%20d01'
   ,@cLine03 = 'CONFIRM SHORT PICK ?'
   ,@cLine04 = ''
   ,@cLine05 = '1 = YES'
   ,@cLine06 = '2 = NO'
   ,@cLine07 = 'OPTION: %01i02'
   ,@cLine14 = '%e'
   ,@nFunc = 1855   

-- 5926 = TO LOC screen
DELETE rdt.RDTScn WHERE Scn = 5926 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5926, 'ENG'
   ,@cLine01 = 'TM Assist CPK'
   ,@cLine02 = '%20d01'
   ,@cLine03 = 'TO LOC: %10d02'
   ,@cLine04 = '%10i03'
   ,@cLine14 = '%e'
   ,@nFunc = 1855 

-- 5927 = Unassign screen
DELETE rdt.RDTScn WHERE Scn = 5927 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5927, 'ENG'
   ,@cLine01 = 'TM Assist CPK'
   ,@cLine02 = '%20d01'
   ,@cLine03 = 'UNASSIGN CART ?'
   ,@cLine04 = ''
   ,@cLine05 = '1 = YES'
   ,@cLine06 = '2 = NO'
   ,@cLine07 = 'OPTION: %01i02'
   ,@cLine14 = '%e'
   ,@nFunc = 1855   

-- 5928 = NEXT TASK/ EXIT TM screen
DELETE rdt.RDTScn WHERE Scn = 5928 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5928, 'ENG'
   ,@cLine01 = 'TM Assist CPK'
   ,@cLine02 = '%20d01'
   ,@cLine03 = 'PICKING COMPLETED'
   ,@cLine04 = 'FOR CART: %10d02'
   ,@cLine05 = ''
   ,@cLine06 = 'ENTER = Next Task'
   ,@cLine14 = '%e'
   ,@nFunc = 1855

--WMS-19202
-- 5929 = Task exists, continue ?? screen
DELETE rdt.RDTScn WHERE Scn = 5929 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5929, 'ENG'
   ,@cLine01 = 'TM Assist CPK'
   ,@cLine02 = 'CARTON ALREADY'
   ,@cLine03 = 'ASSIGNED TO CART.'
   ,@cLine04 = 'CONTINUE ?'
   ,@cLine06 = '1 = YES'
   ,@cLine07 = '2 = NO'
   ,@cLine08 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1855
