-- 273151 - 273200

execute rdt.rdtDropMsg 273151 , 273200	

execute rdt.rdtAddMsg 273151, 10, '273151 ID Not In ASN',                           'us_english', 600
execute rdt.rdtAddMsg 273152, 10, '273152 ID in USE',                               'us_english', 600
execute rdt.rdtAddMsg 273153, 10, '273153 Customs status wrong',                    'us_english', 600
execute rdt.rdtAddMsg 273154, 10, '273154 Customs document number missing',         'us_english', 600
execute rdt.rdtAddMsg 273155, 10, '273155 Container Number Missing',                'us_english', 600
execute rdt.rdtAddMsg 273156, 10, '273156 Temperature Range Missing',               'us_english', 600
execute rdt.rdtAddMsg 273157, 10, '273157 COO or HS Code is missing for T1-TEMP',   'us_english', 600
execute rdt.rdtAddMsg 273158, 10, '273158 Condition Code is Not Correct',           'us_english', 600
execute rdt.rdtAddMsg 273159, 10, '273159 Over Receiving Not Allowed',              'us_english', 600

SELECT TOP 100 * FROM rdt.rdtmsg (NOLOCK) WHERE message_id BETWEEN 273151 and 273200