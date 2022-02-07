-- rdt_SerialNoCaptureByOrderSKU_Reset
execute rdt.rdtDropMsg 128301, 128350

execute rdt.rdtAddMsg 128301, 10, '128301DEL LOG Fail  ', 'us_english', 631
execute rdt.rdtAddMsg 128302, 10, '128302DEL PKDtl Fail', 'us_english', 631
execute rdt.rdtAddMsg 128303, 10, '128303DEL LOG Fail  ', 'us_english', 631
execute rdt.rdtAddMsg 128304, 10, '128304UPD LOG Fail  ', 'us_english', 631