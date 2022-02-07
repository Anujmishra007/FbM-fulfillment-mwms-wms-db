-- rdt_PTLCart_Assign_PickslipPosTote_Lottable
execute rdt.rdtDropMsg 121151, 121200

execute rdt.rdtAddMsg 121151, 10, '121151^NeedPickSlipNo ', 'us_english', 808
execute rdt.rdtAddMsg 121152, 10, '121152^PS NoPickTask  ', 'us_english', 808
execute rdt.rdtAddMsg 121153, 10, '121153^Need Position  ', 'us_english', 808
execute rdt.rdtAddMsg 121154, 10, '121154^Bad Position   ', 'us_english', 808
execute rdt.rdtAddMsg 121155, 10, '121155^Pos assigned   ', 'us_english', 808
execute rdt.rdtAddMsg 121156, 10, '121156^Need ToteID    ', 'us_english', 808
execute rdt.rdtAddMsg 121157, 10, '121157^Tote Assigned  ', 'us_english', 808
execute rdt.rdtAddMsg 121158, 10, '121158^INS Log Fail   ', 'us_english', 808
execute rdt.rdtAddMsg 121159, 10, '121159^INS PTL Fail   ', 'us_english', 808
execute rdt.rdtAddMsg 121160, 10, '121160^Bad PickSlipNo ', 'us_english', 808
execute rdt.rdtAddMsg 121161, 10, '121161^PS Assigned    ', 'us_english', 808

--WMS-8585
execute rdt.rdtAddMsg 121162, 10, '121162^Scan In Fail   ', 'us_english', 808
execute rdt.rdtAddMsg 121163, 10, '121163^Pending Replen ', 'us_english', 808

--WMS-10764
execute rdt.rdtAddMsg 121164, 10, '21164^Duplicate Task',   'us_english', 808
