exec rdt.rdtDropMsg 219851,220350

execute rdt.rdtAddMsg 219851, 10, '219851 Need BatchNo',          'us_english'
execute rdt.rdtAddMsg 219852, 10, '219852 Invalid Batch#',        'us_english'
execute rdt.rdtAddMsg 219853, 10, '219853 Invalid ID',            'us_english'
execute rdt.rdtAddMsg 219854, 10, '219854 Batch# Allocated',      'us_english'
execute rdt.rdtAddMsg 219855, 10, '219855 Batch# Picked',         'us_english'
execute rdt.rdtAddMsg 219856, 10, '219856 already available',     'us_english'
execute rdt.rdtAddMsg 219857, 10, '219857 Hold Error',            'us_english'
execute rdt.rdtAddMsg 219858, 10, '219858 nspg_GetKey',           'us_english'
execute rdt.rdtAddMsg 219859, 10, '219859 finalize failed',       'us_english'
execute rdt.rdtAddMsg 219860, 10, '219860 Hold Error',            'us_english'
execute rdt.rdtAddMsg 219861, 10, '219861 nspg_GetKey',           'us_english'
execute rdt.rdtAddMsg 219862, 10, '219862 finalize failed',       'us_english'
execute rdt.rdtAddMsg 219863, 10, '219863 already Block',         'us_english'
execute rdt.rdtAddMsg 219864, 10, '219864 Hold Error',            'us_english'
execute rdt.rdtAddMsg 219865, 10, '219865 nspg_GetKey',           'us_english'
execute rdt.rdtAddMsg 219866, 10, '219866 finalize failed',       'us_english'
execute rdt.rdtAddMsg 219867, 10, '219867 Hold Error',            'us_english'
execute rdt.rdtAddMsg 219868, 10, '219868 nspg_GetKey',           'us_english'
execute rdt.rdtAddMsg 219869, 10, '219869 finalize failed',       'us_english'
execute rdt.rdtAddMsg 219870, 10, '219870 already available',     'us_english'
execute rdt.rdtAddMsg 219871, 10, '219871 Hold Error',            'us_english'
execute rdt.rdtAddMsg 219872, 10, '219872 nspg_GetKey',           'us_english'
execute rdt.rdtAddMsg 219873, 10, '219873 finalize failed',       'us_english'
execute rdt.rdtAddMsg 219874, 10, '219874 Hold Error',            'us_english'
execute rdt.rdtAddMsg 219875, 10, '219875 nspg_GetKey',           'us_english'
execute rdt.rdtAddMsg 219876, 10, '219876 finalize failed',       'us_english'
execute rdt.rdtAddMsg 219877, 10, '219877 finalize failed',       'us_english', 593, 0, '219877 finalize failed'

execute rdt.rdtAddMsg 219901, 10, '219901^Need Weight',           'us_english'
execute rdt.rdtAddMsg 219902, 10, '219902^PalletQtyNotSe',        'us_english'
execute rdt.rdtAddMsg 219903, 10, '219903^NoLabelPrinter',        'us_english'
execute rdt.rdtAddMsg 219904, 10, '219904^TgetDB Not Set',        'us_english'
execute rdt.rdtAddMsg 219905, 10, '219905 AutoGenID Fail',        'us_english'

execute rdt.rdtAddMsg 219921, 10, '219921^Invalid lottable',      'us_english', 898, 0, '219921^Invalid lottable'
execute rdt.rdtAddMsg 219926, 10, '219926^InvalidUCC',            'us_english'
execute rdt.rdtAddMsg 219927, 10, '219927^DisallowMixLot',        'us_english', 898, 0, '219927^Disallow Mix Lot'

execute rdt.rdtAddMsg 219931, 10, '219931 ValueNotInList',        'us_english', 598
execute rdt.rdtAddMsg 219932, 10, '219932 ValueNotInList',        'us_english', 598

execute rdt.rdtAddMsg 219951, 10, '219951 UpdatePkdFail',         'us_english', 838
execute rdt.rdtAddMsg 219952, 10, '219952 DelPickFail',           'us_english', 838
execute rdt.rdtAddMsg 219953, 10, '219953 MergePickFail',         'us_english', 838
execute rdt.rdtAddMsg 219954, 10, '219954 OVER PACK',             'us_english', 838
execute rdt.rdtAddMsg 219955, 10, '219955 PalletQtyNotSetup',     'us_english', 600, 0, '219955 Pallet Qty Not Setup'
execute rdt.rdtAddMsg 219956, 10, '219956 Qty>PalletQty',         'us_english', 600
execute rdt.rdtAddMsg 219957, 10, '219957 Multiple SKU',          'us_english', 600
execute rdt.rdtAddMsg 219958, 10, '219958 Multiple Batch',        'us_english', 600 , 0, '219958 Multiple Batch'
execute rdt.rdtAddMsg 219964, 10, '219964 Invalid SKU',           'us_english', 600 , 0, '219964 Invalid SKU, need to UPPER'
execute rdt.rdtAddMsg 219965, 10, '219965 Invalid ID',            'us_english', 600
execute rdt.rdtAddMsg 219966, 10, '219966 Invalid ID',            'us_english', 600 , 0, '219966 Invalid ID Format, need to UPPER'


SELECT * FROM rdt.rdtMsg WHERE Message_ID BETWEEN 219851 AND 220350
