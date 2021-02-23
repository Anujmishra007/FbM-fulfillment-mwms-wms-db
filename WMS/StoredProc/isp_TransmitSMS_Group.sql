IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[isp_TransmitSMS_Group]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [dbo].[isp_TransmitSMS_Group]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/              
/* Stored Procedure: [isp_TransmitSMS_Group]                            */              
/* Creation Date:                                                       */              
/* Copyright: IDS                                                       */              
/* Written by: kelvinongcy                                              */              
/*                                                                      */              
/* Purpose: https://jiralfl.atlassian.net/browse/WMS-14040              */              
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
/* 22-7-20      kocy      1.0   Sent SMS when Orders is shipped         */      
/*                               for respective StorerKey               */             
/************************************************************************/         
      
CREATE PROCEDURE [dbo].[isp_TransmitSMS_Group]             
( @StorerKey NVARCHAR(15),    
  @LISTNAME  nvarchar(20),    
  @Code   NVARCHAR (20),   -- TRANSMITLOG3.tablename    
  @debug      INT = 0 )            
AS               
BEGIN            
   SET NOCOUNT ON            
   SET ANSI_NULLS OFF           
   SET ANSI_WARNINGS OFF            
   SET QUOTED_IDENTIFIER OFF            
   SET CONCAT_NULL_YIELDS_NULL OFF              
            
   DECLARE   @UniqueKey      NVARCHAR(15)    
            ,@c_R01Value     NVARCHAR(1000)    
            ,@c_R02Value     NVARCHAR(1000)        
            ,@c_R03Value     NVARCHAR(1000)        
            ,@c_R04Value   NVARCHAR(1000)        
            ,@c_R05Value     NVARCHAR(1000)   
            ,@c_SMSInfo      NVARCHAR(4000)        
            ,@Stmt           NVARCHAR(4000)    
            ,@Parm           nvarchar(100)    
            ,@mail_id        INT    
            ,@R01Name        nvarchar(128)    
            ,@R02Name        nvarchar(128)    
            ,@R03Name        nvarchar(128)    
            ,@R04Name        nvarchar(128)    
            ,@R05Name        nvarchar(128)    
            ,@R06Name        nvarchar(20)    
            ,@Err            INT        
            ,@ErrMsg         NVARCHAR(255)        
            ,@ErrSeverity    INT        
            ,@dBegin         DATETIME        
            ,@RowCount       INT        
            ,@c_AlertKey     CHAR(18)     
      
            
   DECLARE @MailQSMS table( mail_id int NOT NULL)      
   IF OBJECT_ID('tempdb..#K','u') IS NOT NULL  DROP TABLE  #K;      
   IF OBJECT_ID('tempdb..#M','u') IS NOT NULL  DROP TABLE  #M;     
   CREATE TABLE #K ( key1 nvarchar(10) NOT NULL PRIMARY KEY )      
   CREATE TABLE #M (        
     UniqueKey     NVARCHAR(15),      
     R01Value      NVARCHAR(1000),        
     R02Value      NVARCHAR(1000),        
     R03Value      NVARCHAR(1000),        
     R04Value      NVARCHAR(1000),         
     R05Value      NVARCHAR(1000),  
     SMSInfo       NVARCHAR(4000),  -- store SMS info sent  
   )        
        
   SELECT @Err = 0, @ErrMsg = '', @ErrSeverity = 0      
    
   EXEC dbo.isp_GetCodeLkup @LISTNAME , @StorerKey, @Code, 'SMSOptions' /*Code2*/, @ErrMsg OUTPUT ,@Err OUTPUT      
   , '' /*Description*/, '' /*Short*/, @R06Name OUTPUT /*Long*/, @Stmt    OUTPUT /*Notes*/, '' /*Notes2*/      
   , @R01Name OUTPUT /*UDF01*/, @R02Name OUTPUT /*UDF02*/, @R03Name OUTPUT /*UDF03*/, @R04Name OUTPUT /*UDF04*/, @R05Name OUTPUT /*UDF05*/    
       
   IF @Code = 'SOCFMSMS'    
   BEGIN    
      INSERT #K SELECT key1    
      FROM TRANSMITLOG3 t WITH (nolock)    
      WHERE tablename = @Code    
      AND   key3  = @StorerKey    
      AND  transmitflag = '0'    
      GROUP BY key1    
   END    
      
   IF @debug=1       
   BEGIN      
      SELECT * FROM #K      
      SELECT '@Stmt'= @Stmt    
   END      
    
    
   DECLARE CUR_TransmitSMS CURSOR LOCAL FAST_FORWARD READ_ONLY FOR    
   SELECT key1  FROM #K    
         
   SELECT @Err = @@ERROR        
   IF @Err <> 0        
   BEGIN        
      SET @ErrMsg = 'NSQL'+CONVERT(Char(5),@Err)+': Error when declare cursor ('+OBJECT_NAME(@@PROCID)+').'        
   END        
        
   OPEN CUR_TransmitSMS        
   FETCH NEXT FROM CUR_TransmitSMS INTO @UniqueKey             
   WHILE @@FETCH_STATUS <> -1        
   BEGIN        
      SELECT @c_R01Value = ''    
            ,@c_R02Value = ''    
            ,@c_R03Value = ''    
            ,@c_R04Value = ''    
            ,@c_R05Value = ''    
            ,@c_SMSInfo  = ''    
  
      TRUNCATE TABLE #M    
    
      UPDATE TRANSMITLOG3 SET transmitflag = '1' WHERE transmitflag = '0' --KH01      
      AND tablename=@Code AND key1=@UniqueKey AND key3=@StorerKey     
            
      SET @Parm = '@StorerKey nvarchar(15), @UniqueKey nvarchar(15), @Code nvarchar(20)'      
      BEGIN TRY     
         INSERT INTO #M    
         EXEC sp_ExecuteSql @Stmt ,@Parm ,@StorerKey ,@UniqueKey ,@Code      
         SET @RowCount = @@ROWCOUNT        
      END TRY        
      BEGIN CATCH        
         SET @ErrMsg     = ISNULL(ERROR_MESSAGE(),'');        
         SET @ErrSeverity = ISNULL(ERROR_SEVERITY(),0);        
         SET @Err = @@ERROR + 50000;        
         PRINT  @ErrMsg    
         EXECUTE nspg_getkey 'LogEvent', 18, @c_AlertKey OUTPUT, '', '', ''        
         INSERT ALERT(AlertKey, ModuleName, AlertMessage, Severity, NotifyId, Status, ResolveDate, Resolution, Storerkey, UOMQty, ID  )         
         VALUES   (@c_AlertKey,ISNULL(OBJECT_NAME(@@PROCID),''),@UniqueKey, @ErrSeverity, ISNULL(HOST_NAME(),''),@Err, DATEDIFF(s,@dBegin,GETDATE()), ISNULL(@Stmt, ''), @StorerKey, @RowCount,LEFT(@ErrMsg,20));        
         THROW @Err, @ErrMsg, 1;        
      END CATCH           
            
      SELECT   @UniqueKey       = ISNULL (UniqueKey,'')    
               ,@c_R01Value  = ISNULL (R01Value, '')     -- this row is a must for receipt name  
               ,@c_R02Value     = ISNULL (R02Value, '')     -- this row is a must for mobile no    
               ,@c_R03Value  = ISNULL (R03Value, '')      
               ,@c_R04Value     = ISNULL (R04Value, '')     
               ,@c_R05Value     = ISNULL (R05Value, '')            
               ,@c_SMSInfo     = ISNULL  (SMSInfo, '')     -- this row is a must for SMS body info  
      FROM #M    
          
      IF (@debug = 1)        
      BEGIN        
          SELECT * FROM #M        
          SELECT @RowCount 'No.RowCount'        
      END        
         
      IF @RowCount > 0        
      BEGIN         
        IF ISNULL(@c_R02Value,'')  <> ''      -- mobile no   
        BEGIN                     
            INSERT INTO [DTS].[DBMailQueue] ( mail_type    
            ,recipients    
            ,[subject]    
            ,[body]    
            ,[body_format]    
            ,[AddSource]     
            ) OUTPUT INSERTED.mail_id INTO @MailQSMS       
            VALUES ( 'SMS'    
            ,'SMS@lifung.com'    
            ,CASE WHEN @debug = 1 THEN  '60108165210'  ELSE 'R86'+@c_R02Value END  -- To sent out the SMS, infront MobileNo need put phone's number CountryCode.    
            ,@c_SMSInfo  -- SMS body  
            ,'TEXT'     
            , OBJECT_NAME(@@PROCID) )       
      
            SELECT @mail_id = mail_id FROM @MailQSMS      
      
            INSERT INTO MailQSMS ( mail_id, UniqueKeyName, UniqueKey, StorerKey, R01Name, R01, R02Name, R02, R03Name, R03, R04Name, R04, R05Name, R05)      
            VALUES(  @mail_id     
            ,'OrderKey', @UniqueKey     
            , @StorerKey    
            , @R01Name, @c_R01Value       
            , @R02Name, @c_R02Value    
            , @R03Name, @c_R03Value    
            , @R04Name, @c_R04Value    
            , @R05Name, @c_R05Value)    
                
            UPDATE TRANSMITLOG3 SET transmitflag = '9' WHERE transmitflag = '1'     
            AND tablename=@Code AND key1=@UniqueKey AND key3=@StorerKey     
        END      
     END    
     ELSE    
     BEGIN    
        SELECT @RowCount 'No.RowCount', @mail_id 'mail_id'    
     END    
         
   FETCH NEXT FROM CUR_TransmitSMS INTO  @UniqueKey             
   END        
   CLOSE CUR_TransmitSMS            
   DEALLOCATE CUR_TransmitSMS         
          
END    
GO


