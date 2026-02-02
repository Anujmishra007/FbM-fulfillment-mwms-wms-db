-- FCR-5535
--rdt_GETSKU_HILLSHK
execute rdt.rdtdropmsg 243951, 244000

execute rdt.rdtAddMsg 243951, 10, '243951Bad Sku       ', 'us_english', 0
execute rdt.rdtAddMsg 243952, 10, '243952Bad Sku       ', 'us_english', 0

SELECT  * FROM rdt.rdtMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 243951 AND 244000