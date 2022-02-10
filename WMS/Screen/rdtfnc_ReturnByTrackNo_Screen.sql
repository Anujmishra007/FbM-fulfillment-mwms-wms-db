-- 3040 = LOC, ASN screen
DELETE rdt.RDTScn WHERE Scn = 3040 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3040, 'ENG',
    @cLine01 = 'RTN ASN: %10i01'
   ,@cLine14 = '%e'
   ,@nFunc = 549
   
-- 3041 = TrackingNo screen
DELETE rdt.RDTScn WHERE Scn = 3041 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3041, 'ENG',
    @cLine01 = 'RTN ASN: %10d01'
   ,@cLine02 = 'TRACKING NO:'
   ,@cLine03 = '%20i02'
   ,@cLine14 = '%e'
   ,@nFunc = 549
    
-- 3042 = Return SKU screen
DELETE rdt.RDTScn WHERE Scn = 3042 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3042, 'ENG',
    @cLine01 = 'PT/PO:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = '%20d02'
   ,@cLine04 = 'SKU:'
   ,@cLine05 = '%20d03'        --SKU
   ,@cLine06 = '%20d04'        --Desc1
   ,@cLine07 = '%20d05'        --Desc2
   ,@cLine08 = '%20d06'        --Style
   ,@cLine09 = '%10d07 %05d08' --Color, Size
   ,@cLine10 = ''
   ,@cLine11 = 'OPTION: %01i09'
   ,@cLine12 = '1=RECEIVE 2=LOOKUP'
   ,@cLine14 = '%e'
   ,@nFunc = 549

-- 3043 = Return SKU lookup screen
DELETE rdt.RDTScn WHERE Scn = 3043 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3043, 'ENG',
    @cLine01 = 'NAME:'
   ,@cLine02 = '%20d01'
   ,@cLine03 = 'SKU:'
   ,@cLine04 = '%20d02'
   ,@cLine05 = '%20d03' 	
   ,@cLine06 = '%20d04'
   ,@cLine07 = '%20d05'
   ,@cLine08 = '%10d06 %05d07' --Color, Size
   ,@cLine09 = ''
   ,@cLine10 = ''
   ,@cLine11 = 'OPTION: %01i08 %10d09'
   ,@cLine12 = '1=RECEIVE,ENTER=NEXT'
   ,@cLine14 = '%e'
   ,@nFunc = 549
   
-- 3044 = Return SKU condition screen
DELETE rdt.RDTScn WHERE Scn = 3044 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3044, 'ENG',
    @cLine01 = 'RETURN'
   ,@cLine02 = ''
   ,@cLine03 = 'RTN TYPE: %10i01'
   ,@cLine04 = 'CONDCODE: %01i02' -- Condition code
   ,@cLine05 = 'RSN CODE: %10i03' -- Reason code
   ,@cLine06 = 'TO LOC  : %10i04'
   ,@cLine07 = 'FCTRYCOD: %10i05'
   ,@cLine08 = 'FCTRYLOT: %10i06'
   ,@cLine14 = '%e'
   ,@nFunc = 549

-- 3045 = Exchange SKU screen
DELETE rdt.RDTScn WHERE Scn = 3045 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3045, 'ENG',
    @cLine01 = 'EXCHANGE'
   ,@cLine02 = ''
   ,@cLine03 = 'SKU:'
   ,@cLine04 = '%20i01'
   ,@cLine05 = ''
   ,@cLine06 = 'OR'
   ,@cLine07 = ''
   ,@cLine08 = 'STYLE:'
   ,@cLine09 = '%20i02'
   ,@cLine10 = 'COLOR: %10i03'
   ,@cLine11 = 'SIZE : %05i04'
   ,@cLine14 = '%e'
   ,@nFunc = 549
   
-- 3046 = Exhcnage SKU confirm screen
DELETE rdt.RDTScn WHERE Scn = 3046 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 3046, 'ENG',
    @cLine01 = 'EXCHANGE'
   ,@cLine02 = ''
   ,@cLine03 = 'SKU:'
   ,@cLine04 = '%20d01'
   ,@cLine05 = '%20d02' 	
   ,@cLine06 = '%20d03'
   ,@cLine07 = '%20d04'
   ,@cLine08 = '%10d05 %05d06'
   ,@cLine09 = ''
   ,@cLine10 = 'ENTER=CONFIRM'
   ,@cLine11 = 'ESC=BACK'
   ,@cLine14 = '%e'
   ,@nFunc = 549