
--rdt_727Inquiry03

exec rdt.rdtDropMsg 121801 - 121850
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 727

execute rdt.rdtAddMsg 121801 ,10, '21801^ReceiptKeyReq', 'us_english',@nFunc
execute rdt.rdtAddMsg 121802 ,10, '21802^InvalidReceiptKey', 'us_english',@nFunc
execute rdt.rdtAddMsg 121803 ,10, '21803^SKUReq', 'us_english',@nFunc
execute rdt.rdtAddMsg 121804 ,10, '21804^InvalidSKU', 'us_english',@nFunc
execute rdt.rdtAddMsg 121805 ,10, '21805^MultiBarcode', 'us_english',@nFunc
execute rdt.rdtAddMsg 121806 ,10, '21806^SKUNotInASN', 'us_english',@nFunc





