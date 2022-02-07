
-- rdt_PFLStation_Assign_OrderKey
execute rdt.rdtDropMsg 160701 , 160750	

execute rdt.rdtAddMsg 160701, 10, '160701UpdLogFail', 'us_english', 801
execute rdt.rdtAddMsg 160702, 10, '160702UpdPTLTranFail', 'us_english', 801
execute rdt.rdtAddMsg 160703, 10, '160703DelLogFail', 'us_english', 801
execute rdt.rdtAddMsg 160704, 10, '160704NeedOrderKey', 'us_english', 801
execute rdt.rdtAddMsg 160705, 10, '160705OrderAssigned', 'us_english', 801
execute rdt.rdtAddMsg 160706, 10, '160706NoTask', 'us_english', 801
execute rdt.rdtAddMsg 160707, 10, '160707INSLogFail', 'us_english', 801
execute rdt.rdtAddMsg 160708, 10, '160708INSPTLTranFail', 'us_english', 801
execute rdt.rdtAddMsg 160709, 10, '160709UPDPTLTranFail', 'us_english', 801
