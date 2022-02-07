--rdt_1837ExtUpd02
rdt.rdtDropMsg 178701, 178750

execute rdt.rdtAddMsg 178701, 10, '178701^No PickSlipNo',  'us_english', 1837
execute rdt.rdtAddMsg 178702, 10, '178702^PackCfmFailed',  'us_english', 1837

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 178701 AND 178750