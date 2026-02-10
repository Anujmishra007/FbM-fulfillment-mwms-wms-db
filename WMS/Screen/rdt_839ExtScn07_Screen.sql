
   -- 6823 = Short pick screen
   DELETE rdt.RDTScn WHERE Scn = 6823 AND Lang_Code = 'ENG'
   EXECUTE rdt.rdtAddScn 6823, 'ENG'
      ,@cLine01 = ''
      ,@cLine02 = 'CONFIRM OPTION?' 
      ,@cLine03 = ''
      ,@cLine04 = '1 = SHORT'       
      ,@cLine05 = '2 = BAL PICK LATER' 
      ,@cLine06 = '3 = CLOSE DROPID'
      ,@cLine07 = '9 = Alternate PICK LOC' 
      ,@cLine08 = 'OPTION: %01i01'
      ,@cLine14 = '%e'
      ,@nFunc = 839
