--rdtfnc_CC_ReprintToteLabel
--execute rdt.rdtdropmsg 72141 - 72190

execute rdt.rdtAddMsg '72141', 10, '72141^Tote No req', 'us_english'
execute rdt.rdtAddMsg '72142', 10, '72142^ToteNotExists', 'us_english'
execute rdt.rdtAddMsg '72143', 10, '72143^Option req', 'us_english'
execute rdt.rdtAddMsg '72144', 10, '72144^Invalid Option', 'us_english'
execute rdt.rdtAddMsg '72145', 10, '72145^NoLabelPrinter', 'us_english'
execute rdt.rdtAddMsg '72146', 10, '72146^DWNOTSetup', 'us_english'
execute rdt.rdtAddMsg '72147', 10, '72147^TgetDBNotSet', 'us_english'
execute rdt.rdtAddMsg '72148', 10, '72148^InsertPRTFail', 'us_english'
execute rdt.rdtAddMsg '72149', 10, '72149^NoPaperPrinter', 'us_english'
execute rdt.rdtAddMsg '72150', 10, '72150^DWNOTSetup', 'us_english'
execute rdt.rdtAddMsg '72151', 10, '72151^TgetDBNotSet', 'us_english'
execute rdt.rdtAddMsg '72152', 10, '72152^InsertPRTFail', 'us_english'
execute rdt.rdtAddMsg '72153', 10, '72153^DWNOTSetup', 'us_english'
execute rdt.rdtAddMsg '72154', 10, '72154^TgetDBNotSet', 'us_english'
execute rdt.rdtAddMsg '72155', 10, '72155^InsertPRTFail', 'us_english'
execute rdt.rdtAddMsg '72156', 10, '72156^UpdDropIDFail', 'us_english'
execute rdt.rdtAddMsg '72157', 10, '72157^CloseToteFail', 'us_english'
execute rdt.rdtAddMsg '72158', 10, '72158^NOT C&C TOTE', 'us_english'


select * from rdt.rdtmsg (nolock) where message_id between 72141 and 72190
