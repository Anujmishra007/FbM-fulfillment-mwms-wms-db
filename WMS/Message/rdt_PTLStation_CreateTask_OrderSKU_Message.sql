-- rdt_PTLStation_CreateTask_OrderSKU
execute rdt.rdtDropMsg 97101, 97150

execute rdt.rdtAddMsg 97101, 10, '97101^AssignCartonID', 'us_english', 805
execute rdt.rdtAddMsg 97102, 10, '97102^INSPTLTranFail', 'us_english', 805
execute rdt.rdtAddMsg 97103, 10, '97103^UPD Log Fail  ', 'us_english', 805
execute rdt.rdtAddMsg 97104, 10, '97104^No Task       ', 'us_english', 805
execute rdt.rdtAddMsg 97105, 10, '97105^PKDtl changed ', 'us_english', 805
