IF EXISTS (SELECT name FROM dbo.sysobjects WHERE name = 'ntrPalletMgmtDetailAdd' AND type = 'TR')
   DROP TRIGGER ntrPalletMgmtDetailAdd
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO
/***************************************************************************/
/* Trigger: ntrPalletMgmtDetailAdd                                         */
/* Creation Date: 04-MAR-2016                                              */
/* Copyright: LF                                                           */
/* Written by: YTWan                                                       */
/*                                                                         */
/* Purpose: Pallet Management Maintenance Screen                           */
/*        : PalletMgmtDetail Insert Trigger                                */
/*                                                                         */
/* Return Status:                                                          */
/*                                                                         */
/* Usage:                                                                  */
/*                                                                         */
/* Called By: When records Inserted                                        */
/*                                                                         */
/* PVCS Version: 1.0                                                       */
/*                                                                         */
/* Version: 7.0                                                            */
/*                                                                         */
/* Modifications:                                                          */
/* Date         Author  Ver   Purposes                                     */
/***************************************************************************/
CREATE TRIGGER ntrPalletMgmtDetailAdd ON PALLETMGMTDETAIL
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

         , @b_debug           INT


   SET @n_Continue  = 1
   SET @n_StartTCnt = @@TRANCOUNT   

   IF EXISTS( SELECT 1 FROM INSERTED WHERE ArchiveCop = '9')
   BEGIN
      SET @n_continue = 4
      GOTO QUIT
   END

   --Checking
   IF EXISTS ( SELECT 1
               FROM  INSERTED
               JOIN  PALLETMGMT PMH WITH (NOLOCK) ON (INSERTED.PMKey = PMH.PMKey)
               WHERE PMH.Sourcetype = 'ASN'
               AND   INSERTED.Type = 'WD'
              )
   BEGIN
      SET @n_continue = 3    
      SET @n_err = 63120   -- Should Be Set To The SQL Errmessage but I don't know how to do so.    
      SET @c_errmsg= 'Invalid Withdrawal Transaction type for inbound source type. (ntrPalletMgmtDetailAdd)' 
      GOTO QUIT 
   END

   IF EXISTS ( SELECT 1
               FROM  INSERTED
               JOIN  PALLETMGMT PMH WITH (NOLOCK) ON (INSERTED.PMKey = PMH.PMKey)
               WHERE PMH.Sourcetype IN ('SO', 'LOADPLAN', 'MBOL')
               AND   INSERTED.Status < '9'
               AND   INSERTED.Type = 'DP'
              )
   BEGIN
      SET @n_continue = 3    
      SET @n_err = 63130   -- Should Be Set To The SQL Errmessage but I don't know how to do so.    
      SET @c_errmsg= 'Invalid Deposit Transaction type for outbound source type. (ntrPalletMgmtDetailAdd)' 
      GOTO QUIT 
   END

  IF EXISTS (  SELECT 1
               FROM  INSERTED
               JOIN  PALLETMGMT PMH WITH (NOLOCK) ON (INSERTED.PMKey = PMH.PMKey)
               JOIN  RECEIPT    RH  WITH (NOLOCK) ON (PMH.Facility   = RH.Facility)
                                                  AND(PMH.SourceKey  = RH.ReceiptKey)
               WHERE PMH.Sourcetype = 'ASN'
               AND   INSERTED.Status < '9'
               AND   INSERTED.FromStorerkey <> '' 
               AND   INSERTED.FromStorerkey <> ISNULL(RH.SellerName,'')
             )
   BEGIN
      SET @n_continue = 3    
      SET @n_err = 63140   -- Should Be Set To The SQL Errmessage but I don't know how to do so.    
      SET @c_errmsg= 'Invalid From Storer for inbound source transaction #. (ntrPalletMgmtDetailAdd)' 
      GOTO QUIT 
   END

  IF EXISTS (  SELECT 1
               FROM  INSERTED
               JOIN  PALLETMGMT PMH WITH (NOLOCK) ON (INSERTED.PMKey = PMH.PMKey)
               JOIN  RECEIPT    RH  WITH (NOLOCK) ON (PMH.Facility   = RH.Facility)
                                                  AND(PMH.SourceKey  = RH.ReceiptKey)
               WHERE PMH.Sourcetype = 'ASN'
               AND   INSERTED.ToStorerkey <> RH.Storerkey
             )
   BEGIN
      SET @n_continue = 3    
      SET @n_err = 63150   -- Should Be Set To The SQL Errmessage but I don't know how to do so.    
      SET @c_errmsg= 'Invalid From Storer for inbound source transaction #. (ntrPalletMgmtDetailAdd)' 
      GOTO QUIT 
   END

   IF EXISTS ( SELECT 1
               FROM  INSERTED
               JOIN  PALLETMGMT PMH WITH (NOLOCK) ON (INSERTED.PMKey = PMH.PMKey)
               LEFT JOIN  ORDERS     SO  WITH (NOLOCK) ON (PMH.Facility   = SO.Facility)
                                                       AND(PMH.SourceKey  = SO.Orderkey)
               LEFT JOIN  ORDERS     LP  WITH (NOLOCK) ON (PMH.Facility   = LP.Facility)
                                                       AND(PMH.SourceKey  = LP.Loadkey)
               LEFT JOIN  ORDERS     MB  WITH (NOLOCK) ON (PMH.Facility   = MB.Facility)
                                                       AND(PMH.SourceKey  = MB.Mbolkey)    
               WHERE PMH.Sourcetype IN ( 'SO', 'LOADPLAN', 'MBOL' )
               AND   INSERTED.Status < '9'
               AND   INSERTED.FromStorerkey <> '' AND SO.Orderkey IS NOT NULL AND INSERTED.FromStorerkey <> SO.Storerkey
               AND   INSERTED.FromStorerkey <> '' AND LP.Orderkey IS NOT NULL AND INSERTED.FromStorerkey <> LP.Storerkey
               AND   INSERTED.FromStorerkey <> '' AND MB.Orderkey IS NOT NULL AND INSERTED.FromStorerkey <> MB.Storerkey
              )
   BEGIN
      SET @n_continue = 3    
      SET @n_err = 63160   -- Should Be Set To The SQL Errmessage but I don't know how to do so.    
      SET @c_errmsg= 'Invalid From Storer for outbound source transaction #. (ntrPalletMgmtDetailAdd)' 
      GOTO QUIT 
   END

   IF EXISTS ( SELECT 1
               FROM  INSERTED
               JOIN  PALLETMGMT PMH WITH (NOLOCK) ON (INSERTED.PMKey = PMH.PMKey)
               LEFT JOIN  ORDERS     SO  WITH (NOLOCK) ON (PMH.Facility   = SO.Facility)
                                                       AND(PMH.SourceKey  = SO.Orderkey)
               LEFT JOIN  ORDERS     LP  WITH (NOLOCK) ON (PMH.Facility   = LP.Facility)
                                                       AND(PMH.SourceKey  = LP.Loadkey)
               LEFT JOIN  ORDERS     MB  WITH (NOLOCK) ON (PMH.Facility   = MB.Facility)
                                                       AND(PMH.SourceKey  = MB.Mbolkey)                                                   
                                                      
               WHERE PMH.Sourcetype IN ( 'SO', 'LOADPLAN', 'MBOL' )
               AND   INSERTED.Status < '9'
               AND   INSERTED.ToStorerkey <> '' AND SO.Orderkey IS NOT NULL AND INSERTED.ToStorerkey <> SO.Consigneekey
               AND   INSERTED.ToStorerkey <> '' AND LP.Orderkey IS NOT NULL AND INSERTED.ToStorerkey <> LP.Consigneekey
               AND   INSERTED.ToStorerkey <> '' AND MB.Orderkey IS NOT NULL AND INSERTED.ToStorerkey <> MB.Consigneekey
              )
   BEGIN
      SET @n_continue = 3    
      SET @n_err = 63170   -- Should Be Set To The SQL Errmessage but I don't know how to do so.    
      SET @c_errmsg= 'Invalid To Storer for outbound source transaction #. (ntrPalletMgmtDetailAdd)' 
      GOTO QUIT 
   END
QUIT:
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

      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrPalletMgmtDetailAdd'    
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

