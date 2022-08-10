-- 2840 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2840 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2840, 'ENG',
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
 
 -- 2841 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2841 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2841, 'ENG',
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
   
-- 2842 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2842 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2842, 'ENG',
    @cLine01 = 'TTL   SKU    QTY'
   ,@cLine02 = 'PICK: %05d01 %07d02'
   ,@cLine03 = 'PPA:  %05d03 %07d04'
   ,@cLine14 = '%e'
 
-- 2843 = ?? screen
DELETE rdt.RDTScn WHERE Scn = 2843 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2843, 'ENG',
    
    @cLine01 = 'TTL     SKU    QTY'
   ,@cLine02 = 'PICK: %05d01 %07d02'
   ,@cLine03 = 'PPA : %05d03 %07d04'
   ,@cLine05 = 'SKU:         %10d13'
   ,@cLine06 = '%20d07'
   ,@cLine07 = '%20d08'
   ,@cLine08 = '%20d09'
   ,@cLine09 = '%20d10'
   ,@cLine10 = '%20d11'
   ,@cLine11 = 'PICK QTY:%05d05 %05d06'
   ,@cLine12 = 'PPA QTY :%05d12 %05d14'
   ,@cLine13 = '%20d15' --(yeekung01)
   ,@cLine14 = '%e'
 