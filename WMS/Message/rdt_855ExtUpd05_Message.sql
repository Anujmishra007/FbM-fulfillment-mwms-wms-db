--rdt_855ExtUpd01
exec rdt.rdtDropMsg 106751 , 106800

execute rdt.rdtAddMsg 106751, 10, '06751^No PickSlip No',   'us_english', 855
execute rdt.rdtAddMsg 106752, 10, '06752^InsPackHdrFail',   'us_english', 855
execute rdt.rdtAddMsg 106753, 10, '06753^InsPKInfoFail',    'us_english', 855
execute rdt.rdtAddMsg 106754, 10, '06754^Sku Not Exists',   'us_english', 855
execute rdt.rdtAddMsg 106755, 10, '06755^UpdPackDtlFail',   'us_english', 855
execute rdt.rdtAddMsg 106756, 10, '06756^InsPackDtlFail',   'us_english', 855
execute rdt.rdtAddMsg 106757, 10, '06757^UpdPackDtlFail',   'us_english', 855
execute rdt.rdtAddMsg 106758, 10, '06758^UpdPackDtlFail',   'us_english', 855
execute rdt.rdtAddMsg 106759, 10, '06759^UpdPackDtlFail',   'us_english', 855
execute rdt.rdtAddMsg 106760, 10, '06760^OffSetPack Err',   'us_english', 855
execute rdt.rdtAddMsg 106761, 10, '06761^InsDropIDFail',    'us_english', 855
execute rdt.rdtAddMsg 106762, 10, '06762^UPD DropIDFail',   'us_english', 855
execute rdt.rdtAddMsg 106763, 10, '06763^PackCfm Fail',     'us_english', 855
execute rdt.rdtAddMsg 106764, 10, '06764^PackLstPrinted',   'us_english', 855
execute rdt.rdtAddMsg 106765, 10, '06765^UPD DropIDFail',   'us_english', 855

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 106751 AND 106800



