-- nspItrnAddWithdrawalCheck (range 61911 - 61950)
-- execute rdt.rdtDropMsg 61911, 61950
-- select * from rdt.rdtMsg (nolock) where message_id between 61911 and 61950  
  
execute rdt.rdtAddMsg 61911, 10, '61911 Storerkey is blank or null - not allowed! (nspItrnAddWithdrawalCheck)', 'us_english'
execute rdt.rdtAddMsg 61912, 10, '61912 Insert Trigger On ITRN Failed Because An Attempt To Update StorerKey Failed. (nspItrnAddWithdrawalCheck)', 'us_english'
execute rdt.rdtAddMsg 61913, 10, '61913 Update To Table ITRN Returned Zero Rows Affected. (nspItrnAddWithdrawalCheck)', 'us_english'
execute rdt.rdtAddMsg 61914, 10, '61914 Storerkey is blank or null - not allowed! (nspItrnAddWithdrawalCheck)', 'us_english'
execute rdt.rdtAddMsg 61915, 10, '61915 Insert Trigger On ITRN Failed Because An Attempt To Update SKU Failed. (nspItrnAddWithdrawalCheck)', 'us_english'
execute rdt.rdtAddMsg 61916, 10, '61916 Update To Table ITRN Returned Zero Rows Affected. (nspItrnAddWithdrawalCheck)', 'us_english'
execute rdt.rdtAddMsg 61917, 10, '61917 Default SKU Is Not Allowed And SKU Passed Is Blank! (nspItrnAddWithdrawalCheck)', 'us_english'
execute rdt.rdtAddMsg 61918, 10, '61918 Lot Number Does Not Exist In The LOTATTRIBUTE Table! (nspItrnAddWithdrawalCheck)', 'us_english'
execute rdt.rdtAddMsg 61919, 10, '61919 Lot Number Is Not Unique Or Does Not Exist In The LOTATTRIBUTE Table! (nspItrnAddWithdrawalCheck)', 'us_english'
execute rdt.rdtAddMsg 61920, 10, '61920 Lot Number and SKU Passed Do Not Match The Definition In The LOTATTRIBUTE Table! (nspItrnAddWithdrawalCheck)', 'us_english'
execute rdt.rdtAddMsg 61921, 10, '61921 Update Failed On Table LOT. (nspItrnAddWithdrawalCheck)', 'us_english'
execute rdt.rdtAddMsg 61922, 10, '61922 Update To Table LOT Returned Zero Rows Affected. (nspItrnAddWithdrawalCheck)', 'us_english'
execute rdt.rdtAddMsg 61923, 10, '61923 Lot Table Did Not Return Expected Unique Row In Response To Query. (nspItrnAddWithdrawalCheck)', 'us_english'
execute rdt.rdtAddMsg 61924, 10, '61924 Update Failed On Table ID. (nspItrnAddWithdrawalCheck)', 'us_english'
execute rdt.rdtAddMsg 61925, 10, '61925 Update To Table ID Returned Zero Rows Affected. (nspItrnAddWithdrawalCheck)', 'us_english'
execute rdt.rdtAddMsg 61926, 10, '61926 ID Table Did Not Return Expected Unique Row In Response To Query.(nspItrnAddWithdrawalCheck)', 'us_english'
execute rdt.rdtAddMsg 61927, 10, '61927 Update To Table ID Returned Zero Rows Affected. (nspItrnAddWithdrawalCheck)', 'us_english'
execute rdt.rdtAddMsg 61928, 10, '61928 Update Failed On Table SKUxLOC. (nspItrnAddWithdrawalCheck)', 'us_english'
execute rdt.rdtAddMsg 61929, 10, '61929 Update To Table SKUxLOC Returned Zero Rows Affected. (nspItrnAddWithdrawalCheck)', 'us_english'
execute rdt.rdtAddMsg 61930, 10, '61930 SKUxLOC Table Did Not Return Expected Unique Row In Response To Query. (nspItrnAddWithdrawalCheck)', 'us_english'
execute rdt.rdtAddMsg 61931, 10, '61931 Update Failed On Table LOTxLOCxID. (nspItrnAddWithdrawalCheck)', 'us_english'
execute rdt.rdtAddMsg 61932, 10, '61932 Update To Table LOTxLOCxID Returned Zero Rows Affected. (nspItrnAddWithdrawalCheck)', 'us_english'
execute rdt.rdtAddMsg 61933, 10, '61933 LOTxLOCxID Table Did Not Return Expected Unique Row In Response To Query. (nspItrnAddWithdrawalCheck)', 'us_english'
execute rdt.rdtAddMsg 61934, 10, '61934 Update Failed On Table LOT.(nspItrnAddWithdrawalCheck)', 'us_english'


