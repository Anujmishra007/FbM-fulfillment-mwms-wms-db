--rdtfnc_ScanToTruck_Reset
-- 3650 - 3659


INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
VALUES ('923', 'ENG', 'FNC', 'ScanToTruck Reset', 'rdtfnc_ScanToTruck_Reset', '0')

-- 3650 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 3650 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3650, 'ENG'
   ,@cLine01 = 'MBOLKEY:  %10i01'
   ,@cLine02 = ''
   ,@cLine03 = 'LOADKEY:  %10i02'
   ,@cLine04 = ''
   ,@cLine05 = 'ORDERKEY: %10i03'
   ,@cLine14 = '%e'
   ,@nFunc = 923 

-- (ChewKP01) 
DELETE rdt.RDTScn WHERE Scn = 3651 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3651, 'ENG'
   ,@cLine01 = 'MBOLKEY:  %10d01'
   ,@cLine02 = 'LOADKEY:  %10d02'
   ,@cLine03 = 'ORDERKEY: %10d03'
   ,@cLine04 = ''
   ,@cLine05 = 'LABELNO/DROPID:'
   ,@cLine06 = '%20i04'
   ,@cLine08 = ''
   ,@cLine14 = '%e'
   ,@nFunc = 923   

-- 3651 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 3652 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3652, 'ENG'
   ,@cLine01 = 'MBOLKEY:  %10d01'
   ,@cLine02 = 'LOADKEY:  %10d02'
   ,@cLine03 = 'ORDERKEY: %10d03'
   ,@cLine04 = ''
   ,@cLine05 = 'CONFIRM RESET?'
   ,@cLine06 = '1 = YES | 9 = NO'
   ,@cLine10 = 'OPTION:%01i04'
   ,@cLine14 = '%e'
   ,@nFunc = 923
 