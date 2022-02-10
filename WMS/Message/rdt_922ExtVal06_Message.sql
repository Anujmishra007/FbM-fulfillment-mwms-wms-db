--rdt_922ExtVal06
execute rdt.rdtdropmsg 56451, 56500

execute rdt.rdtAddMsg '56451', 10, '56451^Diff Shipper  ',  'us_english', 922
execute rdt.rdtAddMsg '56452', 10, '56452^>Order is HOLD',  'us_english', 922
execute rdt.rdtAddMsg '56453', 10, '56453^>Pending UPD',    'us_english', 922
execute rdt.rdtAddMsg '56454', 10, '56454^>Pending CANC',   'us_english', 922
execute rdt.rdtAddMsg '56455', 10, '56455^>Order CANCEL',   'us_english', 922
execute rdt.rdtAddMsg '56456', 10, '56456^>Allow #OfOrds',  'us_english', 922

