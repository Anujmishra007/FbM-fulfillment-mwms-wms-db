-- rdt_646ExtPrint01
rdt.rdtDropMsg 170601,  170650

execute rdt.rdtAddMsg 170601, 10, '170601^NO TASK FOUND',      'us_english', 646
execute rdt.rdtAddMsg 170602, 10, '170602^GetKey Fail  ',      'us_english', 646
execute rdt.rdtAddMsg 170603, 10, '170603^No LoadKey   ',      'us_english', 646
execute rdt.rdtAddMsg 170604, 10, '170604^No PickSlipNo',      'us_english', 646
execute rdt.rdtAddMsg 170605, 10, '170605^UPD Task Fail',      'us_english', 646
execute rdt.rdtAddMsg 170606, 10, '170606^TaskNoLoadKey',      'us_english', 646

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 170601 AND 170650	
