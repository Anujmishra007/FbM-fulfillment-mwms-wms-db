--rdt_1837ExtUpd01
rdt.rdtDropMsg 150801 , 150850

execute rdt.rdtAddMsg 150801, 10, '50801^No PickSlipNo',    'us_english', 1837
execute rdt.rdtAddMsg 150802, 10, '50802^PackCfm Failed',   'us_english', 1837

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 150801 AND 150850