--rdt_867ExtValid01
execute rdt.rdtDropMsg 151301, 151350

execute rdt.rdtAddMsg 151301, 10, '51301^JITX ORDERS',   'us_english', 867


SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 151301 AND 151350