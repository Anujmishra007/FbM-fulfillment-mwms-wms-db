--rdtfnc_MbolCreation
--5930-5939

IF NOT EXISTS ( SELECT 1 FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID = 1856)
BEGIN
   INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
   VALUES (1856, 'ENG', 'FNC', 'MBOL CREATION', 'rdtfnc_MbolCreation', '9')
END

-- 5930 = Facility screen
DELETE rdt.RDTScn WHERE Scn = 5930 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5930, 'ENG'
   ,@cLine01 = 'MBOL CREATION'
   ,@cLine03 = 'FACILITY: %05i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1856
 
-- 5931 = CART MATRIX screen
DELETE rdt.RDTScn WHERE Scn = 5931 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5931, 'ENG'
   ,@cLine01 = 'MBOL CREATION'
   ,@cLine03 = 'FACILITY: %05d01'
   ,@cLine04 = 'MBOLKEY : %10i02'
   ,@cLine05 = 'ORDERKEY: %10i03'
   ,@cLine06 = 'LOADKEY : %10i04'
   ,@cLine07 = '%20d05'          -- Refno 1 Label (WMS-20213)
   ,@cLine08 = '%20i06'          -- Refno 1 input 
   ,@cLine09 = '%20d07'          -- Refno 2 Label
   ,@cLine10 = '%20i08'          -- Refno 2 input
   ,@cLine11 = '%20d09'          -- Refno 3 Label
   ,@cLine12 = '%20i10'          -- Refno 3 input
   ,@cLine13 = 'ORDER #: %03d15'
   ,@cLine14 = '%e'
   ,@nFunc = 1856

-- 5932 = Close MBOL screen
DELETE rdt.RDTScn WHERE Scn = 5932 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5932, 'ENG'
   ,@cLine01 = 'MBOL CREATION'
   ,@cLine03 = 'MBOLKEY: %10d01'
   ,@cLine04 = 'CLOSE MBOL ?'
   ,@cLine05 = '1 = YES'
   ,@cLine06 = '2 = NO'
   ,@cLine07 = 'OPTION: %01i02'
   ,@cLine14 = '%e'
   ,@nFunc = 1856

-- WMS-17621
-- 5933 = Capture info screen
DELETE rdt.RDTScn WHERE Scn = 5933 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 5933, 'ENG'
   ,@cLine01 = '%20d01'
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
   ,@nFunc = 1856   