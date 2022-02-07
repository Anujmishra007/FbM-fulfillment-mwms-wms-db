--rdt_593Print10
execute rdt.rdtdropmsg 105101 , 105150

execute rdt.rdtAddMsg '105101', 10, '05101^CARTON NO REQ',  'us_english', 593
execute rdt.rdtAddMsg '105102', 10, '05102^INV CARTON NO',  'us_english', 593
execute rdt.rdtAddMsg '105103', 10, '05103^LabelPrnterReq', 'us_english', 593
execute rdt.rdtAddMsg '105104', 10, '05104^DWNOTSetup',     'us_english', 593
execute rdt.rdtAddMsg '105105', 10, '05105^TgetDB Not Set', 'us_english', 593

select * from rdt.rdtmsg (nolock) where message_id between 105101 and 105150

