--rdt_1766ExtScn02
--UWP-46877
EXECUTE rdt.rdtDropMsg 256251 , 256300

EXECUTE rdt.rdtAddMsg 256251, 10, '256251^InsStockTakeSheetParametersFail',       'us_english', 1766, 0, '256251 Insert StockTakeSheetParameters Failed'
EXECUTE rdt.rdtAddMsg 256252, 10, '256252^InsCCDetailFail',       'us_english', 1766, 0, '256252 Insert CCDetail Failed'

SELECT * FROM rdt.rdtmsg WITH(NOLOCK) WHERE message_id BETWEEN 256251 AND 256300
