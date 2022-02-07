
--rdt_1804ExtValidSP01
-- 93201 , 93250

exec rdt.rdtDropMsg 93201 , 93250
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 1804

execute rdt.rdtAddMsg 93201 ,10, '93201^InvalidUCCStatus', 'us_english',@nFunc
execute rdt.rdtAddMsg 93202 ,10, '93202^InvalidUCC', 'us_english',@nFunc
execute rdt.rdtAddMsg 93203 ,10, '93203^InvalidFacility', 'us_english',@nFunc
execute rdt.rdtAddMsg 93204 ,10, '93204^UCCExists', 'us_english',@nFunc
