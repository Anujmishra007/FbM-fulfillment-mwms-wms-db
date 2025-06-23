--rdtfnc_Inbound_PalletTempCapture
--FCR-1398
EXECUTE rdt.rdtdropmsg 230451 , 230500

EXECUTE rdt.rdtAddMsg 230451, 10, '230451UpdTmpLogFail',             'us_english', 1869
EXECUTE rdt.rdtAddMsg 230452, 10, '230452GetKeyFail',                'us_english', 1869
EXECUTE rdt.rdtAddMsg 230453, 10, '230453AddTmpLogFail',             'us_english', 1869

SELECT * FROM rdt.RdtMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 230451 AND 230500