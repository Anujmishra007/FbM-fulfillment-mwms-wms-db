-- rdt_JobCapture_Confirm
execute rdt.rdtDropMsg 128551, 128600

execute rdt.rdtAddMsg 128551, 10, '128551INS LOG Fail  ', 'us_english', 705
execute rdt.rdtAddMsg 128552, 10, '128552REC NOT FOUND ', 'us_english', 705
execute rdt.rdtAddMsg 128553, 10, '128553INS LOG Fail  ', 'us_english', 705
execute rdt.rdtAddMsg 128554, 10, '128554INS LOG Fail  ', 'us_english', 705

--WMS-10170
execute rdt.rdtAddMsg 128555, 10, '128555Record Exists ', 'us_english', 705
