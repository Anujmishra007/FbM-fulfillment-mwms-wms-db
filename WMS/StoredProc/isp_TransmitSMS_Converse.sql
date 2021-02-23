 IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[isp_TransmitSMS_Converse]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [dbo].[isp_TransmitSMS_Converse]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/            
/* Stored Procedure: [isp_TransmitSMS_Converse]                         */            
/* Creation Date:                                                       */            
/* Copyright: IDS                                                       */            
/* Written by: kelvinongcy                                              */            
/*                                                                      */            
/* Purpose: https://jira.lfapps.net/browse/WMS-10448                    */            
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
/* 23-9-19       kocy       1.0   Sent SMS when Orders is shipped       */    
/*                               for storerkey = 'Converse'             */           
/************************************************************************/       
    
CREATE PROCEDURE [dbo].[isp_TransmitSMS_Converse]           
( @StorerKey NVARCHAR(15),           
  @Debug      INT = 0 )          
AS             
BEGIN          
   SET NOCOUNT ON          
   SET ANSI_NULLS ON          
   SET ANSI_WARNINGS ON          
   SET QUOTED_IDENTIFIER OFF          
   SET CONCAT_NULL_YIELDS_NULL OFF            
          
   DECLARE    @ConsigneeKey         NVARCHAR(15)    
             ,@ExternOrderKey       NVARCHAR(15)  
             ,@SumOriginalQty       NVARCHAR(15)   
             ,@TotalSumQriginalQty  NVARCHAR(15)  
             ,@MobileNo             NVARCHAR(15)      
             ,@LoadPlanAddDate      NVARCHAR(15)   
             ,@Err                  INT    = 0   
             ,@ErrMsg               NVARCHAR(255)      
             ,@ErrSeverity          INT   
             ,@dBegin               DATETIME      
             ,@RowCount             INT      
             ,@c_AlertKey           CHAR(18)    
             ,@Qid                  INT  
             ,@cSubject             NVARCHAR(15)      
             ,@c_SMSBody            NVARCHAR(MAX)  
             ,@cSQL                 NVARCHAR(MAX)  
             ,@TotalLoadKey         INT  
             ,@OrderKey             NVARCHAR(15)  
             ,@mail_id              INT  = 0  
  
   DECLARE @mailQSMS table( Qid int NOT NULL)  
   DECLARE @DBMailQueue table (mail_id int NOT NULL)  
  
   
   SELECT @Err = 0, @ErrMsg = '', @ErrSeverity = 0 ,  @c_SMSBody = '',  @TotalLoadKey = 0  
  
   DECLARE CUR_1 CURSOR LOCAL FAST_FORWARD READ_ONLY FOR  
   SELECT  o.ConsigneeKey,  FORMAT(ISNULL(l.AddDate, ''), 'MM/dd'), A.C_Phone1  
   FROM  ORDERS o  WITH (NOLOCK)    
   JOIN ORDERDETAIL od WITH (NOLOCK) ON o.OrderKey = od.OrderKey  
      LEFT JOIN STORER c WITH (NOLOCK) ON o.ConsigneeKey = c.StorerKey         
      LEFT JOIN LoadPlanDetail lp WITH (NOLOCK) ON lp.OrderKey = o.OrderKey  
      LEFT JOIN LoadPlan l WITH (NOLOCK) ON l.LoadKey = o.LoadKey  
   CROSS APPLY  
   (   
      SELECT TOP 1 C_Phone1  
      FROM ORDERS  WITH (NOLOCK)  
      WHERE StorerKey = o.StorerKey  
      AND C_Phone1 LIKE '+861%'    
      AND LEN(C_Phone1) = 14  
      AND [Status] = o.[Status]  
       AND ConsigneeKey =o.ConsigneeKey  
  ) AS A  
      WHERE o.StorerKey = @StorerKey       
      AND o.[Status] = '9'  
      AND l.AddDate BETWEEN CONVERT(VARCHAR(10), GETDATE() -1, 23) + ' 23:00:00.000' AND CONVERT(VARCHAR(10), GETDATE(), 23) + ' 23:00:00.000'  
      AND NOT EXISTS ( SELECT 1 FROM MailQSMSDet (NOLOCK) WHERE MailQSMSDet.OrderKey = o.OrderKey)  
      GROUP BY o.ConsigneeKey , l.AddDate, A.C_Phone1  
     
   SELECT @Err = @@ERROR  
   IF @Err <> 0  
   BEGIN  
      SET @ErrMsg = 'NSQL'+CONVERT(Char(5),@Err)+': Error when declare cursor ('+OBJECT_NAME(@@PROCID)+').'  
   END  
   
   OPEN CUR_1    
   FETCH NEXT FROM CUR_1 INTO @ConsigneeKey, @LoadPlanAddDate,  @MobileNo  
   WHILE @@FETCH_STATUS <> -1  
   BEGIN  
   BEGIN TRY     
     INSERT INTO MailQSMS(UniqueKey, UniqueKeyName, StorerKey, R01Name, R01, R02Name, R02, R03Name, R03)  
     OUTPUT INSERTED.Qid INTO @mailQSMS  
     VALUES ( @ConsigneeKey, 'ConsigneeKey', @StorerKey, 'ConsigneeKey', @ConsigneeKey, 'AddDate', @LoadPlanAddDate, 'C_Phone1' , @MobileNo)  
     SET @RowCount = @@ROWCOUNT  
   END TRY  
   BEGIN CATCH  
      SET @ErrMsg     = ISNULL(ERROR_MESSAGE(),'');    
      SET @ErrSeverity = ISNULL(ERROR_SEVERITY(),0);    
      SET @Err = @@ERROR + 50000;    
      EXECUTE nspg_getkey 'LogEvent', 18, @c_AlertKey OUTPUT, '', '', ''    
      INSERT ALERT(AlertKey, ModuleName, AlertMessage, Severity, NotifyId, Status, ResolveDate, Resolution, Storerkey, UCCNo, UOMQty, Qty, ID  )     
      VALUES   (@c_AlertKey,ISNULL(OBJECT_NAME(@@PROCID),''),@ConsigneeKey, @ErrSeverity, ISNULL(HOST_NAME(),''),@Err, '', ISNULL(@ConsigneeKey, ''), @StorerKey, @Qid, @RowCount, DATEDIFF(s,@dBegin,GETDATE()),LEFT(@ErrMsg,20));    
      THROW @Err, @ErrMsg, 1;  
   END CATCH  
       
   SELECT @Qid = Qid FROM @mailQSMS  
  
   IF(@Debug =1)  
   BEGIN   
     SELECT @RowCount 'No.RowCountSMSHeader', @Qid 'No.Qid'  
     SELECT * FROM MailQSMS (nolock) WHERE Qid = @Qid  
   END  
  
   SET @c_SMSBody=''  
   SET @TotalSumQriginalQty=''  
  
   IF (@RowCount > 0 AND ISNULL(@Qid, 0) > 0)  
   BEGIN  
     DECLARE CUR_2 CURSOR LOCAL FAST_FORWARD READ_ONLY FOR  
     SELECT  ISNULL(o.ExternOrderKey,''), SUM (od.OriginalQty), o.Orderkey  
     FROM  ORDERS o  WITH (NOLOCK)  
     JOIN ORDERDETAIL od WITH (NOLOCK) ON o.OrderKey = od.OrderKey  
     LEFT JOIN STORER c WITH (NOLOCK) ON o.ConsigneeKey = c.StorerKey  
     LEFT JOIN LoadPlanDetail lp WITH (NOLOCK) ON lp.OrderKey = o.OrderKey  
     LEFT JOIN LoadPlan l WITH (NOLOCK) ON l.LoadKey = o.LoadKey  
     WHERE o.StorerKey = @StorerKey  
     AND o.[Status] = '9'  
     AND o.ConsigneeKey = @ConsigneeKey  
     AND l.AddDate BETWEEN CONVERT(VARCHAR(10), GETDATE() - 1, 23) + ' 23:00:00.000' AND CONVERT(VARCHAR(10), GETDATE(), 23) + ' 23:00:00.000'  
     GROUP BY ISNULL(o.ExternOrderKey,''), o.OrderKey  
     
     OPEN CUR_2  
     FETCH NEXT FROM CUR_2 INTO  @ExternOrderKey, @SumOriginalQty, @OrderKey  
     WHILE @@FETCH_STATUS <> -1  
     BEGIN  
  
       SET @c_SMSBody +=  @ExternOrderKey + '， ' + @SumOriginalQty  + N'件; '  
       SET @TotalSumQriginalQty = CAST(@TotalSumQriginalQty AS INT) + CAST(@SumOriginalQty AS INT)  
  
       BEGIN TRY  
          INSERT INTO MailQSMSDet (Qid, C01Name, C01, C02Name, C02 , OrderKey)  
          VALUES (@Qid, 'ExternOrderKey', @ExternOrderKey, 'SumOfOrignalQty', @SumOriginalQty, @OrderKey)  
          SET @RowCount = @@ROWCOUNT  
       END TRY  
       BEGIN CATCH    
          SET @ErrMsg     = ISNULL(ERROR_MESSAGE(),'');    
          SET @ErrSeverity = ISNULL(ERROR_SEVERITY(),0);    
          SET @Err = @@ERROR + 50000;    
          EXECUTE nspg_getkey 'LogEvent', 18, @c_AlertKey OUTPUT, '', '', ''    
          INSERT ALERT(AlertKey, ModuleName, AlertMessage, Severity, NotifyId, Status, ResolveDate, Resolution, Storerkey, UCCNo, UOMQty, Qty, ID  )     
          VALUES   (@c_AlertKey,ISNULL(OBJECT_NAME(@@PROCID),''),@ExternOrderKey, @ErrSeverity, ISNULL(HOST_NAME(),''),@Err, '', ISNULL(@ConsigneeKey, ''), @StorerKey, @TotalLoadKey, @RowCount, DATEDIFF(s,@dBegin,GETDATE()),LEFT(@ErrMsg,20));    
          THROW @Err, @ErrMsg, 1;    
        END CATCH  
  
      FETCH NEXT FROM CUR_2 INTO @ExternOrderKey, @SumOriginalQty, @OrderKey  
     END    
     CLOSE CUR_2        
     DEALLOCATE CUR_2  
  
     IF (@Debug =1)  
     BEGIN   
        SELECT @RowCount 'No.RowCountSMSDet',@Err 'No.Error'  
        SELECT * FROM MailQSMSDet (nolock) WHERE Qid = @Qid  
     END  
  
     IF (@RowCount > 0 AND @Err = 0)  
     BEGIN  
        SET @cSQL = N'您好， 这里是利丰供应链管理 （中国） 有限公司，' + CHAR(13) +  
                    N'您的 ' + @LoadPlanAddDate + N' 的补货， 其订单及件数信息如下：' + CHAR(13) +  
                    @c_SMSBody + CHAR(13) +  
                    N'上述订单共' + @TotalSumQriginalQty + N'件，仓库正在装箱， 会尽快发出， 请等候， 谢谢！'                   
     END  
  
      INSERT INTO [DTS].[DBMailQueue] ( mail_type, recipients, [subject], body , body_format, AddSource )     
      OUTPUT INSERTED.mail_id INTO @DBMailQueue    
      VALUES ( 'SMS', 'SMS@lifung.com', 'R'+REPLACE(@MobileNo,'+', '') , @cSQL, 'HTML' , OBJECT_NAME(@@PROCID) )       
         
      SELECT @mail_id = mail_id FROM @DBMailQueue  
      UPDATE MailQSMS SET mail_id = @mail_id WHERE Qid = @Qid  
  
      IF (@Debug =1)  
      BEGIN  
         PRINT @cSQL  
      END  
             
   END  -- end of (@RowCount > 0) AND ISNULL(@Qid, 0) > 0  
   ELSE   
   BEGIN   
      PRINT @Qid  
   END  
  
    FETCH NEXT FROM CUR_1 INTO  @ConsigneeKey, @LoadPlanAddDate, @MobileNo  
  END    
  CLOSE CUR_1        
DEALLOCATE CUR_1  
   
  
END -- end of SP  