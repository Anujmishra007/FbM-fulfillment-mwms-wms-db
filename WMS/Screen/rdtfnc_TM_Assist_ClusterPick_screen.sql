IF NOT EXISTS ( SELECT 1 FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID = 1855 AND Lang_Code = 'ENG' AND Message_Type = 'FNC')
BEGIN
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES (1855, 'ENG', 'FNC', 'TM Assist CPK', 'rdtfnc_TM_Assist_ClusterPick', '3')
END

-- 5920 = Cart ID screen
DELETE rdt.RDTScn WHERE Scn = 5920 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5920, 'ENG'
   ,@cLine01 = N'TM Assist CPK'
   ,@cLine02 = N'PICKZONE: %10i01'
   ,@cLine04 = N'CART ID:  %10i02'
   ,@cLine06 = N'METHOD:   %01i03'
   ,@cLine14 = N'%e'
   ,@nFunc = 1855
 
-- 5921 = Matrix screen
DELETE rdt.RDTScn WHERE Scn = 5921 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5921, 'ENG'
   ,@cLine01 = N'TM Assist CPK'
   ,@cLine02 = N'%20d01'
   ,@cLine03 = N'CART ID: %10d02'
   ,@cLine04 = N''
   ,@cLine05 = N'%20d03'
   ,@cLine06 = N'%20d04'
   ,@cLine07 = N'%20d05'
   ,@cLine08 = N'%20d06'
   ,@cLine09 = N'%20d07'
   ,@cLine10 = N'TOTE ID:'
   ,@cLine11 = N'%20i08'
   ,@cLine12 = N'ASSIGNED: %03d09'
   ,@cLine13 = N''
   ,@cLine14 = N'%e'
   ,@nFunc = 1855
 
-- 5922 = LOC screen
DELETE rdt.RDTScn WHERE Scn = 5922 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5922, 'ENG'
   ,@cLine01 = N'TM Assist CPK'
   ,@cLine02 = N'%20d01'
   ,@cLine03 = N'LOC: %10d02'
   ,@cLine04 = N'%10i03'
   ,@cLine14 = N'%e'
   ,@nFunc = 1855

-- 5923 = SKU, QTY screen
DELETE rdt.RDTScn WHERE Scn = 5923 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5923, 'ENG'
   ,@cLine01 = N'TM Assist CPK'
   ,@cLine02 = N'%20d01'
   ,@cLine03 = N'LOC: %10d02'
   ,@cLine04 = N'SKU/UPC'
   ,@cLine05 = N'%20d03'
   ,@cLine06 = N'%20d04'
   ,@cLine07 = N'%20d05'
   ,@cLine08 = N'%20i06'
   ,@cLine09 = N''
   ,@cLine10 = N'PICK QTY: %03i07'
   ,@cLine11 = N'PICKED/TOTAL: %03d08 / %03d09'
   ,@cLine12 = N''
   ,@cLine13 = N'%20d15'
   ,@cLine14 = N'%e'
   ,@nFunc = 1855
 
-- 5924 = Confirm Tote ID screen
DELETE rdt.RDTScn WHERE Scn = 5924 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5924, 'ENG'
   ,@cLine01 = N'TM Assist CPK'
   ,@cLine02 = N'%20d01'
   ,@cLine03 = N'LOC: %10d02'
   ,@cLine04 = N'CONFIRM TOTE ID:'
   ,@cLine05 = N'%20d03'
   ,@cLine06 = N'%20i04'
   ,@cLine07 = N'POSITION:'
   ,@cLine08 = N'%20d05'
   ,@cLine14 = N'%e'
   ,@nFunc = 1855
 
-- 5925 = Short pick screen
DELETE rdt.RDTScn WHERE Scn = 5925 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5925, 'ENG'
   ,@cLine01 = N'TM Assist CPK'
   ,@cLine02 = N'%20d01'
   ,@cLine03 = N'CONFIRM SHORT PICK ?'
   ,@cLine04 = N''
   ,@cLine05 = N'1 = YES'
   ,@cLine06 = N'2 = NO'
   ,@cLine07 = N'OPTION: %01i02'
   ,@cLine14 = N'%e'
   ,@nFunc = 1855
 
-- 5926 = TO LOC screen
DELETE rdt.RDTScn WHERE Scn = 5926 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5926, 'ENG'
   ,@cLine01 = N'TM Assist CPK'
   ,@cLine02 = N'%20d01'
   ,@cLine03 = N'TO LOC: %10d02'
   ,@cLine04 = N'%10i03'
   ,@cLine14 = N'%e'
   ,@nFunc = 1855
 
-- 5927 = Unassign cart screen
DELETE rdt.RDTScn WHERE Scn = 5927 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5927, 'ENG'
   ,@cLine01 = N'TM Assist CPK'
   ,@cLine02 = N'%20d01'
   ,@cLine03 = N'UNASSIGN CART ?'
   ,@cLine04 = N''
   ,@cLine05 = N'1 = YES'
   ,@cLine06 = N'2 = NO'
   ,@cLine07 = N'OPTION: %01i02'
   ,@cLine14 = N'%e'
   ,@nFunc = 1855
 
-- 5928 = End, next task screen
DELETE rdt.RDTScn WHERE Scn = 5928 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5928, 'ENG'
   ,@cLine01 = N'TM Assist CPK'
   ,@cLine02 = N'%20d01'
   ,@cLine03 = N'PICKING COMPLETED'
   ,@cLine04 = N'FOR CART: %10d02'
   ,@cLine05 = N''
   ,@cLine06 = N'ENTER = Next Task'
   ,@cLine14 = N'%e'
   ,@nFunc = 1855
 
