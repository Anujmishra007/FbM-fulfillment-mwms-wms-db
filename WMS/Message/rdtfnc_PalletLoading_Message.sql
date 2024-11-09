--rdtfnc_PalletLoading
execute rdt.rdtdropmsg 221251, 221300

execute rdt.rdtAddMsg 221251, 10, '221251^InvalidOption', 'us_english'
execute rdt.rdtAddMsg 221252, 10, '221252^NoOrderScanned', 'us_english'
execute rdt.rdtAddMsg 221253, 10, '221253^Need OrderKey', 'us_english'
execute rdt.rdtAddMsg 221254, 10, '221254^Invalid Order', 'us_english'
execute rdt.rdtAddMsg 221255, 10, '221255^InvOdrStatus', 'us_english'
execute rdt.rdtAddMsg 221256, 10, '221256^NoPalletSKU', 'us_english'
execute rdt.rdtAddMsg 221257, 10, '221257^InvalidAltSKU', 'us_english'
execute rdt.rdtAddMsg 221258, 10, '221258^InvalidQty', 'us_english'
execute rdt.rdtAddMsg 221259, 10, '221259^NeedQty', 'us_english'
execute rdt.rdtAddMsg 221260, 10, '221260^QtyUnavailable', 'us_english'
execute rdt.rdtAddMsg 221261, 10, '221261^TransacFailed', 'us_english'

IF NOT EXISTS (SELECT 1 FROM rdt.RDTMSG where Message_ID=1668)
INSERT INTO rdt.RDTMSG(Message_ID,Lang_Code,Message_Type,Message_Text,StoredProcName,EventType)
VALUES (1668,'ENG','FNC','Pallet Loading','rdtfnc_PalletLoading','9')

