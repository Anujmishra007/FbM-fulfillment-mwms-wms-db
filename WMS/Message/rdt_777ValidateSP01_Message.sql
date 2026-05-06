-- rdtfnc_Pack
-- FCR-9200
execute rdt.rdtDropMsg 251751, 251800

execute rdt.rdtAddMsg 251751, 10, '251751 OrderPacked ',             'us_english', 777, 0, '251751 Order is packed'
execute rdt.rdtAddMsg 251752, 10, '251752 SKU NotIn Order ',         'us_english', 777, 0, '251752 SKU Not In Order or Packed'
execute rdt.rdtAddMsg 251753, 10, '251753 SKU NotIn Wave ',          'us_english', 777, 0, '251753 SKU Not In Wave or Packed'
execute rdt.rdtAddMsg 251754, 10, '251754 Over Pack ',               'us_english', 777, 0, '251754 Over Pack'
execute rdt.rdtAddMsg 251755, 10, '251755 Over Pack ',               'us_english', 777, 0, '251755 Over Pack'
execute rdt.rdtAddMsg 251756, 10, '251756 Order not picked ',        'us_english', 777, 0, '251756 Order is not picked yet'

SELECT * FROM rdt.rdtmsg (NOLOCK) WHERE Message_ID BETWEEN 251751 AND 251800