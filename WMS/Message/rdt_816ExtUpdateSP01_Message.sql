
--rdt_816ExtUpdateSP01
-- 88901 - 88950

exec rdt.rdtDropMsg 88901 , 88950
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 816

execute rdt.rdtAddMsg 88901 ,10, '88901^OverPacked', 'us_english',@nFunc
execute rdt.rdtAddMsg 88902 ,10, '88902^UpdPackDetFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 88903 ,10, '88903^InsPackHFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 88904 ,10, '88904^GenLabelFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 88905 ,10, '88905^InsPackDetFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 88906 ,10, '88906^InsDIDDetFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 88907 ,10, '88907^UpdPickDetFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 88908 ,10, '88908^InsPKInfoFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 88909 ,10, '88909^UpdDropIdFail', 'us_english',@nFunc

execute rdt.rdtAddMsg 88910 ,10, '88910^UpdWCSRODetFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 88911 ,10, '88911^UpdWCSROFail', 'us_english',@nFunc
