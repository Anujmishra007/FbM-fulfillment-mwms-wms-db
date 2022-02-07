-- rdt_PTLCart_Assign_OrderPosTote
execute rdt.rdtDropMsg 54051, 54100

execute rdt.rdtAddMsg 54051, 10, '54051^Need OrderKey ', 'us_english', 808
execute rdt.rdtAddMsg 54052, 10, '54052^Bad OrderKey  ', 'us_english', 808
execute rdt.rdtAddMsg 54053, 10, '54053^Diff storer   ', 'us_english', 808
execute rdt.rdtAddMsg 54054, 10, '54054^Diff facility ', 'us_english', 808
execute rdt.rdtAddMsg 54055, 10, '54055^Order CANCEL  ', 'us_english', 808
execute rdt.rdtAddMsg 54056, 10, '54056^Order NotAlloc', 'us_english', 808
execute rdt.rdtAddMsg 54057, 10, '54057^Order picked  ', 'us_english', 808
execute rdt.rdtAddMsg 54058, 10, '54058^OrderAssigned ', 'us_english', 808
execute rdt.rdtAddMsg 54059, 10, '54059^Order no task ', 'us_english', 808
execute rdt.rdtAddMsg 54060, 10, '54060^Need Position ', 'us_english', 808
execute rdt.rdtAddMsg 54061, 10, '54061^Bad Position  ', 'us_english', 808
execute rdt.rdtAddMsg 54062, 10, '54062^Pos assigned  ', 'us_english', 808
execute rdt.rdtAddMsg 54063, 10, '54063^Need ToteID   ', 'us_english', 808
execute rdt.rdtAddMsg 54064, 10, '54064^Tote Assigned ', 'us_english', 808
execute rdt.rdtAddMsg 54065, 10, '54065^INS Log Fail  ', 'us_english', 808
execute rdt.rdtAddMsg 54066, 10, '54066^INS PTL Fail  ', 'us_english', 808

--WMS16448
execute rdt.rdtAddMsg 54067, 10, '54067^Tote Assigned', 'us_english', 808
