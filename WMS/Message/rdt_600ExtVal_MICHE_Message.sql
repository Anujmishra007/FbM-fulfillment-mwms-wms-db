-- rdt_600ExtVal_MICHE_Message.sql (NYE018)
--  254951 - 255000  --Add DOT/Week related messages for Func 600
execute rdt.rdtdropmsg 254951, 255000


execute rdt.rdtAddMsg 254951, 10, '254951DOT4Digits',               'us_english', 600, 0, '254951: DOT should only 4 digits'
execute rdt.rdtAddMsg 254952, 10, '254952DOTWeeksRule',             'us_english', 600, 0, '254952: not meet DOT weeks rule'
execute rdt.rdtAddMsg 254953, 10, '254953DOTNotMoreThanToday',      'us_english', 600, 0, '254953: DOT should not more than today'
execute rdt.rdtAddMsg 254954, 10, '254954Between1And53',            'us_english', 600, 0, '254954: must be between 1 and 53'
execute rdt.rdtAddMsg 254955, 10, '254955MustBe4Digit',             'us_english', 600, 0, '254955: must be a 4-digit'
execute rdt.rdtAddMsg 254956, 10, '254956WeekYearFuture',           'us_english', 600, 0, '254956: WeekYear can not in future'
execute rdt.rdtAddMsg 254957, 10, '254957WeekNumberInvalid',        'us_english', 600, 0, '254957: WeekNumber Invalid'
execute rdt.rdtAddMsg 254958, 10, '254958MoreThanSUSR4Allowed',     'us_english', 600, 0, '254958: More than SUSR4 allowed'


select * from rdt.rdtmsg (nolock) where message_id between 254951 and 254958