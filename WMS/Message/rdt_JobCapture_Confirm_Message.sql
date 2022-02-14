-- rdt_JobCapture_Confirm
execute rdt.rdtDropMsg 128551, 128600

execute rdt.rdtAddMsg 128551, 10, '128551StartJob Exist', 'us_english', 705
execute rdt.rdtAddMsg 128552, 10, '128552INS WATLogFail', 'us_english', 705
execute rdt.rdtAddMsg 128553, 10, '128553UPD WATLogFail', 'us_english', 705
execute rdt.rdtAddMsg 128554, 10, '128554StartJob error', 'us_english', 705
execute rdt.rdtAddMsg 128555, 10, '128555Duplicate Data', 'us_english', 705
execute rdt.rdtAddMsg 128556, 10, '128556INS WATLogFail', 'us_english', 705
execute rdt.rdtAddMsg 128557, 10, '128557No start JOB  ', 'us_english', 705
execute rdt.rdtAddMsg 128558, 10, '128558Multi StartJOB', 'us_english', 705
execute rdt.rdtAddMsg 128559, 10, '128559UPD WATLogFail', 'us_english', 705
execute rdt.rdtAddMsg 128560, 10, '128560UPD WATLogFail', 'us_english', 705
