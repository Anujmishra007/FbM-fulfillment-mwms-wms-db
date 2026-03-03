-- rdt_1730ExtUpd01
-- FCR-10345
EXECUTE rdt.rdtdropmsg 258651, 258700

EXECUTE rdt.rdtAddMsg 258651, 10, '258651 Update InventoryQCDetail Failed',               'us_english', 1730
EXECUTE rdt.rdtAddMsg 258652, 10, '258652 Exec ispFinalizeIQC Failed',                    'us_english', 1730
EXECUTE rdt.rdtAddMsg 258653, 10, '258653 Exec isp_IQC_ExtendedValidation Failed',        'us_english', 1730
EXECUTE rdt.rdtAddMsg 258654, 10, '258654 Update InventoryQCDetail Failed',               'us_english', 1730
EXECUTE rdt.rdtAddMsg 258655, 10, '258655 Update InventoryQC Failed',                     'us_english', 1730
EXECUTE rdt.rdtAddMsg 258656, 10, '258656 Update ispPostFinalizeIQCWrapper Failed',                     'us_english', 1730

SELECT * FROM  rdt.rdtMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 258651 AND 258700