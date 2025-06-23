--rdtfnc_TM_ClusterPickV2
--6470-5929

IF NOT EXISTS ( SELECT 1 FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID = 1867)
BEGIN
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES (1867, 'ENG', 'FNC', 'TM Assist CPK V2', 'rdtfnc_TM_Assist_ClusterPickV2', '3')
END

-- 6470 = CART ID screen
DELETE rdt.RDTScn WHERE Scn = 6470 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6470, 'ENG'
   ,@cLine01 = 'TM Assist CPK'
   ,@cLine02 = 'AreaKey: %10i01'
   ,@cLine04 = 'CART ID:  %10i02'
   ,@cLine06 = 'METHOD:   %01i03'
   ,@cLine14 = '%e'
   ,@nFunc = 1867
 
-- 6471 = CART MATRIX screen
DELETE rdt.RDTScn WHERE Scn = 6471 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6471, 'ENG'
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
   ,@cLine13 = 'Option:%20i10 1-Close'
   ,@cLine14 = '%e'
   ,@nFunc = 1867

-- 6472 = LOC screen
DELETE rdt.RDTScn WHERE Scn = 6472 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6472, 'ENG'
   ,@cLine01 = 'TM Assist CPK'
   ,@cLine02 = '%20d01'
   ,@cLine03 = 'LOC: %10d02'
   ,@cLine04 = '%10i03'
   ,@cLine14 = '%e'
   ,@nFunc = 1867

-- 6473 = SKU/UPC, Qty screen
DELETE rdt.RDTScn WHERE Scn = 6473 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6473, 'ENG'
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
   ,@nFunc = 1867

-- 6474 = CONFIRM TOTE ID screen
DELETE rdt.RDTScn WHERE Scn = 6474 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6474, 'ENG'
   ,@cLine01 = 'TM Assist CPK'
   ,@cLine02 = '%20d01'
   ,@cLine03 = 'LOC: %10d02'
   ,@cLine04 = 'CONFIRM TOTE ID:'
   ,@cLine05 = '%20d03'
   ,@cLine06 = '%20i04'
   ,@cLine07 = 'POSITION:'
   ,@cLine08 = '%20d05'
   ,@cLine14 = '%e'
   ,@nFunc = 1867 

-- 6475 = OPTION screen
DELETE rdt.RDTScn WHERE Scn = 6475 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6475, 'ENG'
   ,@cLine01 = 'TM Assist CPK'
   ,@cLine02 = '%20d01'
   ,@cLine03 = 'CONFIRM SHORT PICK ?'
   ,@cLine04 = ''
   ,@cLine05 = '1 = YES'
   ,@cLine06 = '2 = NO'
   ,@cLine07 = 'OPTION: %01i02'
   ,@cLine14 = '%e'
   ,@nFunc = 1867   

-- 6476 = TO LOC screen
DELETE rdt.RDTScn WHERE Scn = 6476 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6476, 'ENG'
   ,@cLine01 = 'TM Assist CPK'
   ,@cLine02 = '%20d01'
   ,@cLine03 = 'TO LOC: %10d02'
   ,@cLine04 = '%10i03'
   ,@cLine14 = '%e'
   ,@nFunc = 1867 

-- 6477 = Unassign screen
DELETE rdt.RDTScn WHERE Scn = 6477 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6477, 'ENG'
   ,@cLine01 = 'TM Assist CPK'
   ,@cLine02 = '%20d01'
   ,@cLine03 = 'UNASSIGN CART ?'
   ,@cLine04 = ''
   ,@cLine05 = '1 = YES'
   ,@cLine06 = '2 = NO'
   ,@cLine07 = 'OPTION: %01i02'
   ,@cLine14 = '%e'
   ,@nFunc = 1867   

-- 6478 = NEXT TASK/ EXIT TM screen
DELETE rdt.RDTScn WHERE Scn = 6478 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6478, 'ENG'
   ,@cLine01 = 'TM Assist CPK'
   ,@cLine02 = '%20d01'
   ,@cLine03 = 'PICKING COMPLETED'
   ,@cLine04 = 'FOR CART: %10d02'
   ,@cLine05 = ''
   ,@cLine06 = 'ENTER = Next Task'
   ,@cLine14 = '%e'
   ,@nFunc = 1867

--WMS-19202
-- 6479 = Task exists, continue ?? screen
DELETE rdt.RDTScn WHERE Scn = 6479 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6479, 'ENG'
   ,@cLine01 = 'TM Assist CPK'
   ,@cLine02 = 'CARTON ALREADY'
   ,@cLine03 = 'ASSIGNED TO CART.'
   ,@cLine04 = 'CONTINUE ?'
   ,@cLine06 = '1 = YES'
   ,@cLine07 = '2 = NO'
   ,@cLine08 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1867

-- 6480 = Serial No
DELETE rdt.RDTScn WHERE Scn = 6480 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6480, 'ENG'
   ,@cLine01 = 'TM Assist CPK'
   ,@cLine02 = 'SKU/UPC:'
   ,@cLine03 = '%20d01'
   ,@cLine04 = '%20d02'
   ,@cLine05 = '%20d03'
   ,@cLine06 = ''
   ,@cLine07 = 'SerialNo:'
   ,@cLine08 = '%30i04'
   ,@cLine09 = 'SCAN/TOTAL: %08d05'
   ,@cLine14 = '%e'
   ,@nFunc = 1867


-- 6481 = Reason Code
DELETE rdt.RDTScn WHERE Scn = 6481 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6481, 'ENG'
   ,@cLine01 = 'TM Assist CPK'
   ,@cLine02 = ''
   ,@cLine03 = 'Reason Code:'
   ,@cLine04 = '%20i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1867


-- 6482 = Pallet Info
DELETE rdt.RDTScn WHERE Scn = 6482 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6482, 'ENG'
   ,@cLine01 = 'TM Assist CPK'
   ,@cLine02 = ''
   ,@cLine03 = 'PALLET TYPE: %20d01'
   ,@cLine04 = ''
   ,@cLine05 = 'PALLET HEIGHT: %20d02'
   ,@cLine06 = ''
   ,@cLine07 = 'No of PALLETS TYPE: %20d03'
   ,@cLine14 = '%e'
   ,@nFunc = 1867
