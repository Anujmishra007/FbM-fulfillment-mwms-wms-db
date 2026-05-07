--rdt_573ExtValidSP15
exec rdt.rdtDropMsg 265751, 265800

execute rdt.rdtAddMsg 265751, 10, '265751PAZoneMismatch', 'us_english', 573, 0, '265751: SKUPutawayZoneMismatch'
execute rdt.rdtAddMsg 265752, 10, '265752ConfigRequired', 'us_english', 573, 0, '265752: UCCFromReceivedDetail must be on'

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 265751 AND 265800
