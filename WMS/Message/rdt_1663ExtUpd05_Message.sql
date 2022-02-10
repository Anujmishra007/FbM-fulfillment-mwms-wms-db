--rdt_1663ExtUpd05
exec rdt.rdtdropmsg 150851, 150900

execute rdt.rdtAddMsg 150851, 10, '50851^Gen TLOG3 Fail', 'us_english', 1663
execute rdt.rdtAddMsg 150852, 10, '50852^UPD MBDtl Fail', 'us_english', 1663

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 150851 AND 150900
