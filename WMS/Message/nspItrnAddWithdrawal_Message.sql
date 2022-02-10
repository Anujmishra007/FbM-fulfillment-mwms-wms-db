-- nspItrnAddWithdrawal (range 61901 - 61910)
-- execute rdt.rdtDropMsg 61901, 61910
-- select * from rdt.rdtMsg (nolock) where message_id between 61901 and 61910  
    
execute rdt.rdtAddMsg 61901, 10, '61901 nspg_GetKey ItrnKey (nspItrnAddWithdrawal)', 'us_english'
execute rdt.rdtAddMsg 61902, 10, '61902 Execute nspUOMConv Failed (nspItrnAddWithdrawal)', 'us_english'





