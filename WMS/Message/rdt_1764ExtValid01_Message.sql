--rdt_1764ExtValid01
rdt.rdtDropMsg 163801 , 163850

execute rdt.rdtAddMsg 163801, 10, '63801^Over Replenish',   'us_english', 1764

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 163801 AND 163850