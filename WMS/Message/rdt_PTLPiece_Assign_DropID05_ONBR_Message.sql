-- rdt_PTLPiece_Assign_DropID05_ONBR
-- FCR-14204
execute rdt.rdtDropMsg 278751 , 278800

execute rdt.rdtAddMsg 278751, 10, '278751DevID Empty   ', 'us_english', 803, 0, '278751 DeviceID Can not be empty'
execute rdt.rdtAddMsg 278752, 10, '278752Need DropID   ', 'us_english', 803, 0, '278752 Need DropID'
execute rdt.rdtAddMsg 278753, 10, '278753Bad DropID    ', 'us_english', 803, 0, '278753 Drop ID not found in PickDetail'
execute rdt.rdtAddMsg 278754, 10, '278754DropIDAssigned', 'us_english', 803, 0, '278754 Drop ID already assigned'
execute rdt.rdtAddMsg 278755, 10, '278755INS Log fail  ', 'us_english', 803, 0, '278755 Failed to save assignment log'
execute rdt.rdtAddMsg 278756, 10, '278756No Stn/Pos    ', 'us_english', 803, 0, '278756 No PTL position found for this Drop ID at current station'
execute rdt.rdtAddMsg 278757, 10, '278757Tote stn {}   ', 'us_english', 803, 0, '278757 Tote belongs to station {}. Please scan at correct station'
execute rdt.rdtAddMsg 278758, 10, '278758UPD Log fail  ', 'us_english', 803, 0, '278758 Failed to update assignment log'
execute rdt.rdtAddMsg 278759, 10, '278759DropIDAssigned', 'us_english', 803, 0, '278759 Drop ID already assigned'
execute rdt.rdtAddMsg 278760, 10, '278760INS Log fail  ', 'us_english', 803, 0, '278760 Failed to save assignment log'
execute rdt.rdtAddMsg 278761, 10, '278761UPD Log fail  ', 'us_english', 803, 0, '278761 Failed to update assignment log'
execute rdt.rdtAddMsg 278762, 10, '278762NoOrderFound  ', 'us_english', 803, 0, '278762 No order found in hospital location'
execute rdt.rdtAddMsg 278763, 10, '278763NoOrderFound  ', 'us_english', 803, 0, '278763 No order found for this DropID'
execute rdt.rdtAddMsg 278764, 10, '278764UpdDeviceFail ', 'us_english', 803, 0, '278764 Failed to update device status'
execute rdt.rdtAddMsg 278765, 10, '278765DelPTLTranFail', 'us_english', 803, 0, '278765 Failed to delete PTLTran'

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 278751 AND 278800
