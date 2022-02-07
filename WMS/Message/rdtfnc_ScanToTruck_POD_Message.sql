-- rdtfnc_ScanToTruck_POD
exec rdt.rdtDropMsg 82701 , 82750

execute rdt.rdtAddMsg 82701, 10, '82701^Key either one', 'us_english', 924
execute rdt.rdtAddMsg 82702, 10, '82702^Value needed  ', 'us_english', 924
execute rdt.rdtAddMsg 82703, 10, '82703^MBOL/LOAD/ORD ', 'us_english', 924
execute rdt.rdtAddMsg 82704, 10, '82704^Bad MBOLKey   ', 'us_english', 924
execute rdt.rdtAddMsg 82705, 10, '82705^Bad LoadKey   ', 'us_english', 924
execute rdt.rdtAddMsg 82706, 10, '82706^Load Not MBOL ', 'us_english', 924
execute rdt.rdtAddMsg 82707, 10, '82707^Bad OrderKey  ', 'us_english', 924
execute rdt.rdtAddMsg 82708, 10, '82708^OrderNotYetLP ', 'us_english', 924
execute rdt.rdtAddMsg 82709, 10, '82708^Order Not MBOL', 'us_english', 924
execute rdt.rdtAddMsg 82710, 10, '82710^Order CANCEL  ', 'us_english', 924
execute rdt.rdtAddMsg 82711, 10, '82711^MBOL Shipped  ', 'us_english', 924
                                       
                                       
execute rdt.rdtAddMsg 82712, 10, '82712^Door Req', 'us_english', 924
execute rdt.rdtAddMsg 82713, 10, '82713^TruckNoReq', 'us_english', 924
execute rdt.rdtAddMsg 82714, 10, '82714^TransporterReq', 'us_english', 924
execute rdt.rdtAddMsg 82715, 10, '82715^PODCompleted', 'us_english', 924
execute rdt.rdtAddMsg 82716, 10, '82716^ExtUpdSPReq', 'us_english', 924

