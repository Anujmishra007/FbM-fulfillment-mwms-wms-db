-- 2330 = DROP ID screen
DELETE rdt.RDTScn WHERE Scn = 2330 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2330, 'ENG',
    @cLine01 = 'SCAN TO DOOR'
   ,@cLine03 = 'DROP ID:'
   ,@cLine04 = '%18i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1642
 
-- 2331 = TO DOOR screen
DELETE rdt.RDTScn WHERE Scn = 2331 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2331, 'ENG',
    @cLine01 = 'SCAN TO DOOR'
   ,@cLine03 = 'DROP ID:'
   ,@cLine04 = '%18d01'
   ,@cLine05 = 'TO DOOR:'
   ,@cLine06 = '%20d02'
   ,@cLine07 = '%20i03'
   ,@cLine14 = '%e'
   ,@nFunc = 1642
   
-- 2332 = ReasonCode screen
DELETE rdt.RDTScn WHERE Scn = 2332 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2332, 'ENG',
    @cLine01 = 'SCAN TO DOOR'
   ,@cLine03 = 'DROP ID:'
   ,@cLine04 = '%18d01'
   ,@cLine06 = 'Missing Parcel'
   ,@cLine07 = 'Carton Label'
   --,@cLine09 = '1 = NOT REQUIRED' -- (ChewKP03)
   ,@cLine10 = '1 = REPRINT'      -- (ChewKP03)
   ,@cLine11 = 'OPTION: %01i02'
   ,@cLine14 = '%e'   
   ,@nFunc = 1642

-- 2333 = ReasonCode screen
DELETE rdt.RDTScn WHERE Scn = 2333 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2333, 'ENG',
    @cLine01 = 'SCAN TO DOOR'
   ,@cLine03 = 'DROP ID:'
   ,@cLine04 = '%18d01'
   ,@cLine06 = 'REASON CODE:'
   ,@cLine07 = '%10i02' 
   ,@cLine14 = '%e'   
   ,@nFunc = 1642

-- 2334 = Close truck screen
DELETE rdt.RDTScn WHERE Scn = 2334 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 2334, 'ENG'
   ,@cLine01 = ''
   ,@cLine02 = 'ALL PALLET COMPLETED'
   ,@cLine03 = 'AND CLOSE TRUCK?'
   ,@cLine04 = ''
   ,@cLine05 = '1 = YES AND EXIT'
   ,@cLine06 = '2 = NO, EXIT ANYWAY'
   ,@cLine07 = ''
   ,@cLine08 = 'OPTION: %01i01'
   ,@cLine14 = '%e' 
   ,@nFunc = 1642
   
