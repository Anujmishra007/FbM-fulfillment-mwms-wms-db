--rdt_732ExtVal03
execute rdt.rdtdropmsg 140651, 140700

execute rdt.rdtAddMsg 140651, 10, '40651^Opt 2 NotAllow',   'us_english', 732

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE MESSAGE_ID BETWEEN 140651 AND 140700	