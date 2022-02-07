
--rdt_842ExtValidSP01
-- 104201 - 104250

exec rdt.rdtDropMsg 104201 - 104250
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 842

execute rdt.rdtAddMsg 104201 ,10, '04201^Invalid Tote', 'us_english',@nFunc
execute rdt.rdtAddMsg 104202 ,10, '04202^ToteNotPicked', 'us_english',@nFunc
execute rdt.rdtAddMsg 104203 ,10, '04203^ToteCompleted', 'us_english',@nFunc
execute rdt.rdtAddMsg 104204 ,10, '04204^Order Hold!', 'us_english',@nFunc
execute rdt.rdtAddMsg 104205 ,10, '04205^Waiting Cancel!', 'us_english',@nFunc
execute rdt.rdtAddMsg 104206 ,10, '04206^Order Cancelled', 'us_english',@nFunc
