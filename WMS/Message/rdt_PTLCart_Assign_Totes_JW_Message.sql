--rdt_PTLCart_Assign_Totes_JW
execute rdt.rdtdropmsg 103001 , 103050

execute rdt.rdtAddMsg '103001', 10, '03001^Need ToteID',    'us_english', 819
execute rdt.rdtAddMsg '103002', 10, '03002^Invalid Format', 'us_english', 819
execute rdt.rdtAddMsg '103003', 10, '03003^Tote Assigned',  'us_english', 819
execute rdt.rdtAddMsg '103004', 10, '03004^NoMorePosition', 'us_english', 819
execute rdt.rdtAddMsg '103005', 10, '03005^PutAway Tote',   'us_english', 819
execute rdt.rdtAddMsg '103006', 10, '03006^DPK/PTS Tote',   'us_english', 819
execute rdt.rdtAddMsg '103007', 10, '03007^Tote In Used',   'us_english', 819
execute rdt.rdtAddMsg '103008', 10, '03008^Tote In Used',   'us_english', 819
execute rdt.rdtAddMsg '103009', 10, '03009^No More Orders', 'us_english', 819
execute rdt.rdtAddMsg '103010', 10, '03010^Assign Fail',    'us_english', 819
execute rdt.rdtAddMsg '103011', 10, '03011^Ins PTL Fail',   'us_english', 819
execute rdt.rdtAddMsg '103012', 10, '03012^ResetToteFail',  'us_english', 819
execute rdt.rdtAddMsg '103013', 10, '03013^ResetToteFail',  'us_english', 819
execute rdt.rdtAddMsg '103014', 10, '03014^ResetToteFail',  'us_english', 819
execute rdt.rdtAddMsg '103015', 10, '03015^InsDropIDFail',  'us_english', 819
execute rdt.rdtAddMsg '103016', 10, '03016^Tote In Used',   'us_english', 819
execute rdt.rdtAddMsg '103017', 10, '03017^Canc Task Fail', 'us_english', 819

select * from rdt.rdtmsg (nolock) where message_id between 103001 and 103050

