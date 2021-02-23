/***************************************************************************/
/* Updates:                                                                */
/* Date         Author      Ver.  Purposes                                 */
/* 10-Aug-2018  KHL03       1.0   https://jiralfl.atlassian.net/browse/WMS-4319 */
/***************************************************************************/

CREATE OR ALTER FUNCTION dbo.fn_GetSendDate(
   @DeliveryDate DATETIME,
   @LeadDay      INT
  ,@StorerKey    nvarchar(15) = '' )
RETURNS DATETIME
AS
BEGIN
   DECLARE  @SendDate DATETIME = @DeliveryDate
           ,@i int   = 1;
   WHILE @i <= @LeadDay
   BEGIN
      SET @SendDate = DATEADD(d, -@i, @DeliveryDate)
      IF DATENAME(WEEKDAY, @SendDate) IN('Saturday', 'Sunday')
      BEGIN
         --PRINT CONVERT(CHAR(8),@SendDate,112)+' '+DATENAME(dw,@SendDate)
         SET @DeliveryDate = DATEADD(d, -1, @DeliveryDate);
      END
      ELSE IF EXISTS ( SELECT * FROM HolidayHeader AS h JOIN HolidayDetail AS d ON h.HolidayKey=d.HolidayKey 
               WHERE h.UserDefine01=@StorerKey AND h.UserDefine02='AutomailHoliday' AND convert(char(8),d.HolidayDate,112)=convert(char(8),@SendDate,112) )
      BEGIN
         --PRINT CONVERT(CHAR(8),@SendDate,112)+' Holiday'
         SET @DeliveryDate = DATEADD(d, -1, @DeliveryDate);
      END
      ELSE
      BEGIN
         --PRINT CONVERT(CHAR(8),@SendDate,112)+' work '+CAST(@i AS char(2))
         SET @i = @i + 1
      END
   END;
   RETURN @SendDate;
END;
GO
