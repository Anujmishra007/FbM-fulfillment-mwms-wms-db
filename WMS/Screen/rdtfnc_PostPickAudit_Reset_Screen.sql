-- 2830 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2830 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2830, 'ENG',
    @cLine01 = 'REFNO:    %10i01'
   ,@cLine02 = ''
   ,@cLine03 = 'PSNO:     %10i02'
   ,@cLine04 = ''
   ,@cLine05 = 'LOADKEY:  %10i03'
   ,@cLine06 = ''
   ,@cLine07 = 'ORDERKEY: %10i04'
   ,@cLine08 = ''
   ,@cLine09 = 'CARTON ID:'
   ,@cLine10 = '%20i05'
   ,@cLine14 = '%e'
 
 -- 2831 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2831 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2831, 'ENG',
    @cLine01 = 'REFNO:    %10d01'
   ,@cLine02 = ''
   ,@cLine03 = 'PSNO:     %10d02'
   ,@cLine04 = ''
   ,@cLine05 = 'LOADKEY:  %10d03'
   ,@cLine06 = ''
   ,@cLine07 = 'ORDERKEY: %10d04'
   ,@cLine08 = ''
   ,@cLine09 = 'CARTON ID:'
   ,@cLine10 = '%20d05'
   ,@cLine11 = ''
   ,@cLine12 = 'SKU/UPC:'
   ,@cLine13 = '%20i06'
   ,@cLine14 = '%e'
   
-- 2832 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2832 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2832, 'ENG',
    @cLine01 = 'REFNO:    %10d01'
   ,@cLine02 = 'PSNO:     %10d02'
   ,@cLine03 = 'LOADKEY:  %10d03'
   ,@cLine04 = 'ORDERKEY: %10d04'
   ,@cLine05 = 'CARTON ID:'
   ,@cLine06 = '%20d05'
   ,@cLine07 = 'SKU:'
   ,@cLine08 = '%20d06'
   ,@cLine09 = '%20d07'
   ,@cLine10 = '%20d08'
   ,@cLine11 = '%20d09'
   ,@cLine12 = '%10d10     %05d11'
   ,@cLine14 = '%e'
 
-- 2833 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2833 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2833, 'ENG',
    @cLine01 = ''
   ,@cLine02 = 'Reset PPA QTY?'
   ,@cLine03 = ''
   ,@cLine04 = '1=YES'
   ,@cLine05 = '2=NO'
   ,@cLine06 = ''
   ,@cLine07 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
 