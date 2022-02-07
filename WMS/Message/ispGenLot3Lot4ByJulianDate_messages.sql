
-- ispLottableRule_Wrapper (range 61326 - 61350)
-- execute rdt.rdtDropMsg 61326, 61350
-- select * from rdt.rdtMsg (nolock) where message_id between 61326 and 61350

execute rdt.rdtAddMsg 61326, 10, '61326 Invalid Lottable03Label Setup.  (ispGenLot3Lot4ByJulianDate)', 'us_english'
execute rdt.rdtAddMsg 61327, 10, '61327 Invalid Lottable04Label Setup.  (ispGenLot3Lot4ByJulianDate)', 'us_english'
execute rdt.rdtAddMsg 61328, 10, '61328 Batch/Year Not Numeric.  (ispGenLot3Lot4ByJulianDate)', 'us_english'
execute rdt.rdtAddMsg 61329, 10, '61329 DaysInYear Not Numeric. (ispGenLot3Lot4ByJulianDate)', 'us_english'
execute rdt.rdtAddMsg 61330, 10, '61330 DaysInYear Less Than or Equal to Zero.  (ispGenLot3Lot4ByJulianDate)', 'us_english'
execute rdt.rdtAddMsg 61331, 10, '61331 DaysInYear Greater Than 366. (ispGenLot3Lot4ByJulianDate)', 'us_english'
execute rdt.rdtAddMsg 61332, 10, '61332 DaysInYear Greater Than 365. (ispGenLot3Lot4ByJulianDate)', 'us_english'

