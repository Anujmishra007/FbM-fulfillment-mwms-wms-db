--rdtfnc_Close_PTS_Tote
--execute rdt.rdtdropmsg 70566, 70590
--execute rdt.rdtdropmsg 91751 - 91800

execute rdt.rdtAddMsg '70566', 10, '70566^Tote No req', 'us_english'
execute rdt.rdtAddMsg '70567', 10, '70567^Sort Tote 1st', 'us_english'
execute rdt.rdtAddMsg '70568', 10, '70568^Option req', 'us_english'
execute rdt.rdtAddMsg '70569', 10, '70569^Invalid Option', 'us_english'
execute rdt.rdtAddMsg '70570', 10, '70570^NoLabelPrinter', 'us_english'
execute rdt.rdtAddMsg '70571', 10, '70571^DWNOTSetup', 'us_english'
execute rdt.rdtAddMsg '70572', 10, '70572^TgetDBNotSet', 'us_english'
execute rdt.rdtAddMsg '70573', 10, '70573^InsertPRTFail', 'us_english'
execute rdt.rdtAddMsg '70574', 10, '70574^NoPaperPrinter', 'us_english'
execute rdt.rdtAddMsg '70575', 10, '70575^DWNOTSetup', 'us_english'
execute rdt.rdtAddMsg '70576', 10, '70576^TgetDBNotSet', 'us_english'
execute rdt.rdtAddMsg '70577', 10, '70577^InsertPRTFail', 'us_english'
execute rdt.rdtAddMsg '70578', 10, '70578^DO PTS 2 CLOSE', 'us_english'
execute rdt.rdtAddMsg '70579', 10, '70579^NoPaperPrinter', 'us_english'
execute rdt.rdtAddMsg '70580', 10, '70580^DWNOTSetup', 'us_english'
execute rdt.rdtAddMsg '70581', 10, '70581^TgetDBNotSet', 'us_english'
execute rdt.rdtAddMsg '70582', 10, '70582^InsertPRTFail', 'us_english'
execute rdt.rdtAddMsg '70583', 10, '70583^CLOSE TOTE 1ST', 'us_english'
execute rdt.rdtAddMsg '70584', 10, '70584^UpdDropIdFailed', 'us_english'
execute rdt.rdtAddMsg '70585', 10, '70585^LabelPrinted', 'us_english'
execute rdt.rdtAddMsg '70586', 10, '70586^UpdDropIdFailed', 'us_english'
execute rdt.rdtAddMsg '70587', 10, '70587^DWNOTSetup', 'us_english'
execute rdt.rdtAddMsg '70588', 10, '70588^TgetDBNotSet', 'us_english'
execute rdt.rdtAddMsg '70589', 10, '70589^InsertPRTFail', 'us_english'
execute rdt.rdtAddMsg '70590', 10, '70590^ToteNoReq', 'us_english'


execute rdt.rdtAddMsg '91751', 10, '91751^ToteNoReq', 'us_english'
execute rdt.rdtAddMsg '91752', 10, '91752^NewToteOpen', 'us_english'

select * from rdt.rdtmsg (nolock) where message_id between 70566 and 70590
