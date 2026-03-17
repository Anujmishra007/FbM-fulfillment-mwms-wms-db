--rdt_1795ExtUpd01
--UWP-52220
EXECUTE rdt.rdtDropMsg 260501, 260550

EXECUTE rdt.rdtAddMsg 260501, 10, '260501 CloseAlertErr',         'us_english', 1795, 0, '260501 Close alert failed'

SELECT * FROM RDT.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 260501 AND 260550