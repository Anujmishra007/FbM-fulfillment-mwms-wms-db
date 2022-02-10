-- rdt_600ExtVal09
execute rdt.rdtDropMsg 162151, 162200

execute rdt.rdtAddMsg 162151, 10, '162151^Non empty PL ',   'us_english', 600
execute rdt.rdtAddMsg 162152, 10, '162152ID in multiLOC',   'us_english', 600
execute rdt.rdtAddMsg 162153, 10, '162153^ID on hold   ',   'us_english', 600 
execute rdt.rdtAddMsg 162154, 10, '162154Mix AC/Ambient',   'us_english', 600
execute rdt.rdtAddMsg 162155, 10, '162155MixBond/Unbond',   'us_english', 600
execute rdt.rdtAddMsg 162156, 10, '162156^Mix Cond Code',   'us_english', 600 
execute rdt.rdtAddMsg 162157, 10, '162157^PalletMixZone',   'us_english', 600
execute rdt.rdtAddMsg 162158, 10, '162158ID over weight',   'us_english', 600
execute rdt.rdtAddMsg 162159, 10, '162159^SKU suspended',   'us_english', 600
execute rdt.rdtAddMsg 162160, 10, '162160^Invalid Qty  ',   'us_english', 600


SELECT TOP 100 * FROM rdt.rdtmsg (NOLOCK) WHERE message_id BETWEEN 162151 and 162200