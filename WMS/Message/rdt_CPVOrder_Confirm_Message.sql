-- rdt_SerialNoCaptureByOrderSKU_Confirm
execute rdt.rdtDropMsg 125051, 125100

execute rdt.rdtAddMsg 125051, 10, '125051Fully scanned ', 'us_english', 879
execute rdt.rdtAddMsg 125052, 10, '125052INS LOG Fail  ', 'us_english', 879