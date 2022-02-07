--rdtfnc_Close_Tote
execute rdt.rdtdropmsg 112101 , 112150
GO
DECLARE @nFunc INT

SET @nFunc = 1036

execute rdt.rdtAddMsg 112101, 10, '12101^CloseToteReq',    'us_english',@nFunc
execute rdt.rdtAddMsg 112102, 10, '12102^OptionReq',    'us_english',@nFunc
execute rdt.rdtAddMsg 112103, 10, '12103^InvalidOption',    'us_english',@nFunc
