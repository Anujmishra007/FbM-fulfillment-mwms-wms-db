-- rdtfnc_UCCInfo, 98151 - 98200
--execute rdt.rdtdropmsg 98151 - 98200


GO
DECLARE @nFunc INT

SET @nFunc = 726

execute rdt.rdtAddMsg 98151, 10, '98151^UCCReq',     'us_english',@nFunc
execute rdt.rdtAddMsg 98152, 10, '98152^InvalidUCC',     'us_english',@nFunc
execute rdt.rdtAddMsg 98153, 10, '98153^RefNoReq',     'us_english',@nFunc
execute rdt.rdtAddMsg 98154, 10, '98154^InvalidRefNo',     'us_english',@nFunc
execute rdt.rdtAddMsg 98155, 10, '98155^InvalidSetup',     'us_english',@nFunc
execute rdt.rdtAddMsg 98156, 10, '98156^InvalidSetup',     'us_english',@nFunc
