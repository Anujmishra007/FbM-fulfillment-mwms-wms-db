-- 2970 = LPN screen
DELETE rdt.RDTScn WHERE Scn = 2970 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2970, 'ENG'
   ,@cLine01 = 'MPK/LPN/TOTE:'
   ,@cLine02 = '%20i01'
   ,@cLine14 = '%e'
   ,@nFunc = 952
   
-- 2971 = MPK/LPN screen
DELETE rdt.RDTScn WHERE Scn = 2971 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2971, 'ENG'
   ,@cLine01 = '%20d01'
   ,@cLine02 = 'MPK:'
   ,@cLine03 = '%20d02'
   ,@cLine04 = 'LPN:'
   ,@cLine05 = '%20i03'
   ,@cLine12 = 'SCAN INNER LPN'
   ,@cLine14 = '%e'
   ,@nFunc = 952
   
-- 2972 = MPK/LPN screen
DELETE rdt.RDTScn WHERE Scn = 2972 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2972, 'ENG'
   ,@cLine01 = '%20d01'
   ,@cLine02 = 'MPK:'
   ,@cLine03 = '%20i02'
   ,@cLine04 = 'LPN:'
   ,@cLine05 = '%20d03'
   ,@cLine13 = 'SCAN MASTER LPN'
   ,@cLine14 = '%e'
   ,@nFunc = 952
   
-- 2973 = Print INNER LPN screen
DELETE rdt.RDTScn WHERE Scn = 2973 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2973, 'ENG'
   ,@cLine01 = '%20d01'
   ,@cLine02 = 'MPK:'
   ,@cLine03 = '%20d02'
   ,@cLine04 = 'LPN:'
   ,@cLine05 = '%20d03'
   ,@cLine08 = 'APPLY GS1/UCC LABEL'
   ,@cLine09 = '%20d04'
   ,@cLine10 = '%20d05'
   ,@cLine12 = '%20d06'
   ,@cLine13 = '<ENTER> TO CONFIRM'
   ,@cLine14 = '%e'
   ,@nFunc = 952
   
-- 2974 = Conveyable screen
DELETE rdt.RDTScn WHERE Scn = 2974 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2974, 'ENG'
   ,@cLine01 = 'MPK: NO'
   ,@cLine02 = 'LPN: %20d01'
   ,@cLine04 = 'CONVEYABLE?'
   ,@cLine06 = '1 = YES'
   ,@cLine07 = '2 = NO'
   ,@cLine09 = 'OPTION: %01i02'
   ,@cLine14 = '%e'
   ,@nFunc = 952
   
-- 2975 = Apply Label Child LPN screen
DELETE rdt.RDTScn WHERE Scn = 2975 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2975, 'ENG'
   ,@cLine01 = 'MPK: NO'
   ,@cLine02 = 'LPN: %20d01'
   ,@cLine04 = 'APPLY GS1/UCC'
   ,@cLine05 = 'LABEL TO CARTON'
   ,@cLine13 = 'ENTER TO CONFIRM'
   ,@cLine14 = '%e'
   ,@nFunc = 952

-- 2976 = Apply Label On CTN screen
DELETE rdt.RDTScn WHERE Scn = 2976 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2976, 'ENG'
   ,@cLine01 = 'MPK: NO'
   ,@cLine02 = 'LPN: %20d01'
   ,@cLine04 = 'APPLY GS1/UCC'
   ,@cLine05 = 'LABEL TO CARTON'
   ,@cLine07 = 'PLACE INTO TOTE #:'
   ,@cLine08 = '%20i02'
   ,@cLine10 = 'TOTE FULL?'
   ,@cLine11 = '1 = YES'
   ,@cLine12 = '2 = NO'
   ,@cLine13 = 'OPTION: %01i03'
   ,@cLine14 = '%e'
   ,@nFunc = 952
   
-- 2977 = Weight screen
DELETE rdt.RDTScn WHERE Scn = 2978 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2978, 'ENG'
   ,@cLine02 = 'ENTER WEIGHT'
   ,@cLine03 = '%05i01'
   ,@cLine14 = '%e'
   ,@nFunc = 952