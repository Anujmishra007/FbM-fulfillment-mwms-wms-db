-- rdt_SerialNoCaptureByExtOrderSKU_SerialNoValidate
execute rdt.rdtDropMsg 209901, 209950

execute rdt.rdtAddMsg 209901, 10, '209901Invalid format',   'us_english', 878
execute rdt.rdtAddMsg 209902, 10, '209902Invalid SNO   ',   'us_english', 878
execute rdt.rdtAddMsg 209903, 10, '209903Invalid SNO   ',   'us_english', 878
execute rdt.rdtAddMsg 209904, 10, '209904SNO scanned   ',   'us_english', 878

SELECT * FROM rdt.rdtmsg WITH(NOLOCK) WHERE Message_ID BETWEEN 209901 AND 209950