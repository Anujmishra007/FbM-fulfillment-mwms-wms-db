--rdtCarterLabel01
--execute rdt.rdtDropMsg 93751 ,  93800

GO
DECLARE @nFunc INT
SET @nFunc = 593

execute rdt.rdtAddMsg 93751, 10, '93751^LabelPrnterReq',    'us_english', @nFunc
execute rdt.rdtAddMsg 93752, 10, '93752^ReceiptKeyReq',    'us_english', @nFunc
execute rdt.rdtAddMsg 93753, 10, '93753^InvalidReceiptKey',    'us_english', @nFunc
execute rdt.rdtAddMsg 93754, 10, '93754^LineNoReq',    'us_english', @nFunc
execute rdt.rdtAddMsg 93755, 10, '93755^InvalidLineNo',    'us_english', @nFunc
execute rdt.rdtAddMsg 93756, 10, '93756^InvalidQty',    'us_english', @nFunc
execute rdt.rdtAddMsg 93757, 10, '93757^InvalidSKU',    'us_english', @nFunc
execute rdt.rdtAddMsg 93758, 10, '93758^MultiBarCodeSKU',    'us_english', @nFunc
execute rdt.rdtAddMsg 93759, 10, '93759^InvalidQty',    'us_english', @nFunc
execute rdt.rdtAddMsg 93760, 10, '93760^LabelNoReq',    'us_english', @nFunc
execute rdt.rdtAddMsg 93761, 10, '93761^LabelNoReq',    'us_english', @nFunc



