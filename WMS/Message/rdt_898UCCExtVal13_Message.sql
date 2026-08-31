--rdt_898UCCExtVal13 - 267501 - 267550
-- FCR-11903 Columbia Malaysia (CFS) UCC Receiving
execute rdt.rdtdropmsg 267501, 267550

execute rdt.rdtAddMsg 267501, 10, '267501^UCC Exists!',     'us_english', 898
execute rdt.rdtAddMsg 267502, 10, '267502^UCC Not Found',   'us_english', 898

select * from rdt.rdtmsg (nolock) where message_id between 267501 AND 267550	
