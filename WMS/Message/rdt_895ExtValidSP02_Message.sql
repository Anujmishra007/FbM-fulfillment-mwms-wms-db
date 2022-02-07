--rdt_895ExtValidSP02
-- 167151 - 167200

exec rdt.rdtDropMsg 167151, 167200
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 895

execute rdt.rdtAddMsg 167151 ,10, '167151^InvalidUCC   ', 'us_english',@nFunc
execute rdt.rdtAddMsg 167152 ,10, '167152^InvalidSKU   ', 'us_english',@nFunc
execute rdt.rdtAddMsg 167153 ,10, '167153^InvalidUCCQty', 'us_english',@nFunc
execute rdt.rdtAddMsg 167154 ,10, '167154^InvalidUCC   ', 'us_english',@nFunc
EXECUTE rdt.rdtAddMsg 167155 ,10, '167155^UCCScanned   ', 'us_english',@nFunc

SELECT * FROM rdt.rdtMsg (NOLOCK) WHERE message_Id BETWEEN 167151 and 167200