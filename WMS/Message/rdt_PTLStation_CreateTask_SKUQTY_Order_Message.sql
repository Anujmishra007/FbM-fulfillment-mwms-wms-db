-- rdt_PTLStation_CreateTask_SKUQTY_Order
execute rdt.rdtDropMsg 193851, 193900

execute rdt.rdtAddMsg 193851, 10, 'SKU LOCKED BY:      ', 'us_english', 805
execute rdt.rdtAddMsg 193852, 10, '193852No task       ', 'us_english', 805
execute rdt.rdtAddMsg 193853, 10, '193853Over pick     ', 'us_english', 805
execute rdt.rdtAddMsg 193854, 10, '193854DELPTLTranFail', 'us_english', 805
execute rdt.rdtAddMsg 193855, 10, '193855INSPTLTranFail', 'us_english', 805
