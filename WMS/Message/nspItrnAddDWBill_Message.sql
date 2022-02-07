-- nspItrnAddDWBill (range 62401 - 62425)
-- execute rdt.rdtDropMsg 62401, 62425
-- select * from rdt.rdtMsg (nolock) where message_id between 62401 and 62425  
  
execute rdt.rdtAddMsg 62401, 10, '62401 There is no TariffKey. (nspItrnAddDWBill)', 'us_english'
execute rdt.rdtAddMsg 62402, 10, '62402 Invalid TariffKey. (nspItrnAddDWBill)', 'us_english'
execute rdt.rdtAddMsg 62403, 10, '62403 Unable to get dates for Calendar Group (nspItrnAddDWBill)', 'us_english'
execute rdt.rdtAddMsg 62404, 10, '62404 Insert into LotxBillDate failed (nspItrnAddDWBill)', 'us_english'
execute rdt.rdtAddMsg 62405, 10, '62405 Declaration of cursor failed (nspItrnAddDWBill)', 'us_english'
execute rdt.rdtAddMsg 62406, 10, '62406 Open of cursor failed (nspItrnAddDWBill)', 'us_english'
execute rdt.rdtAddMsg 62407, 10, '62407 nspg_GetKey AccumulatedCharges (nspItrnAddDWBill) ', 'us_english'
execute rdt.rdtAddMsg 62408, 10, '62408 Insert into AccumulatedCharges failed (nspItrnAddDWBill)', 'us_english'


