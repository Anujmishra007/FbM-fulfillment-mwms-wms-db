--rdt_840ExtUpd30
execute rdt.rdtdropmsg 206851 , 206900

execute rdt.rdtAddMsg 206851, 10, '206851 NO TRACK NO  ',   'us_english', 840
execute rdt.rdtAddMsg 206852, 10, '206852 INV TRACK NO ',   'us_english', 840
execute rdt.rdtAddMsg 206853, 10, '206853 Upd Track Err',   'us_english', 840
execute rdt.rdtAddMsg 206854, 10, '206854 InsTL2Log Err',   'us_english', 840
execute rdt.rdtAddMsg 206855, 10, '206855 TCP Socket Er',   'us_english', 840
execute rdt.rdtAddMsg 206856, 10, '206856UPD PACKINF Er',   'us_english', 840
execute rdt.rdtAddMsg 206857, 10, '206857 NO TRACKING #',   'us_english', 840
execute rdt.rdtAddMsg 206858, 10, '206858ASSIGN TRK# Er',   'us_english', 840
execute rdt.rdtAddMsg 206859, 10, '206859 REL TRACK# Err',  'us_english', 840
execute rdt.rdtAddMsg 206860, 10, '206860 UPD Orders Err',  'us_english', 840
execute rdt.rdtAddMsg 206861, 10, '206861 UPD PKDTL Err',   'us_english', 840
execute rdt.rdtAddMsg 206862, 10, '206862 UPD PKDTL Err',   'us_english', 840
execute rdt.rdtAddMsg 206863, 10, '206863UPD PACKINF Er',   'us_english', 840


select * from rdt.rdtmsg (nolock) where message_id between 206851 AND 206900
