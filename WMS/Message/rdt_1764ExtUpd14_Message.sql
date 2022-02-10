-- rdt_1764ExtUpd14
exec rdt.rdtdropmsg 166001, 166050

execute rdt.rdtAddMsg 166001, 10, '166001FoundExtraUCC ', 'us_english', 1764
execute rdt.rdtAddMsg 166002, 10, '166002UPD PKDtl Fail', 'us_english', 1764
execute rdt.rdtAddMsg 166003, 10, '166003UpdTaskdetFail', 'us_english', 1764
execute rdt.rdtAddMsg 166004, 10, '166004Need DropID   ', 'us_english', 1764
execute rdt.rdtAddMsg 166005, 10, '166005UpdTaskdetFail', 'us_english', 1764
execute rdt.rdtAddMsg 166006, 10, '166006UPD Order Fail', 'us_english', 1764
execute rdt.rdtAddMsg 166007, 10, '166007Scan-in Fail  ', 'us_english', 1764
execute rdt.rdtAddMsg 166008, 10, '166008INS DropIDFail', 'us_english', 1764
execute rdt.rdtAddMsg 166009, 10, '166009INS DID Fail  ', 'us_english', 1764
execute rdt.rdtAddMsg 166010, 10, '166010nspg_getkey   ', 'us_english', 1764
execute rdt.rdtAddMsg 166011, 10, '166011InsTaskDetFail', 'us_english', 1764
execute rdt.rdtAddMsg 166012, 10, '166012nspg_getkey   ', 'us_english', 1764
execute rdt.rdtAddMsg 166013, 10, '166013InsTaskDetFail', 'us_english', 1764
execute rdt.rdtAddMsg 166014, 10, '166014AGV API Error ', 'us_english', 1764
execute rdt.rdtAddMsg 166015, 10, '166015AGV API Error ', 'us_english', 1764
execute rdt.rdtAddMsg 166016, 10, '166016UPDTaskDtlFail', 'us_english', 1764
execute rdt.rdtAddMsg 166017, 10, '166017UPD PKDtl Fail', 'us_english', 1764

select * from rdt.rdtmsg (nolock) where message_id between 166001 and 166050
