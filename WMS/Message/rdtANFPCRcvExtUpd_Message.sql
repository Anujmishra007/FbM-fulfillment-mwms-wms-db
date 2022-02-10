-- rdtANFPCRcvExtUpd (range 87901 - 87950)

-- delete from rdt.rdtMsg where message_id between 87901 and 87950
-- execute rdt.rdtDropMsg 87901, 87950

-- rdtANFPCRcvExtUpd
execute rdt.rdtAddMsg 87901, 10, '87901^Need ToID',      'us_english'

SELECT * FROM rdt.rdtMsg (NOLOCK) WHERE Message_ID BETWEEN 87901 AND 87950
