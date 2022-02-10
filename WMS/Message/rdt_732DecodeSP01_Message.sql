--rdt_732DecodeSP01
execute rdt.rdtDropMsg 126651 , 126700

execute rdt.rdtAddMsg 126651, 10, '26651^UCC Scanned B4',   'us_english', 732

select * from rdt.rdtmsg (nolock) where message_id between 126651 and 126700