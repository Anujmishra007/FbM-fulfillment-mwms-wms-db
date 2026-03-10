-- FCR-10102 
-- message ids 259351 - 259400

rdt.rdtDropMsg 259351 , 259400

execute rdt.rdtAddMsg 259351, 10, '259351^SKU not in PickSlip', 'us_english', 1868, 0, '259351^SKU not in PickSlip'
execute rdt.rdtAddMsg 259352, 10, '259352^Invalid SKU',         'us_english', 1868, 0, '259352^Invalid SKU'

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 259351 AND 259400