-- rdt_PTLStation_Confirm_Order
execute rdt.rdtDropMsg 54651, 54700

execute rdt.rdtAddMsg 54651, 10, '54651^SetupConfirmSP', 'us_english', 805
execute rdt.rdtAddMsg 54652, 10, '54652^Bad Confirm SP', 'us_english', 805
