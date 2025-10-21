--rdt_Pallet_Swap
execute rdt.rdtdropmsg 53651 , 53700

execute rdt.rdtAddMsg '53651', 10, '53651^GET RFKEY FAIL',     'us_english', 961
execute rdt.rdtAddMsg '53652', 10, '53652^UPD RFKEY FAIL',     'us_english', 961
execute rdt.rdtAddMsg '53653', 10, '53653^ITRNADDMV FAIL',     'us_english', 961
execute rdt.rdtAddMsg '53654', 10, '53654^UPD RFKEY FAIL',     'us_english', 961
execute rdt.rdtAddMsg '53655', 10, '53655^SEND WCS FAIL',      'us_english', 961

--UWP-42702
execute rdt.rdtAddMsg '53656', 10, '53656^Trigger WCS FAIL',   'us_english', 961, 0, '53656 Trigger WCS Message FAIL'

SELECT * FROM rdt.RDTMSG WITH(NOLOCK) WHERE Message_ID BETWEEN 53651 AND 53700