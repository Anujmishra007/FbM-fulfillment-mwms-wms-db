-- Function 1868
-- 6511 = PSNO screen
DELETE rdt.RDTScn WHERE Scn = 6511 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6511, 'ENG'
   ,@cLine01 = 'PSNO'
   ,@cLine02 = '%10i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1868



-- 6512 = Confirm Unpack or Unpack & Unpick
DELETE rdt.RDTScn WHERE Scn = 6512 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6512, 'ENG'
   ,@cLine01 = 'COMFIRM UNPACK?'
   ,@cLine04 = '1.Unpack'
   ,@cLine05 = '2.Unpack And Unpick'
   ,@cLine08 = 'OPTION: %01i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1868

--6513 = Unpack & Unpick location
DELETE rdt.RDTScn WHERE Scn = 6513 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6513, 'ENG'
   ,@cLine01 = 'To Location'
   ,@cLine02 = '%30i01'
   ,@cLine14 = '%e'
   ,@nFunc = 1868

--6514 = Scan serial number
DELETE rdt.RDTScn WHERE Scn = 6514 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6514, 'ENG'
   ,@cLine01 = 'SERIALNO'
   ,@cLine02 = '%200iV_Barcode' --FCR-9889
   ,@cLine05 = 'Scanned SN: %08d02'
   ,@cLine08 = 'Option %01i04'
   ,@cLine09 = '9: Finish %10d03'
   ,@cLine14 = '%e'
   ,@nFunc = 1868
   ,@cWebGroup = '{"1":["1","2"],"2":["5"],"3":["8","9"]}'

--6515 = Complete
DELETE rdt.RDTScn WHERE Scn = 6515 AND Lang_Code = 'ENG'
EXECUTE rdt.rdtAddScn 6515, 'ENG'
   ,@cLine02 = '%10d01 Complete'
   ,@cLine04 = 'Press enter or ESC to continue'
   ,@cLine14 = '%e'
   ,@nFunc = 1868
      




