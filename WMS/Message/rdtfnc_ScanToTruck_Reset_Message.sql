-- rdtfnc_ScanToTruck_Reset
exec rdt.rdtDropMsg 82651 , 82700

execute rdt.rdtAddMsg 82651, 10, '82651^Key either one', 'us_english', 923
execute rdt.rdtAddMsg 82652, 10, '82652^Value needed  ', 'us_english', 923
execute rdt.rdtAddMsg 82653, 10, '82653^MBOL/LOAD/ORD ', 'us_english', 923
execute rdt.rdtAddMsg 82654, 10, '82654^Bad MBOLKey   ', 'us_english', 923
execute rdt.rdtAddMsg 82655, 10, '82655^Bad LoadKey   ', 'us_english', 923
execute rdt.rdtAddMsg 82656, 10, '82656^Load Not MBOL ', 'us_english', 923
execute rdt.rdtAddMsg 82657, 10, '82657^Bad OrderKey  ', 'us_english', 923
execute rdt.rdtAddMsg 82658, 10, '82658^OrderNotYetLP ', 'us_english', 923
execute rdt.rdtAddMsg 82659, 10, '82659^Order Not MBOL', 'us_english', 923
execute rdt.rdtAddMsg 82660, 10, '82660^Order CANCEL  ', 'us_english', 923
execute rdt.rdtAddMsg 82661, 10, '82661^MBOL Shipped  ', 'us_english', 923
                                       
                                       
execute rdt.rdtAddMsg 82662, 10, '82662^Option Req', 'us_english', 923
execute rdt.rdtAddMsg 82663, 10, '82663^InvalidOption', 'us_english', 923
execute rdt.rdtAddMsg 82664, 10, '82664^ResetFail', 'us_english', 923
execute rdt.rdtAddMsg 82665, 10, '82665^ResetFail', 'us_english', 923
execute rdt.rdtAddMsg 82666, 10, '82666^ResetFail', 'us_english', 923
execute rdt.rdtAddMsg 82667, 10, '82667^ResetCompleted', 'us_english', 923

-- (ChewKP01) 
execute rdt.rdtAddMsg 82668, 10, '82668^LabelNotExist', 'us_english', 923
execute rdt.rdtAddMsg 82669, 10, '82669^ResetFail', 'us_english', 923
execute rdt.rdtAddMsg 82670, 10, '82670^ResetFail', 'us_english', 923
execute rdt.rdtAddMsg 82671, 10, '82671^ResetFail', 'us_english', 923
execute rdt.rdtAddMsg 82672, 10, '82672^ResetCompleted', 'us_english', 923
execute rdt.rdtAddMsg 82673, 10, '82673^ResetCompleted', 'us_english', 923
execute rdt.rdtAddMsg 82674, 10, '82674^ResetCompleted', 'us_english', 923
