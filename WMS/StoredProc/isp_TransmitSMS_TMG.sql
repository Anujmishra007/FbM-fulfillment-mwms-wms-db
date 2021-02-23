IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[isp_TransmitSMS_TMG]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [dbo].[isp_TransmitSMS_TMG]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/          
/* Stored Procedure: [isp_TransmitSMS_TMG]                              */          
/* Creation Date:                                                       */          
/* Copyright: IDS                                                       */          
/* Written by: kelvinongcy                                              */          
/*                                                                      */          
/* Purpose: https://jira.lfapps.net/browse/WMS-10271                    */          
/*                                                                      */          
/* Called By:                                                           */          
/*                                                                      */          
/* PVCS Version: 1.0                                                    */          
/*                                                                      */          
/* Version: 5.4                                                         */          
/*                                                                      */          
/* Data Modifications:                                                  */          
/*                                                                      */          
/* Updates:                                                             */          
/* Date         Author    Ver.  Purposes                                */          
/* 6-9-19       kocy       1.0   Sent SMS when Orders is shipped        */  
/*                               for Taylormade Golf (storerkey = 'TMG')*/         
/************************************************************************/     
  
CREATE PROCEDURE [dbo].[isp_TransmitSMS_TMG]         
( @StorerKey NVARCHAR(15),         
  @bDebug      INT = 0 )        
AS           
BEGIN        
   SET NOCOUNT ON        
   SET ANSI_NULLS ON        
   SET ANSI_WARNINGS ON        
   SET QUOTED_IDENTIFIER OFF        
   SET CONCAT_NULL_YIELDS_NULL OFF          
        
   DECLARE    @cOrderKey       NVARCHAR(15)  
             ,@cCompany        NVARCHAR(25)    
             ,@cMobileNo       NVARCHAR(15)    
             ,@cExternOrderkey NVARCHAR(25)    
             ,@cUDF09          NVARCHAR(30)    
             ,@cSubject        NVARCHAR(30)    
             ,@cSQL            NVARCHAR(MAX)    
             ,@Err             INT    
             ,@ErrMsg          NVARCHAR(255)    
             ,@ErrSeverity     INT    
             ,@dBegin          DATETIME    
             ,@RowCount        INT    
             ,@c_AlertKey      CHAR(18)  
             ,@mail_id         INT  
  
        
   DECLARE @MailQSMS table( mail_id int NOT NULL)  
   IF OBJECT_ID('tempdb..#M','u') IS NOT NULL  DROP TABLE  #M;    
   CREATE TABLE #M (    
     OrderKey       NVARCHAR(25),  
     ReceiptName    NVARCHAR(25),    
     MobileNo       NVARCHAR(15),    
     ExternOrderKey NVARCHAR(25),    
     WarehouseName  NVARCHAR (25),    
     SMSInfo           NVARCHAR(MAX)    
   )    
    
   SELECT @Err = 0, @ErrMsg = '', @ErrSeverity = 0    
    
   DECLARE CUR_TMG CURSOR LOCAL FAST_FORWARD READ_ONLY FOR     
   SELECT o.OrderKey, o.C_Company, o.C_Phone1, o.ExternOrderKey, f.UserDefine09    
   FROM  ORDERS o  WITH (NOLOCK) --ON  t.key1 = o.Orderkey    
   LEFT JOIN STORER c WITH (NOLOCK) ON o.ConsigneeKey = c.StorerKey    
   LEFT JOIN FACILITY f WITH (NOLOCK) ON o.Facility = f.Facility    
   LEFT JOIN MBOLDETAIL md WITH (NOLOCK) ON md.OrderKey = o.OrderKey    
   LEFT JOIN MBOL m WITH (NOLOCK) ON m.MbolKey = md.MbolKey    
   WHERE o.StorerKey = @StorerKey    
   AND o.[Status] = '9'     
   AND ISNULL(o.C_Phone1, '') <> '' AND LEFT(LTRIM(o.C_Phone1), 1 ) ='1'    
   AND LEN(o.C_Phone1) = '11'  
   AND o.AddDate >  '2019-09-18'  --DATEADD (day, -1 ,CONVERT(varchar, GETDATE(), 112))
   AND NOT EXISTS ( SELECT 1 FROM MailQSMS AS m (NOLOCK) WHERE m.UniqueKey = o.OrderKey )  
   GROUP BY o.OrderKey, o.C_Company, o.C_Phone1, o.ExternOrderKey, f.UserDefine09  
       
   SELECT @Err = @@ERROR    
   IF @Err <> 0    
   BEGIN    
      SET @ErrMsg = 'NSQL'+CONVERT(Char(5),@Err)+': Error when declare cursor ('+OBJECT_NAME(@@PROCID)+').'    
   END    
    
   OPEN CUR_TMG    
   FETCH NEXT FROM CUR_TMG INTO @cOrderKey, @cCompany, @cMobileNo, @cExternOrderkey, @cUDF09             
    
   WHILE @@FETCH_STATUS <> -1    
   BEGIN    
          
      SET @cSQL = N' 尊敬的 ' + @cCompany + ' '+ @cMobileNo + '，' +  
                  N' 你的订单 ' + RTRIM(LTRIM(@cExternOrderkey)) +   
                  N' 已经从 '+ @cUDF09 +   
                  N' 发出，预计 2-3 日后送到，请注意接听派送人员的来电。如有疑问，请联络利丰物流运输部 13530960929/13510899702。' +
                  N'（上海泰勒梅高尔夫用品有限公司 Shanghai Taylor Made Golf Products Co., Ltd. ）'  
  
      BEGIN TRY 
         TRUNCATE TABLE #M
         PRINT @cSQL    
         INSERT INTO #M ( OrderKey, ReceiptName, MobileNo, ExternOrderKey, WarehouseName, SMSInfo )    
         SELECT @cOrderKey, @cCompany, @cMobileNo, @cExternOrderkey, @cUDF09, @cSQL    
         SET @RowCount = @@ROWCOUNT    
      END TRY    
      BEGIN CATCH    
         SET @ErrMsg     = ISNULL(ERROR_MESSAGE(),'');    
         SET @ErrSeverity = ISNULL(ERROR_SEVERITY(),0);    
         SET @Err = @@ERROR + 50000;    
         EXECUTE nspg_getkey 'LogEvent', 18, @c_AlertKey OUTPUT, '', '', ''    
         INSERT ALERT(AlertKey, ModuleName, AlertMessage, Severity, NotifyId, Status, ResolveDate, Resolution, Storerkey, UCCNo, UOMQty, Qty, ID  )     
         VALUES   (@c_AlertKey,ISNULL(OBJECT_NAME(@@PROCID),''),@cOrderKey, @ErrSeverity, ISNULL(HOST_NAME(),''),@Err, '', ISNULL(@cSQL, ''), @StorerKey, @cExternOrderKey, @RowCount, DATEDIFF(s,@dBegin,GETDATE()),LEFT(@ErrMsg,20));    
         THROW @Err, @ErrMsg, 1;    
      END CATCH    
    
      IF (@bDebug = 1)    
      BEGIN    
          SELECT * FROM #M    
          SELECT @RowCount 'No.RowCount'    
      END    
    
      SELECT   
         @cOrderKey       = ISNULL(OrderKey, '')  
        ,@cCompany        = ISNULL(ReceiptName, '')    
        ,@cMobileNo       = ISNULL(MobileNo, '' )    
        ,@cExternOrderKey = ISNULL(ExternOrderKey, '' )    
        ,@cUDF09          = ISNULL(WarehouseName, '' )    
        ,@cSQL            = ISNULL(SMSInfo, '' )    
      FROM #M    
        
      IF @RowCount > 0    
      BEGIN     
        IF @cMobileno  <> ''    
        BEGIN          
         
         INSERT INTO [DTS].[DBMailQueue] ( mail_type, recipients, [subject], body , body_format, AddSource )   
         OUTPUT INSERTED.mail_id INTO @MailQSMS   
         VALUES ( 'SMS', 'SMS@lifung.com', 'R86'+@cMobileNo , @cSQL, 'TEXT' , OBJECT_NAME(@@PROCID) )    -- To sent out the SMS, infront MobileNo need put phone's number CountryCode.
  
         SELECT @mail_id = mail_id FROM @MailQSMS  
  
         INSERT INTO MailQSMS ( mail_id, UniqueKey, UniqueKeyName, StorerKey, R01Name, R01, R02Name, R02, R03Name, R03, R04Name, R04 )  
         VALUES(  @mail_id, @cOrderKey, 'OrderKey', @StorerKey, 'ExternOrderKey', @cExternOrderKey, 'C_Company', @cCompany, 'C_Phone1', @cMobileNo, 'UserDefine09', @cUDF09)   
  
      END  
     END    
     
   FETCH NEXT FROM CUR_TMG INTO  @cOrderKey, @cCompany, @cMobileNo, @cExternOrderkey, @cUDF09               
   END    
   CLOSE CUR_TMG        
   DEALLOCATE CUR_TMG     
      
END
GO


