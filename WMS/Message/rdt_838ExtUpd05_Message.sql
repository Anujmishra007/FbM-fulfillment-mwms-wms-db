--rdt_838ExtUpd05
execute rdt.rdtdropmsg 142851, 142900

execute rdt.rdtAddMsg 142851, 10, '42851^Upd RefNo Fail', 'us_english', 838
execute rdt.rdtAddMsg 142852, 10, '42852^Upd RefNo Fail', 'us_english', 838

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE MESSAGE_ID BETWEEN 142851 AND 142900	