-- 1920 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1920 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1920, 'ENG',
    @cLine01 = 'ASN: %10i01'
   ,@cLine02 = 'PO : %10i02'
   ,@cLine14 = '%e'
 
-- 1921 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1921 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1921, 'ENG',
    @cLine01 = 'ASN: %10d01'
   ,@cLine02 = 'PO : %10d02'
   ,@cLine04 = 'TO LOC: %10i03'
   ,@cLine14 = '%e'
 
-- 1922 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1922 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1922, 'ENG',
    @cLine01 = 'ASN: %10d01'
   ,@cLine02 = 'PO : %10d02'
   ,@cLine04 = 'TO LOC: %10d03'
   ,@cLine05 = 'TO ID:'
   ,@cLine06 = '%18i04'
   ,@cLine14 = '%e'

 
-- 1923 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1923 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1923, 'ENG',
    @cLine01 = 'ASN: %10d01'
   ,@cLine02 = 'PO : %10d02'
   ,@cLine04 = 'TO LOC: %10d03'
   ,@cLine05 = 'TO ID:'
   ,@cLine06 = '%18d04'
   ,@cLine08 = 'ESTIMATED'
   ,@cLine09 = 'CTN ON ID: %02i05'
   ,@cLine14 = '%e'
 
-- 1924 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1924 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1924, 'ENG',
    @cLine01 = 'LABEL:         %05d01'
   ,@cLine02 = '%32i02'
   ,@cLine03 = 'SKU:'
   ,@cLine04 = '%20d03'
   ,@cLine05 = 'STYLE:' 	
   ,@cLine06 = '%20d04'
   ,@cLine07 = 'COLOR:       SIZE:'
   ,@cLine08 = '%10d05       %10d06'
   ,@cLine10 = 'QTY REC: %11d09' -- (ChewKP01)
   ,@cLine11 = 'QTY: %05d07'     -- (ChewKP01)
   ,@cLine12 = 'CO#:'
   ,@cLine13 = '%20d08'
   ,@cLine14 = '%e'
 
-- 1925 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1925 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1925, 'ENG',
    @cLine01 = '%20i01'
   ,@cLine02 = '%20i02'
   ,@cLine03 = '%20i03'
   ,@cLine04 = '%20i04'
   ,@cLine05 = '%20i05'
   ,@cLine06 = '%20i06'
   ,@cLine07 = '%20i07'
   ,@cLine08 = '%18i08'
   ,@cLine14 = '%e'
   
-- 1926 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1926 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1926, 'ENG',
    @cLine01 = 'CONFIRM OVER'
   ,@cLine02 = 'RECEIVE?'
   ,@cLine04 = 'OPTION %01i01'
   ,@cLine06 = '1 = YES'
   ,@cLine07 = '2 = NO'
   ,@cLine14 = '%e'
   
-- 1927 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 1927 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 1927, 'ENG',
    @cLine01 = 'CONFIRM SHORT'
   ,@cLine02 = 'RECEIVE?'
   ,@cLine04 = 'OPTION %01i01'
   ,@cLine06 = '1 = YES'
   ,@cLine07 = '2 = NO'
   ,@cLine14 = '%e'