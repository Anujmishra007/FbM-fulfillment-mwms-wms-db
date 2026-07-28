IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[ispOrderDespatchDate]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [dbo].[ispOrderDespatchDate]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/      
/* Stored Procedure: ispOrderDespatchDate                               */      
/* Creation Date: 20-Aug-2010                                           */      
/* Copyright: MAERSK                                                    */      
/* Written by: LIM KAH HWEE                                             */      
/*                                                                      */      
/* Purpose: Update Despatch & Arrival date                              */      
/*                                                                      */      
/*                                                                      */      
/* Called By: BEJ - Update Despatch & Arrival Date                      */      
/*                                                                      */      
/* PVCS Version: 1.0                                                    */      
/*                                                                      */      
/* Version: 5.4                                                         */      
/*                                                                      */      
/* Data Modifications:                                                  */      
/*                                                                      */      
/* Updates:                                                             */      
/* Date        Author Ver Purposes                                      */      
/* 2010-08-20  KHLim  1.0 initial revision                              */      
/* 2010-11-22  KHLim  1.1 Add TrafficCop = NULL                         */      
/* 2010-12-01  KHLim  1.2 Add Condition: IntermodalVehicle              */      
/*                        check if CODELKUP.Long = '', skip condition   */           
/* 2013-04-18  TLTING 1.3 Deadlock issue                                */  
/* 2014-04-07  TLTING 1.3 Bug fix                                       */
/* 2025-10-16  JihHaur1.4 FCR-8948 Add consideration of Holidays (JH01) */
/* 2026-01-02  JihHaur1.5 FCR-8948 consider Offday between holidays (JH02)*/
/************************************************************************/      
      
CREATE   PROC [dbo].[ispOrderDespatchDate]            
AS      
BEGIN      
      
   SET NOCOUNT ON      
   SET QUOTED_IDENTIFIER OFF      
   SET ANSI_NULLS OFF      
   SET CONCAT_NULL_YIELDS_NULL OFF      
      
   DECLARE @cSQL               nvarchar(MAX),      
           @cSQL2              nvarchar(MAX),      
           @cStorerKey         nvarchar(15),      
           @cPrevStorerKey     nvarchar(15) = '',  /*JH01*/
           @cType              nvarchar(10),      
           @cCompare           nvarchar(15),      
           @cOperator          char(2),      
           @cCutOff            char(5),      
           @nMinQty            int,      
           @nMaxQty            int,      
           @nProcess           int,      
           @cDatePart          char(1),      
           @cOrderKey          nvarchar(10),      
           @dOrderDate         datetime,      
           @dDeliveryDate      datetime,      
           @cIntermodalVehicle char(30),      
           @dAddDate           datetime,      
           @dUserDefine06      datetime,      
           @cOffDayList        nvarchar(7),      
           @cLeadTime          nvarchar(10),      
           @cFacility          nvarchar(5),      
           @cConsigneekey      nvarchar(15),      
           @cC_City            nvarchar(45),
           @c_BEJ_SkipHoliday  NVARCHAR(10) = '',  /*JH01*/
           @c_HolidayKey       NVARCHAR(10) = '',  /*JH01*/  
           @c_SkipUpdateDeliveryDate NVARCHAR(10) = '',  /*JH01*/
           @n_AddDays          int = 0,  /*JH01*/ 
           @dStartDate         DATE, /*JH02*/ 
           @n_continue         int,  
           @n_starttcnt        int      
   /*JH01 S*/ 
   DECLARE @b_Success    int,      
           @n_err        int,      
           @c_authority  char(1),      
           @c_errmsg     nvarchar(255)      
   /*JH01 E*/ 

   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT        
   -- tlting01  
   WHILE @@TRANCOUNT> 0  
      COMMIT TRAN  
   
   DECLARE Cur_StorerDD CURSOR LOCAL FAST_FORWARD READ_ONLY FOR      
   SELECT RTRIM(StorerKey), ISNULL(RTRIM(OrderType),''), CONCAT('O.',RTRIM(CompareDate)), Operator, CutOffTime, MinQty, MaxQty, ProcessTime, ProcessType      
   FROM   dbo.StorerSODefaultDate WITH (NOLOCK)       
   ORDER BY Priority      
      
   OPEN Cur_StorerDD  
      
   FETCH NEXT FROM Cur_StorerDD INTO @cStorerKey, @cType, @cCompare, @cOperator, @cCutOff, @nMinQty, @nMaxQty, @nProcess, @cDatePart      
      
   WHILE @@FETCH_STATUS <> -1      
   BEGIN      
      
    CREATE TABLE #tblOrder      
      (      
         OrderKey       nvarchar(10),      
         StorerKey      nvarchar(15),      
         OrderDate      datetime,      
         DeliveryDate   datetime,      
         ConsigneeKey   nvarchar(15),       
         C_City         nvarchar(45),      
         IntermodalVehicle char(30),      
         AddDate        datetime,      
         Facility       nvarchar(5),      
         UserDefine06   datetime      
      )      
      
--      PRINT @cType + ', ' + @cCompare + ', ' + @cOperator + ', ' + @cCutOff + ', ' + CAST(@nMinQty AS char(9)) + ', ' + CAST(@nMaxQty AS char(9)) + ', ' + CAST(@nProcess AS char(9)) + ', ' + @cDatePart      
      
   --   SET @cSQL = 'UPDATE ORDERS WITH (rowlock)       
   --      SET UserDefine06 = DateAdd(day, ' + CAST(@nProcess AS nvarchar(9)) + ', OrderDate)' +      
      SET @cSQL = 'INSERT INTO #tblOrder      
         SELECT RTRIM(O.OrderKey), RTRIM(O.StorerKey), O.OrderDate, O.DeliveryDate, RTRIM(O.ConsigneeKey), ISNULL(O.C_City,''''), RTRIM(O.IntermodalVehicle), O.AddDate, RTRIM(O.Facility),      
         CASE WHEN O.UserDefine06 IS NULL OR O.UserDefine06 = ''1/1/1900''      
            THEN DateAdd(' + CASE @cDatePart WHEN 'D' THEN 'dd' ELSE 'hh' END + ', ' + CAST(@nProcess AS nvarchar(9)) + ', ' + @cCompare + ')       
            ELSE O.UserDefine06 END AS UserDefine06       
         FROM ORDERS O WITH (nolock) 
         LEFT JOIN StorerConfig SC WITH (NOLOCK) 
            ON SC.StorerKey = O.StorerKey 
            AND SC.Facility = O.Facility 
            AND SC.ConfigKey = ''BEJ_SkipUpdateDeliveryDate'' '+      
         'WHERE 
            ((SC.SValue <> ''1'' AND O.DeliveryDate <= O.AddDate) 
           OR (SC.SValue = ''1'' 
            AND (O.UserDefine06 IS NULL OR
                 O.UserDefine06 = ''1/1/1900'' OR O.DeliveryDate = ''1/1/1900'') )  )
            AND O.SOSTATUS not in (''9'',''CANC'')  AND O.STATUS not in (''9'',''CANC'')       
            AND O.AddDate <> ''1/1/1900'' AND O.OrderDate <> ''1/1/1900''      
            AND O.StorerKey = ''' + @cStorerKey + '''' +       
         CASE @cType WHEN '' THEN '' ELSE ' AND Type = ''' + @cType + '''' END      
      
      IF @cCutOff <> '00:00'      
      BEGIN      
         SET @cSQL = @cSQL +      
            ' AND CAST(REPLACE(STR(DATEPART(hour,   ' + @cCompare + '),2),'' '',''0'') AS char(2))+'':''+      
                  CAST(REPLACE(STR(DATEPART(minute, ' + @cCompare + '),2),'' '',''0'') AS char(2)) ' + @cOperator +       
                  '''' + @cCutOff + ''''      
      END      
      IF @nMinQty <> 0 OR @nMaxQty <> 0      
      BEGIN      
         SET @cSQL = @cSQL +      
            ' AND ( SELECT SUM(OriginalQty) FROM ORDERDETAIL WITH (nolock)       
               WHERE ORDERS.OrderKey = ORDERDETAIL.OrderKey ) BETWEEN ' + CAST(@nMinQty AS nvarchar(9)) +      
               ' AND ' + CAST(@nMaxQty AS nvarchar(9))      
      END      
      
      --PRINT @cSQL      
      
      EXEC(@cSQL)      
      
      DECLARE Cur_Order CURSOR LOCAL FAST_FORWARD READ_ONLY FOR      
      SELECT *      
      FROM   #tblOrder WITH (NOLOCK)       
      
      OPEN Cur_Order      
      
      FETCH NEXT FROM Cur_Order INTO @cOrderKey, @cStorerKey, @dOrderDate, @dDeliveryDate, @cConsigneeKey, @cC_City, @cIntermodalVehicle, @dAddDate, @cFacility, @dUserDefine06      
      
      WHILE @@FETCH_STATUS <> -1      
      BEGIN 
         IF @cPrevStorerKey <> @cStorerKey               /*JH01*/
         BEGIN
            SET @c_HolidayKey = ''                       /*JH01*/
            SET @c_BEJ_SkipHoliday = ''                  /*JH01*/
            SET @c_SkipUpdateDeliveryDate = ''           /*JH01*/
            SET @cPrevStorerKey = @cStorerKey            /*JH01*/
            
            SELECT @cOffDayList = CASE WHEN Sun <> '0' THEN '1' ELSE '' END +       
                               CASE WHEN Mon <> '0' THEN '2' ELSE '' END +      
                               CASE WHEN Tue <> '0' THEN '3' ELSE '' END +      
                               CASE WHEN Wed <> '0' THEN '4' ELSE '' END +      
                               CASE WHEN Thu <> '0' THEN '5' ELSE '' END +      
                               CASE WHEN Fri <> '0' THEN '6' ELSE '' END +      
                               CASE WHEN Sat <> '0' THEN '7' ELSE '' END
                , @c_HolidayKey = HolidayKey
            FROM StorerSODefault WITH (nolock)       
            WHERE StorerKey = @cStorerKey       
            
            /*JH01 S*/
            IF ISNULL(@c_HolidayKey,'') <> ''
            BEGIN
               EXECUTE nspGetRight                                
                @c_Facility  = @cfacility,                     
                @c_StorerKey = @cStorerKey,                    
                @c_sku       = '',                          
                @c_ConfigKey = 'BEJ_SkipHoliday',         
                @b_Success   = @b_success   OUTPUT,             
                @c_authority = @c_BEJ_SkipHoliday OUTPUT,             
                @n_err       = @n_err       OUTPUT,       
                @c_errmsg    = @c_errmsg    OUTPUT
               
              EXECUTE nspGetRight                                
                @c_Facility  = @cfacility,                     
                @c_StorerKey = @cStorerKey,                    
                @c_sku       = '',                          
                @c_ConfigKey = 'BEJ_SkipUpdateDeliveryDate',         
                @b_Success   = @b_success   OUTPUT,             
                @c_authority = @c_SkipUpdateDeliveryDate OUTPUT,             
                @n_err       = @n_err       OUTPUT,       
                @c_errmsg    = @c_errmsg    OUTPUT
            END
         END
         
         IF ISNULL(@c_HolidayKey,'') <> '' AND @c_BEJ_SkipHoliday = '1'
         BEGIN                    
            SET @n_AddDays = 0
            SELECT @n_AddDays = COUNT(1) FROM HolidayHeader AS h (NOLOCK)                       
                           JOIN HolidayDetail AS hd (NOLOCK) ON h.HolidayKey = hd.HolidayKey     
                           WHERE h.HolidayKey = ISNULL(@c_HolidayKey, '')                      
                           AND hd.HolidayDate >=  CONVERT(DATE, @dAddDate)
                           AND hd.HolidayDate <= CONVERT(DATE, @dUserDefine06)
            IF @n_AddDays > 0
               BEGIN
               SET @dUserDefine06 = DateAdd(dd, @n_AddDays, @dUserDefine06)
               IF @c_SkipUpdateDeliveryDate <> '1' 
               BEGIN
                  SET @dDeliveryDate = DateAdd(dd, @n_AddDays, @dDeliveryDate)                 
               END

               WHILE EXISTS ( SELECT  1 FROM HolidayHeader AS h (NOLOCK)                       
                           JOIN HolidayDetail AS hd (NOLOCK) ON h.HolidayKey = hd.HolidayKey   
                           WHERE h.HolidayKey = ISNULL (@c_HolidayKey, '')                      
                              AND hd.HolidayDate >=  CONVERT(DATE, @dAddDate)
                              AND hd.HolidayDate = CONVERT(DATE, @dUserDefine06))                  
               BEGIN               
                  SET @dUserDefine06 = DateAdd(dd, 1, @dUserDefine06)                                  
            
                  IF @c_SkipUpdateDeliveryDate <> '1' 
                  BEGIN                     
                     SET @dDeliveryDate = DateAdd(dd, 1, @dDeliveryDate)                     
                  END
               END
            END 
             
         END         
         /*JH01 E*/  

         IF @cOffDayList <> '' AND LEN(@cOffDayList) < 7      
         BEGIN      
            /*JH02 S*/
            SET @dStartDate = @dAddDate
            WHILE @dStartDate <= @dUserDefine06 
            BEGIN
               IF CHARINDEX(CAST(DATEPART(dw, @dStartDate) AS NCHAR(1)),@cOffDayList) > 0 AND @dStartDate NOT IN (SELECT HolidayDate FROM HolidayHeader AS h (NOLOCK)                       
                              JOIN HolidayDetail AS hd (NOLOCK) ON h.HolidayKey = hd.HolidayKey   
                              WHERE h.HolidayKey = ISNULL (@c_HolidayKey, '')                       
                                 )
               BEGIN
                    SET @dUserDefine06 = DateAdd(day, 1, @dUserDefine06)   
                    --select @dUserDefine06
               END
               SET @dStartDate = DATEADD(DAY, 1, @dStartDate)
            END
            --WHILE CHARINDEX(CAST(DATEPART(dw, @dUserDefine06) AS NCHAR(1)),@cOffDayList) > 0       
            --BEGIN      
            --   SET @dUserDefine06 = DateAdd(day, 1, @dUserDefine06)      
            --END   
            /*JH02 E*/
         END      
      
         IF @cDatePart = 'D'      
         BEGIN      
            SET @dUserDefine06 = DateAdd(second, -1, DateAdd(day, 1, CONVERT(char(11),@dUserDefine06,106)))      
         END      
      
         IF @dDeliveryDate <= @dAddDate OR @dDeliveryDate = '1/1/1900'      
--         IF DateDiff(minute,@dDeliveryDate, @dAddDate) = 0      
         BEGIN      
            SET @cLeadTime = ''      
      
            SET @cSQL = 'SELECT TOP 1 @cLeadTime = Short       
                        FROM CODELKUP WITH (nolock)       
                        WHERE LISTNAME = ''CityLdTime''      
                        AND CAST(Notes AS nvarchar(15)) = N''' + @cStorerKey + ''''      
            /*JH01 S*/                  
            --DECLARE  @b_Success    int,      
            --         @n_err        int,      
            --         @c_authority  char(1),      
            --         @c_errmsg     nvarchar(255)      
            /*JH01 E*/ 
            EXECUTE dbo.nspGetRight       
               @cFacility, -- facility      
               @cStorerKey, -- Storerkey        
               NULL,         -- Sku        
               'CityLdTimeField',        -- Configkey        
               @b_success    output,        
               @c_authority  output,         
               @n_err        output,        
               @c_errmsg     output        
      
            IF @b_success <> 1        
            BEGIN        
               SELECT @n_continue = 3, @c_errmsg = 'ispOrderDespatchDate' + RTrim(@c_errmsg)        
            END        
            ELSE IF @c_authority = '1'      
            BEGIN      
               SET @cSQL = @cSQL + ' AND Description = ''' + @cC_City + ''''      
            END      
            ELSE IF @c_authority = '2'      
            BEGIN      
               SET @cSQL = @cSQL + ' AND Description = (SELECT City FROM STORER WITH (nolock) WHERE StorerKey = ''' + @cConsigneeKey + ''')'      
            END      
            ELSE IF @c_authority = '3'      
            BEGIN      
               SET @cSQL = @cSQL + ' AND Description = ''' + @cConsigneeKey + ''''      
            END      
      
            IF @cIntermodalVehicle = ''      
            BEGIN      
               SET @cSQL = @cSQL + ' AND CAST(Notes2 AS nvarchar(30)) = N''Road'''      
            END      
            ELSE      
            BEGIN      
               SET @cSQL = @cSQL + ' AND CAST(Notes2 AS nvarchar(30)) = N''' + @cIntermodalVehicle + ''''      
            END      
      
            SET @cSQL2 = @cSQL + ' AND Long = ''' + @cFacility + ''''      
      
--            PRINT @cSQL2      
            EXEC sp_executesql @cSQL2, N'@cLeadTime nvarchar(10) OUTPUT',  -- check with CODELKUP.Long = ORDERS.Facility      
                                        @cLeadTime OUTPUT         
            IF ISNUMERIC(@cLeadTime) = 1      
            BEGIN      
               SET @dDeliveryDate = DateAdd(day, CAST(@cLeadTime AS INT), @dUserDefine06)      
            END      
            ELSE      
            BEGIN      
               EXEC sp_executesql @cSQL, N'@cLeadTime nvarchar(10) OUTPUT',  -- check again without CODELKUP.Long (allow Long = '')      
                                           @cLeadTime OUTPUT         
               IF ISNUMERIC(@cLeadTime) = 1      
               BEGIN      
--                  PRINT @cLeadTime      
                  SET @dDeliveryDate = DateAdd(day, CAST(@cLeadTime AS INT), @dUserDefine06)    
               END      
               ELSE      
               BEGIN
               IF @c_SkipUpdateDeliveryDate <> '1' /*JH01*/
                  BEGIN                     
                     SET @dDeliveryDate = @dUserDefine06   
                  END                     
               END      
            END      
         END      
      
         BEGIN TRAN  
         UPDATE ORDERS WITH (rowlock)       
         SET UserDefine06 = @dUserDefine06,   
            DeliveryDate = CASE WHEN @c_SkipUpdateDeliveryDate <> '1' THEN @dDeliveryDate ELSE DeliveryDate END,  /*JH01*/   
            Editdate = getdate(),    -- tlting01  
            TrafficCop = NULL      
         --SELECT OrderKey, StorerKey, OrderDate, AddDate, @dUserDefine06 AS NewUserDefine06,       
         --      DeliveryDate, @dDeliveryDate AS NewDeliveryDate      
         --FROM ORDERS WITH (nolock)       
         WHERE OrderKey = @cOrderKey      
         IF @@error <> 0      -- tlting01  
         BEGIN 
            ROLLBACK TRAN       
         END  
         ELSE  
         BEGIN   
            COMMIT TRAN   
         END  
      
         FETCH NEXT FROM Cur_Order INTO @cOrderKey, @cStorerKey, @dOrderDate, @dDeliveryDate, @cConsigneeKey, @cC_City, @cIntermodalVehicle, @dAddDate, @cFacility, @dUserDefine06      
      END      
      CLOSE Cur_Order      
      DEALLOCATE Cur_Order      
      
      DROP TABLE #tblOrder      
      
      FETCH NEXT FROM Cur_StorerDD INTO @cStorerKey, @cType, @cCompare, @cOperator, @cCutOff, @nMinQty, @nMaxQty, @nProcess, @cDatePart      
      
   END      
   CLOSE Cur_StorerDD      
   DEALLOCATE Cur_StorerDD      
     
   -- tlting01  
   WHILE @@TRANCOUNT <  @n_starttcnt  
      BEGIN TRAN  
  
   IF @n_continue=3  -- Error Occured - Process AND Return        
   BEGIN        
      IF @@TRANCOUNT = 1 AND @@TRANCOUNT >= @n_starttcnt        
      BEGIN        
         ROLLBACK TRAN        
      END        
      ELSE        
      BEGIN        
         WHILE @@TRANCOUNT > @n_starttcnt        
         BEGIN        
            COMMIT TRAN        
         END        
      END        
      EXECUTE dbo.nsp_logerror @n_err, @c_errmsg, 'ispOrderDespatchDate'      
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012        
      RETURN        
   END        
   ELSE        
   BEGIN        
      WHILE @@TRANCOUNT > @n_starttcnt        
      BEGIN        
         COMMIT TRAN 
      END        
      RETURN        
   END        
      
END -- procedure
GO
GRANT EXECUTE ON [dbo].[ispOrderDespatchDate] TO nSQL 
GO
