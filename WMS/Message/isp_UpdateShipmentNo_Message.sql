-- isp_UpdateShipmentNo
exec rdt.rdtDropMsg 75701, 75750

execute rdt.rdtAddMsg 75701, 10, '75701^SPNotExistInDB', 'us_english'
execute rdt.rdtAddMsg 75702, 10, '75702^CustomSP error', 'us_english'

