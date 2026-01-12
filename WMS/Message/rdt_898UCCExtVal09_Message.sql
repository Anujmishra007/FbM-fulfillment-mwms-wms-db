-- rdt_898UCCExtVal09
--FCR-236
exec rdt.rdtdropmsg 215301 , 215350

execute rdt.rdtAddMsg 215301, 10, '215301^Invalid Svalue', 'us_english', 898
execute rdt.rdtAddMsg 215302, 10, '215302^Invalid Prefix Length', 'us_english', 898
execute rdt.rdtAddMsg 215303, 10, '215303^Setup CodeLkup', 'us_english', 898
execute rdt.rdtAddMsg 215304, 10, '215304^SKU Not Exist', 'us_english', 898
execute rdt.rdtAddMsg 215305, 10, '215305^Cart Need FAI', 'us_english', 898
execute rdt.rdtAddMsg 215306, 10, '215306^Cart Need QC,FAI', 'us_english', 898
execute rdt.rdtAddMsg 215307, 10, '215307^UCC need QC&FAI,Cannot receive ID', 'us_english', 898
execute rdt.rdtAddMsg 215308, 10, '215308^UCC need QC,Cannot receive ID', 'us_english', 898
execute rdt.rdtAddMsg 215309, 10, '215309^UCC need FAI,Cannot receive ID', 'us_english', 898
execute rdt.rdtAddMsg 215310, 10, '215310^Upd UCC Err', 'us_english', 898
execute rdt.rdtAddMsg 215311, 10, '215311^Upd SKU Err', 'us_english', 898
execute rdt.rdtAddMsg 215312, 10, '215312^UCC Not Exist', 'us_english', 898
execute rdt.rdtAddMsg 215313, 10, '215313^PalletClosed',   'us_english', 898, 0, '215313 Pallet Closed' 

select * from rdt.rdtmsg (nolock) where message_id between 215301 AND 215350