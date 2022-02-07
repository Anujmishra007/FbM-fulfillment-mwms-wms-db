--ispCCDetailUpd_CN01
execute rdt.rdtdropmsg 82051 , 82100

--GO
DECLARE @nFunc INT

SET @nFunc = 732

execute rdt.rdtAddMsg '82051', 10, '82051^UpdCCDetailFail', 'us_english',@nFunc
execute rdt.rdtAddMsg '82052', 10, '82052^UpdCCDetailFail', 'us_english',@nFunc
execute rdt.rdtAddMsg '82053', 10, '82053^UpdCCDetailFail', 'us_english',@nFunc
execute rdt.rdtAddMsg '82054', 10, '82054^UpdCCDetailFail', 'us_english',@nFunc
execute rdt.rdtAddMsg '82055', 10, '82055^GetKeyFail', 'us_english',@nFunc
execute rdt.rdtAddMsg '82056', 10, '82056^GetCCSheetNoFail', 'us_english',@nFunc
execute rdt.rdtAddMsg '82057', 10, '82057^InsertCCFail', 'us_english',@nFunc
execute rdt.rdtAddMsg '82058', 10, '82058^InsertCCFail', 'us_english',@nFunc
execute rdt.rdtAddMsg '82059', 10, '82059^InsertCCFail', 'us_english',@nFunc
execute rdt.rdtAddMsg '82060', 10, '82060^UpdCCDetailFail', 'us_english',@nFunc

select * from rdt.rdtmsg (nolock) where message_id between 82051 and 82100
