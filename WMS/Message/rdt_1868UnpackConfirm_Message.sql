-- rdt_1868UnpackConfirm
-- UWP-60041
EXECUTE rdt.rdtDropMsg 272901, 272950

EXECUTE rdt.rdtAddMsg 272901, 10, '272901^UpdPackHeaderFail',        'us_english', 1868, 0, '272901 Fail to update PackHeader to 0'
EXECUTE rdt.rdtAddMsg 272902, 10, '272902^DelSNFail',                'us_english', 1868, 0, '272902 Fail to delete PackSerialNo record'
EXECUTE rdt.rdtAddMsg 272903, 10, '272903^UpdPackDetlFail',          'us_english', 1868, 0, '272903 Fail to reduce PackDetail Qty'
EXECUTE rdt.rdtAddMsg 272904, 10, '272904^DelPackDetlFail',          'us_english', 1868, 0, '272904 Fail to delete PackDetail record'
EXECUTE rdt.rdtAddMsg 272905, 10, '272905^DelPackHeaderFail',        'us_english', 1868, 0, '272905 Fail to delete PackHeader record'
EXECUTE rdt.rdtAddMsg 272906, 10, '272906^UpdSNStatus',              'us_english', 1868, 0, '272906 Fail to update SerialNo''s status to 1'
EXECUTE rdt.rdtAddMsg 272907, 10, '272907^UpdPackHeaderFail',        'us_english', 1868, 0, '272907 Fail to update PackHeader TTLCNTS'

SELECT * FROM rdt.rdtmsg WITH(NOLOCK) WHERE Message_ID BETWEEN 272901 AND 272950	

