
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/***************************************************************************/
/* Trigger: ntrMasterSerialNoAdd                                           */
/* Creation Date: 26-May-2017                                              */
/* Copyright: MAERSK                                                       */
/* Written by: ChewKP                                                      */
/*                                                                         */
/* Purpose: Trigger transaction log to MasterSerialNoTrn table             */
/*        : WMS-1931,                                                      */
/*                                                                         */
/* Return Status:                                                          */
/*                                                                         */
/* Usage:                                                                  */
/*                                                                         */
/* Called By: When records Added                                           */
/*                                                                         */
/* PVCS Version: 1.3                                                       */
/*                                                                         */
/* Version: 5.4                                                            */
/*                                                                         */
/* Modifications:                                                          */
/* Date         Author   Ver  Purposes                                     */
/* 06-OCT-2025  AK01     1.1  UWP-42143 Data Audit                         */
/***************************************************************************/
CREATE OR ALTER TRIGGER ntrMasterSerialNoAdd ON MasterserialNo
FOR INSERT
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_Continue        INT                     
         , @n_StartTCnt       INT            -- Holds the current transaction count    
         , @b_Success         INT            -- Populated by calls to stored procedures - was the proc successful?    
         , @n_err             INT            -- Error number returned by stored procedure or this trigger    
         , @c_errmsg          NVARCHAR(255)  -- Error message returned by stored procedure or this trigger    

 

   SET @n_Continue  = 1
   SET @n_StartTCnt = @@TRANCOUNT   
   
   

   IF EXISTS( SELECT 1 FROM INSERTED WHERE ArchiveCop = '9')
   BEGIN
      SET @n_continue = 4
      GOTO QUIT
   END
   
   IF EXISTS( SELECT 1 FROM INSERTED WHERE TrafficCop = '9' )  
   BEGIN  
      SELECT @n_continue = 4  
      GOTO QUIT
   END  
   
   

   IF (@n_Continue = 1 OR @n_Continue = 2) 
   BEGIN 
      INSERT INTO dbo.MasterSerialNoTrn (
                     	 MasterSerialNoKey   ,TranType         ,LocationCode 	,UnitType 	      ,PartnerType 	,SerialNo 	      ,ElectronicSN 	,Storerkey	
                     	,Sku              	,ItemID 	         ,ItemDescr 	   ,ChildQty	      ,ParentSerialNo	,ParentSku 	   ,ParentItemID 	  
                     	,ParentProdLine	   ,VendorSerialNo	,VendorLotNo 	,LotNo 	         ,Revision	      ,CreationDate	,Source 	      
                     	,Status 	            ,Attribute1 	   ,Attribute2 	,Attribute3       ,RequestID 	      ,UserDefine01 	,UserDefine02 	
                     	,UserDefine03 	      ,UserDefine04 	   ,UserDefine05 	 )
      SELECT MasterSerialNoKey   ,'DP'             ,LocationCode 	,UnitType 	      ,PartnerType 	   ,SerialNo 	      ,ElectronicSN 	,Storerkey	
            ,Sku              	,ItemID 	         ,ItemDescr 	   ,ChildQty	      ,ParentSerialNo	,ParentSku 	   ,ParentItemID 	  
            ,ParentProdLine	   ,VendorSerialNo	,VendorLotNo 	,LotNo 	         ,Revision	      ,CreationDate	,Source 	      
            ,Status 	            ,Attribute1 	   ,Attribute2 	,Attribute3       ,RequestID 	      ,UserDefine01 	,UserDefine02 	
            ,UserDefine03 	      ,UserDefine04 	   ,UserDefine05  
      FROM INSERTED
      
      IF @@ERROR <> 0 
      BEGIN
          SELECT @n_continue = 3
                ,@n_err = 63210
          SELECT @c_errmsg = "NSQL"+CONVERT(CHAR(5) ,@n_err)+
                 ": Insert into MasterSerialNoTrn Failed - Insert Failed. (ntrMasterSerialNoAdd)"
      END
      
   END
   
   --AK01 - S
   IF dbo.fnc_GetUserName() <> sUser_sName() AND @n_Continue IN (1,2) 
   BEGIN
      UPDATE MasterSerialNo
        SET AddWho  = dbo.fnc_GetUserName(),
            AddDate = dbo.fnc_GetDate(), 
            TrafficCop = NULL 
      FROM MasterSerialNo
      JOIN INSERTED ON MasterSerialNo.MasterSerialNoKey = INSERTED.MasterSerialNoKey
      SELECT @n_err = @@ERROR
      IF @n_err <> 0
      BEGIN
         SELECT @n_continue = 3
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=63211 
         SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Failed On Table MasterSerialNo. (ntrMasterSerialNoAdd)' + ' ( ' + ' SQLSvr MESSAGE=' + TRIM(@c_errmsg) + ' ) '
      END
   END
   --AK01 - E


QUIT:
--   IF CURSOR_STATUS( 'LOCAL', 'CUR_JOB') in (0 , 1)  
--   BEGIN
--      CLOSE CUR_JOB
--      DEALLOCATE CUR_JOB
--   END

--   IF CURSOR_STATUS( 'LOCAL', 'CUR_JOBOP') in (0 , 1)  
--   BEGIN
--      CLOSE CUR_JOBOP
--      DEALLOCATE CUR_JOBOP
--   END

   /* #INCLUDE <TRRDA2.SQL> */    
   IF @n_Continue=3  -- Error Occured - Process And Return    
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

      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrMasterSerialNoAdd'    
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR  

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
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

