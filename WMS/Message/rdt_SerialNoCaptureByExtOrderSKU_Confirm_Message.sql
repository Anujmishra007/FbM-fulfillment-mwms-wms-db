-- rdt_SerialNoCaptureByExtOrderSKU_Confirm
execute rdt.rdtDropMsg 209651, 209700

execute rdt.rdtAddMsg 209651, 10, '209651UPD SNO fail  ',   'us_english', 878
execute rdt.rdtAddMsg 209652, 10, '209652Get key fail  ',   'us_english', 878
execute rdt.rdtAddMsg 209653, 10, '209653INS SNO fail  ',   'us_english', 878
