-- rdt_PTLStation_CreateTask_OrderSKUQty
execute rdt.rdtDropMsg 101701, 101750

execute rdt.rdtAddMsg 101701, 10, '01701^AssignCartonID', 'us_english', 805
execute rdt.rdtAddMsg 101702, 10, '01702^No more task', 'us_english', 805
execute rdt.rdtAddMsg 101703, 10, '01703^INSPTLTranFail', 'us_english', 805
execute rdt.rdtAddMsg 101704, 10, '01704^No Task', 'us_english', 805
execute rdt.rdtAddMsg 101705, 10, '01705^DeviceIDReq', 'us_english', 805
--execute rdt.rdtAddMsg 101705, 10, '101705^PKDtl changed ', 'us_english', 805
