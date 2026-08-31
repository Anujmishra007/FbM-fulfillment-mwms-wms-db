-- rdt_922ExtVal18
-- FCR-11588
-- execute rdt.rdtDropMsg 266201, 266250
exec rdt.rdtDropMsg 266201, 266250

execute rdt.rdtAddMsg 266201, 10, '266201^MustScanOrder',   'us_english', 922, 0, '266201: Must scan Order'
execute rdt.rdtAddMsg 266202, 10, '266202^HasOpenPicking',  'us_english', 922, 0, '266202: Open picking exists'
execute rdt.rdtAddMsg 266203, 10, '266203^OrdShipped',      'us_english', 922, 0, '266203: Order Shipped'

select * from rdt.rdtmsg (nolock) where message_id between 266201 and 266250

