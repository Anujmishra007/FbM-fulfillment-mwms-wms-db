--rdt_LottableProcess_AESOPValidateLottable
execute rdt.rdtDropMsg 200301 , 200350	

execute rdt.rdtAddMsg 200301, 10, '200301 Need Lot01   ',   'us_english', 600
execute rdt.rdtAddMsg 200302, 10, '200302Data Not Found',   'us_english', 600
execute rdt.rdtAddMsg 200303, 10, '200303PalletMixLot01',   'us_english', 600
execute rdt.rdtAddMsg 200304, 10, '200304 Lot01 OverRcv',   'us_english', 600

SELECT TOP 100 * FROM rdt.rdtmsg (NOLOCK) WHERE message_id BETWEEN 200301 AND 200350