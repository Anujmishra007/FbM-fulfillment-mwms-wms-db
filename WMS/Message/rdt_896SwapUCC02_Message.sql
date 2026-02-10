--rdt_896SwapUCC02
-- 235051 - 235100
execute rdt.rdtDropMsg 235051, 235100	

execute rdt.rdtAddMsg 235051, 10, '235051No Replen task',   'us_english', 896, 0, '235051: No Replen task'
execute rdt.rdtAddMsg 235052, 10, '235052UCC QTY Diff',     'us_english', 896, 0, '235052: UCC qty is different'
execute rdt.rdtAddMsg 235053, 10, '235053Upd RPL Fail',     'us_english', 896, 0, '235053: Update replenishment fail'
execute rdt.rdtAddMsg 235054, 10, '235054Upd RPL Fail',     'us_english', 896, 0, '235054: Update replenishment fail'
execute rdt.rdtAddMsg 235055, 10, '235055Upd LLI Fail',     'us_english', 896, 0, '235055: Update LLI fail'
execute rdt.rdtAddMsg 235056, 10, '235056Upd LLI Fail',     'us_english', 896, 0, '235056: Update LLI fail'
execute rdt.rdtAddMsg 235057, 10, '235057UPD UCC Fail',     'us_english', 896, 0, '235057: Update UCC fail'
execute rdt.rdtAddMsg 235058, 10, '235058UPD UCC Fail',     'us_english', 896, 0, '235058: Update UCC fail'
execute rdt.rdtAddMsg 235059, 10, '235059nspGetRight',      'us_english', 896, 0, '235059: nspGetRight'
execute rdt.rdtAddMsg 235060, 10, '235060Upd RPL Fail',     'us_english', 896, 0, '235060: Update replenishment fail'
execute rdt.rdtAddMsg 235061, 10, '235061Upd PKDtl Fail',   'us_english', 896, 0, '235061: Update pickdetail fail'
execute rdt.rdtAddMsg 235062, 10, '235062Upd PKDtl Fail',   'us_english', 896, 0, '235062: Update pickdetail fail'
execute rdt.rdtAddMsg 235063, 10, '235063UPD UCC Fail',     'us_english', 896, 0, '235063: Update UCC fail'
execute rdt.rdtAddMsg 235064, 10, '235064Upd UCC Fail',     'us_english', 896, 0, '235064: Update UCC fail'
execute rdt.rdtAddMsg 235065, 10, '235065Upd RPL Fail',     'us_english', 896, 0, '235065: Update replenishment fail'
execute rdt.rdtAddMsg 235066, 10, '235066UPD RPL Fail',     'us_english', 896, 0, '235066: Update replenishment fail'
execute rdt.rdtAddMsg 235067, 10, '235067Upd PKDtl Fail',   'us_english', 896, 0, '235067: Update pickdetail fail'
execute rdt.rdtAddMsg 235068, 10, '235068Upd PKDtl Fail',   'us_english', 896, 0, '235068: Update pickdetail fail'
execute rdt.rdtAddMsg 235069, 10, '235069Upd PKDtl Fail',   'us_english', 896, 0, '235069: Update pickdetail fail'
execute rdt.rdtAddMsg 235070, 10, '235070UPD PKDtl Fail',   'us_english', 896, 0, '235070: Update pickdetail fail'
execute rdt.rdtAddMsg 235071, 10, '235071UPD PKDtl Fail',   'us_english', 896, 0, '235071: Update pickdetail fail'
execute rdt.rdtAddMsg 235072, 10, '235072UPD PKDtl Fail',   'us_english', 896, 0, '235072: Update pickdetail fail'
execute rdt.rdtAddMsg 235073, 10, '235073Upd RPL Fail',     'us_english', 896, 0, '235073: Update replenishment fail'
execute rdt.rdtAddMsg 235074, 10, '235074Upd RPL Fail',     'us_english', 896, 0, '235074: Update replenishment fail'
execute rdt.rdtAddMsg 235075, 10, '235075UCCLot01Diff',     'us_english', 896, 0, '235075: UCC Lottable01 is different'
execute rdt.rdtAddMsg 235076, 10, '235076UPD PKDtl Fail',   'us_english', 896, 0, '235076: Update pickdetail fail'
execute rdt.rdtAddMsg 235077, 10, '235077UPD PKDtl Fail',   'us_english', 896, 0, '235077: Update pickdetail fail'
execute rdt.rdtAddMsg 235078, 10, '235078UPD PKDtl Fail',   'us_english', 896, 0, '235078: Update pickdetail fail'
execute rdt.rdtAddMsg 235079, 10, '235079UPD PKDtl Fail',   'us_english', 896, 0, '235079: Update pickdetail fail'
execute rdt.rdtAddMsg 235080, 10, '235080UPD PKDtl Fail',   'us_english', 896, 0, '235080: Update pickdetail fail'
execute rdt.rdtAddMsg 235081, 10, '235081UPD PKDtl Fail',   'us_english', 896, 0, '235081: Update pickdetail fail'


------------------------------------------------------------------------------


select * from rdt.rdtmsg(nolock) where message_id between 235051 and 235100 