-- rdt_1764ExtUpd18
exec rdt.rdtdropmsg 201451, 201500

execute rdt.rdtAddMsg 201451, 10, '201451FoundExtraUCC ', 'us_english', 1764
execute rdt.rdtAddMsg 201452, 10, '201452UPD PKDtl Fail', 'us_english', 1764
execute rdt.rdtAddMsg 201453, 10, '201453UpdTaskdetFail', 'us_english', 1764
execute rdt.rdtAddMsg 201454, 10, '201454Need DropID   ', 'us_english', 1764
execute rdt.rdtAddMsg 201455, 10, '201455UpdTaskdetFail', 'us_english', 1764
execute rdt.rdtAddMsg 201456, 10, '201456UPD Order Fail', 'us_english', 1764
execute rdt.rdtAddMsg 201457, 10, '201457Scan-in Fail  ', 'us_english', 1764
execute rdt.rdtAddMsg 201458, 10, '201458INS DropIDFail', 'us_english', 1764
execute rdt.rdtAddMsg 201459, 10, '201459INS DID Fail  ', 'us_english', 1764
execute rdt.rdtAddMsg 201460, 10, '201460nspg_getkey   ', 'us_english', 1764
execute rdt.rdtAddMsg 201461, 10, '201461InsTaskDetFail', 'us_english', 1764
execute rdt.rdtAddMsg 201462, 10, '201462nspg_getkey   ', 'us_english', 1764
execute rdt.rdtAddMsg 201463, 10, '201463InsTaskDetFail', 'us_english', 1764
execute rdt.rdtAddMsg 201464, 10, '201464AGV API Error ', 'us_english', 1764
execute rdt.rdtAddMsg 201465, 10, '201465AGV API Error ', 'us_english', 1764
execute rdt.rdtAddMsg 201466, 10, '201466UPDTaskDtlFail', 'us_english', 1764
execute rdt.rdtAddMsg 201467, 10, '201467UPD PKDtl Fail', 'us_english', 1764

select * from rdt.rdtmsg (nolock) where message_id between 201451 and 201500
