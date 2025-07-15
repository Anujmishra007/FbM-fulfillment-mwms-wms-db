-- rdt_838ExtVal31
-- UWP-33515
EXECUTE rdt.rdtDropMsg 237701, 237750

EXECUTE rdt.rdtAddMsg 237701, 10, '237701InvalidSN',        'us_english', 838, 0, '237701 Invalid SerialNo'
EXECUTE rdt.rdtAddMsg 237702, 10, '237702SNAlreadyScanned', 'us_english', 838, 0, '237702 SerialNo was scanned to other PickSlipNo'
EXECUTE rdt.rdtAddMsg 237703, 10, '237703SNAlreadyScanned', 'us_english', 838, 0, '237703 SerialNo was scanned to current PickSlipNo'

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 237701 AND 237750
