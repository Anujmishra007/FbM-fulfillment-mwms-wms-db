--rdt_593ShipLabel20
--UWP-26275
exec rdt.rdtDropMsg 227851, 227900

execute rdt.rdtAddMsg 227851, 10, '227851 NeedDropID',      'us_english', 593
execute rdt.rdtAddMsg 227852, 10, '227852 InvalidDropID',   'us_english', 593

SELECT * FROM rdt.RdtMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 227851 AND 227900