/***************************************************************************************************/          
/* Trigger: ntrTransmitlog2Update                                                                  */          
/* Creation Date:                                                                                  */          
/* Copyright: IDS                                                                                  */          
/* Written by:                                                                                     */          
/*                                                                                                 */          
/* Purpose:   Transmitlog2 Update Trigger                                                          */          
/*                                                                                                 */          
/* Usage:                                                                                          */          
/*                                                                                                 */          
/* Called By: When records added into OrderHeader                                                  */          
/*                                                                                                 */          
/* PVCS Version: 1.4                                                                               */          
/*                                                                                                 */          
/* Version: 5.4                                                                                    */          
/*                                                                                                 */          
/* Data Modifications:                                                                             */          
/* Date           Author      Ver   Purposes                                                       */          
/* 17-Mar-2009    TLTING      1.0   Change user_name() to SUSER_SNAME()                            */          
/* 28-Oct-2013    TLTING      1.1   Review Editdate column update                                  */          
/* 30-Jun-2016    KTLow       1.2   Retrigger Queue Commander Process (KT01)                       */          
/*                                  Add TrafficCop = NULL (KT01)                                   */          
/* 02-Oct-2018    TLTING      1.3   log and block bulk update                                      */          
/* 22-Sep-2020    TLTING      1.4   new service account                                            */         
/* 15-03-2023     kelvinongcy 1.5   WMS-21595 Delete WSDT_GENERIC_COURIER                          */        
/*                                  when retrigger TML2 (kocy01)                                   */   
/* 27-03-2023     kelvinongcy 1.6   Big fix to filter needed Storer existance based StorerConfig   */  
/*                                  to only trigger WSDT_GENERIC_COURIER deletion (kocy02)         */  
/***************************************************************************************************/          
CREATE OR ALTER TRIGGER [dbo].[ntrTransmitlog2Update]          
ON  [dbo].[TRANSMITLOG2]          
FOR UPDATE          
AS          
BEGIN           
  IF @@ROWCOUNT = 0          
 BEGIN          
  RETURN          
 END          
          
  SET NOCOUNT ON          
  SET ANSI_NULLS OFF          
  SET QUOTED_IDENTIFIER OFF          
  SET CONCAT_NULL_YIELDS_NULL OFF          
          
  DECLARE @b_debug int          
  SELECT @b_debug = 0          
        
  DECLARE   @b_Success     int                 
         , @n_err          int                 
         , @n_err2         int                 
         , @c_errmsg       NVARCHAR(250)           
         , @n_continue     int          
         , @n_starttcnt    int          
         , @c_preprocess   NVARCHAR(250)           
         , @c_pstprocess   NVARCHAR(250)          
         , @n_cnt          int          
         --(KT01) - Start          
         , @c_TransmitlogKey        NVARCHAR(10)          
         , @c_TableName             NVARCHAR(30)          
         , @c_Key1                  NVARCHAR(10)          
         , @c_Key2                  NVARCHAR(5)           
         , @c_Key3                  NVARCHAR(20)          
         , @c_TransmitBatch         NVARCHAR(30)          
         , @c_DeletedTransmitFlag   NVARCHAR(5)                  
         , @c_QCommd_SPName         NVARCHAR(1024)                        
         , @c_Exist                 CHAR(1)                
         , @c_ExecStatements        NVARCHAR(4000)                
         , @c_ExecArguments         NVARCHAR(4000)                             
         --(KT01) - End          
         , @c_RecordID                       INT       
         , @c_OrderKey     NVARCHAR (15)       
         , @c_StorerKey                      NVARCHAR (15)          
         , @c_DEL_WSDT_GENERIC_COURIER_Exist NVARCHAR(10)          
         , @c_Option1                        NVARCHAR(50)        
         , @c_Option2                        NVARCHAR(50)        
                 
          
 SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT          
 IF UPDATE(ArchiveCop)          
 BEGIN          
  SELECT @n_continue = 4           
 END          
          
 --(KT01) - Start          
 IF UPDATE(TrafficCop)          
 BEGIN          
  SELECT @n_continue = 4           
 END          
 --(KT01) - End          
           
 IF ( @n_continue = 1 or @n_continue = 2 ) AND NOT UPDATE(EditDate)          
 BEGIN            
  UPDATE TRANSMITLOG2           
  SET EditDate = GETDATE()          
   ,EditWho = SUSER_SNAME()          
   ,Trafficcop = NULL          
  FROM TRANSMITLOG2, INSERTED          
  WHERE TRANSMITLOG2.TRANSMITLOGKey = INSERTED.TRANSMITLOGKey          
          
  SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT          
   IF @n_err <> 0          
  BEGIN          
   SELECT @n_continue = 3          
   SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=72804   -- Should Be Set To The SQL Errmessage but I don't know how to do so.          
   SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Update Failed On Table TRANSMITLOG2. (ntrTRANSMITLOG2Update)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "          
  END          
 END          
             
   IF ( (Select count(1) FROM  TRANSMITLOG2 (NOLOCK), INSERTED          
       WHERE TRANSMITLOG2.TRANSMITLOGKey = INSERTED.TRANSMITLOGKey ) > 50 )           
       AND Suser_sname() not in ('iml','dts','itadmin', 'QCmdUser', 'alpha\wmsadmingt','mctang', 'kwhchan', 'JovineNg', 'ALPHA\SRVwmsadminlfl', 'ALPHA\SRVwmsadmincn'    )          
   BEGIN          
         --Declare @c_Progname nvarchar(20)          
         --Declare @c_Username nvarchar(20)          
          
         --select @c_Progname= program_name , @c_Username = loginame from master.sys.sysprocesses where spid = @@SPID          
          
          
         --INSERT INTO TRACEINFO ( TraceName , TimeIn, Col1 ,Col2 , Col3 , Col4 , Col5 )             
         --Select  'ntrTransmitlog2Update', GETDATE(), Suser_sname(), INSERTED.tablename,cast(count(5) as nvarchar),@c_Progname,''          
         --FROM   TRANSMITLOG2, INSERTED          
         --WHERE TRANSMITLOG2.TRANSMITLOGKey = INSERTED.TRANSMITLOGKey            
         --group by   INSERTED.tablename          
                
         SELECT @n_continue = 3          
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=72814   -- Should Be Set To The SQL Errmessage but I don't know how to do so.          
         SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Update Failed On Table TRANSMITLOG2. Batch Update not allow! (ntrTransmitlog2Update)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "          
                    
   END          
           
   --kocy01 (S)        
   IF ( @n_continue = 1 or @n_continue = 2 )        
   BEGIN      
               
         SELECT @c_StorerKey = StorerKey      
               ,@c_DEL_WSDT_GENERIC_COURIER_Exist = ISNULL (SVALUE, 0)      
               ,@c_Option1  = Option1      
               ,@c_Option2 = Option2      
         FROM DELETED       -- kocy02  
         JOIN StorerConfig sc  WITH (NOLOCK) ON sc.StorerKey = DELETED.key3  
         WHERE ConfigKey = 'DelWSDTGenericCourier'      
      
        IF @c_DEL_WSDT_GENERIC_COURIER_Exist = 1 AND NOT UPDATE (EditDate)      
        BEGIN      
            DECLARE C_TML2 CURSOR LOCAL FAST_FORWARD READ_ONLY FOR          
            SELECT C.RecordID        
            FROM DELETED           
            JOIN INSERTED ON DELETED.transmitlogkey = INSERTED.transmitlogkey          
            JOIN ORDERS (NOLOCK) ON ORDERS.OrderKey = DELETED.key1 AND ORDERS.StorerKey = DELETED.key3         
            JOIN [DTS].[WSDT_GENERIC_COURIER] C WITH (NOLOCK) ON C.OrderKey = DELETED.key1 AND C.StorerKey = DELETED.key3      
            WHERE DELETED.key3 = @c_StorerKey      
            AND DELETED.tablename IN (@c_Option1,@c_Option2 )      
            AND DELETED.transmitflag = '9'          
            AND INSERTED.transmitflag = '0'          
         
            OPEN C_TML2          
            FETCH NEXT FROM C_TML2 INTO  @c_RecordID      
            WHILE @@FETCH_STATUS = 0          
            BEGIN          
               DELETE FROM [DTS].[WSDT_GENERIC_COURIER] WHERE RecordID = @c_RecordID       
                                   
            FETCH NEXT FROM C_TML2 INTO @c_RecordID         
            END          
            CLOSE C_TML2          
            DEALLOCATE C_TML2          
        
            SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT          
            IF @n_err <> 0          
            BEGIN          
               SELECT @n_continue = 3          
               SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=72804   -- Should Be Set To The SQL Errmessage but I don't know how to do so.          
               SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+":Delete [DTS].[WSDT_GENERIC_COURIER] Failed On Table TRANSMITLOG2. (ntrTRANSMITLOG2Update)"         
                              + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "          
            END          
      END            
   END          
   --kocy01 (E)        
        
          
   IF @n_continue=3  -- Error Occured - Process And Return          
   BEGIN          
    IF @@TRANCOUNT = 1 and @@TRANCOUNT >= @n_starttcnt          
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
    EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrTransmitlog2Update'          
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
END   