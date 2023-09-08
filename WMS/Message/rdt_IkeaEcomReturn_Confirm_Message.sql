--rdt_IkeaEcomReturn_Confirm
execute rdt.rdtdropmsg 204051 , 204100

execute rdt.rdtAddMsg 204051, 10, 'CODE ERROR          ',   'us_english', 657
execute rdt.rdtAddMsg 204052, 10, '204052 UPD UDF01 ERR',   'us_english', 657
execute rdt.rdtAddMsg 204053, 10, '204053 UPD RCVDT ERR',   'us_english', 657
execute rdt.rdtAddMsg 204054, 10, '204054 ASN NOT FOUND',   'us_english', 657
execute rdt.rdtAddMsg 204055, 10, '204055 UPD RCVDT ERR',   'us_english', 657
execute rdt.rdtAddMsg 204056, 10, '204056 ASN NOT FOUND',   'us_english', 657

SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 204051 AND 204100