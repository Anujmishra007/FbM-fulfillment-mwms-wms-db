--262101 - 262150
-- rdt_838ExtSNVal05
execute rdt.rdtDropMsg 262101, 262150

execute rdt.rdtAddMsg 262101  ,10   ,'262101^PickDetailNotFound','us_english'  ,838  ,0 ,'262101 - Picking detail not found'
execute rdt.rdtAddMsg 262102  ,10   ,'262102^SN not exists'     ,'us_english'  ,838  ,0 ,'262102 - Serial number does not exist'
execute rdt.rdtAddMsg 262103  ,10   ,'262103^Multi SN found'    ,'us_english'  ,838  ,0 ,'262103 - Multiple serial number records found'
execute rdt.rdtAddMsg 262104  ,10   ,'262104^SN not received'   ,'us_english'  ,838  ,0 ,'262104 - Serial number not yet received'
execute rdt.rdtAddMsg 262105  ,10   ,'262105^SN picked'         ,'us_english'  ,838  ,0 ,'262105 - Serial number already picked'
execute rdt.rdtAddMsg 262106  ,10   ,'262106^SN packed'         ,'us_english'  ,838  ,0 ,'262106 - Serial number already packed'
execute rdt.rdtAddMsg 262107  ,10   ,'262107^SN shipped'        ,'us_english'  ,838  ,0 ,'262107 - Serial number already shipped'
execute rdt.rdtAddMsg 262108  ,10   ,'262108^SN on hold'        ,'us_english'  ,838  ,0 ,'262108 - Serial number is on hold'
execute rdt.rdtAddMsg 262109  ,10   ,'262109^Invalid Status'    ,'us_english'  ,838  ,0 ,'262109 - Serial number has invalid status'
execute rdt.rdtAddMsg 262110  ,10   ,'262110^SN Ext Hold'       ,'us_english'  ,838  ,0 ,'262110 - Serial number held by external system'
execute rdt.rdtAddMsg 262111  ,10   ,'262111^SN scanned'        ,'us_english'  ,838  ,0 ,'262111 - Serial number already scanned'
execute rdt.rdtAddMsg 262112  ,10   ,'262112^SN ID mismatch'    ,'us_english'  ,838  ,0 ,'262112 - Serial number does not match Pick Detail'

SELECT * FROM RDT.RDTMSG WITH(NOLOCK) WHERE Message_ID BETWEEN 262101 AND 262150



