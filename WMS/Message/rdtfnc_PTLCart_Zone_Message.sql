--rdtfnc_PTLCart_Zone
execute rdt.rdtdropmsg 102801 , 102850

execute rdt.rdtAddMsg '102801', 10, '02801^Need CartID',    'us_english', 819
execute rdt.rdtAddMsg '102802', 10, '02802^Invalid CartID', 'us_english', 819
execute rdt.rdtAddMsg '102803', 10, '02803^Cart In Use',    'us_english', 819
execute rdt.rdtAddMsg '102804', 10, '02804^Setup Capacity', 'us_english', 819
execute rdt.rdtAddMsg '102805', 10, '02805^Need PickZone',  'us_english', 819
execute rdt.rdtAddMsg '102806', 10, '02806^Setup PKZone',   'us_english', 819
execute rdt.rdtAddMsg '102807', 10, '02807^Invalid PKZone', 'us_english', 819
execute rdt.rdtAddMsg '102808', 10, '02808^SetupMethodSP',  'us_english', 819
execute rdt.rdtAddMsg '102809', 10, '02809^Bad Method SP',  'us_english', 819
execute rdt.rdtAddMsg '102810', 10, '02810^Bad pick seq',   'us_english', 819
execute rdt.rdtAddMsg '102811', 10, '02811^GetKey Fail',    'us_english', 819
execute rdt.rdtAddMsg '102812', 10, '02812^LOC required',   'us_english', 819
execute rdt.rdtAddMsg '102813', 10, '02813^LOC Not Match',  'us_english', 819
execute rdt.rdtAddMsg '102814', 10, '02814^SKU required',   'us_english', 819
execute rdt.rdtAddMsg '102815', 10, '02815^SKU Not Match',  'us_english', 819
execute rdt.rdtAddMsg '102816', 10, '02816^Invalid SKU',    'us_english', 819
execute rdt.rdtAddMsg '102817', 10, '02817^Invalid SKU',    'us_english', 819
execute rdt.rdtAddMsg '102818', 10, '02818^Tote Req',       'us_english', 819
execute rdt.rdtAddMsg '102819', 10, '02819^Tote Not Match', 'us_english', 819
execute rdt.rdtAddMsg '102820', 10, '02820^Invalid Format', 'us_english', 819
execute rdt.rdtAddMsg '102821', 10, '02821^Invalid Option', 'us_english', 819
execute rdt.rdtAddMsg '102822', 10, '02822^Invalid Option', 'us_english', 819
execute rdt.rdtAddMsg '102823', 10, '02823^New Tote req',   'us_english', 819
execute rdt.rdtAddMsg '102824', 10, '02824^Invalid Format', 'us_english', 819
execute rdt.rdtAddMsg '102825', 10, '02825^Existing Tote',  'us_english', 819
execute rdt.rdtAddMsg '102826', 10, '02826^UpdWCSFailed',   'us_english', 819
execute rdt.rdtAddMsg '102827', 10, '02827^Pick NotFinish', 'us_english', 819
execute rdt.rdtAddMsg '102828', 10, '02828^Bad Reason',     'us_english', 819
execute rdt.rdtAddMsg '102829', 10, '02829^Bad Reason',     'us_english', 819
execute rdt.rdtAddMsg '102830', 10, '02830^Ins Alert Fail', 'us_english', 819


select * from rdt.rdtmsg (nolock) where message_id between 102801 and 102850
