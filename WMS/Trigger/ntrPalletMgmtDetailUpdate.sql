IF EXISTS (SELECT name FROM dbo.sysobjects WHERE name = 'ntrPalletMgmtDetailUpdate' AND type = 'TR')
   DROP TRIGGER ntrPalletMgmtDetailUpdate
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO
/***************************************************************************/
/* Trigger: ntrPalletMgmtDetailUpdate                                      */
/* Creation Date: 03-Mar-2016                                              */
/* Copyright: LF                                                           */
/* Written by: YTWan                                                       */
/*                                                                         */
/* Purpose: Pallet Management Maintenance Screen                           */
/*        : PalletMgmtdetail Update Trigger                                */
/*                                                                         */
/* Return Status:                                                          */
/*                                                                         */
/* Usage:                                                                  */
/*                                                                         */
/* Called By: When records Update                                          */
/*                                                                         */
/* PVCS Version: 1.0                                                       */
/*                                                                         */
/* Version: 7.0                                                            */
/*                                                                         */
/* Modifications:                                                          */
/* Date         Author  Ver   Purposes                                     */
/***************************************************************************/
CREATE TRIGGER ntrPalletMgmtDetailUpdate ON PALLETMGMTDETAIL
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

   DECLARE @n_Continue        INT                     
         , @n_StartTCnt       INT            -- Holds the current transaction count    
         , @b_Success         INT            -- Populated by calls to stored procedures - was the proc successful?    
         , @n_err             INT            -- Error number returned by stored procedure or this trigger    
         , @c_errmsg          NVARCHAR(255)  -- Error message returned by stored procedure or this trigger  
  
         , @c_PMTranKey       NVARCHAR(10)
         , @c_SourceKey       NVARCHAR(20)
         
         , @c_Facility        NVARCHAR(10)
         , @c_PMKey           NVARCHAR(10)
         , @c_PMLineNumber    NVARCHAR(5)
         , @c_FromStorerkey   NVARCHAR(15) 
         , @c_ToStorerkey     NVARCHAR(15)
         , @c_Storerkey       NVARCHAR(15) 
         , @c_AccountNo       NVARCHAR(30)
         , @c_Type            NVARCHAR(10)
         , @c_PalletType      NVARCHAR(30)
         , @n_Qty             INT

   SET @n_Continue  = 1
   SET @n_StartTCnt = @@TRANCOUNT   

   IF UPDATE(ArchiveCop)
   BEGIN
      SET @n_Continue = 4
      GOTO QUIT
   END

   IF ( @n_continue=1 or @n_continue=2 ) AND NOT UPDATE(EditDate)
   BEGIN
      UPDATE PALLETMGMTDETAIL WITH (ROWLOCK)
      SET EditDate = GETDATE() 
         ,EditWho  = SUSER_SNAME() 
         ,TrafficCop = NULL
      FROM PALLETMGMTDETAIL
      JOIN DELETED  ON (DELETED.PMKey = PALLETMGMTDETAIL.PMKey)
      JOIN INSERTED ON (DELETED.PMKey = INSERTED.PMKey)
      WHERE ( DELETED.Status < '9' OR DELETED.Status < '9' )

      SET @n_err = @@ERROR
      IF @n_err <> 0
      BEGIN
         SET @n_continue = 3
         SET @c_errmsg = CONVERT(CHAR(250),@n_err)
         SET @n_err = 63210  -- Should Be Set To The SQL Errmessage but I don't know how to do so.
         SET @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Failed On Table PALLETMGMTDETAIL. (ntrPalletMgmtDetailUpdate)'
                      + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '
         GOTO QUIT
      END
   END

   IF UPDATE(TrafficCop)
   BEGIN
      SET @n_Continue = 4
      GOTO QUIT
   END

   IF EXISTS ( SELECT 1
               FROM  INSERTED
               JOIN  DELETED ON (INSERTED.PMKey = DELETED.PMKey)
                             AND(INSERTED.PMLineNumber = DELETED.PMLineNumber)
               JOIN  PALLETMGMT PMH WITH (NOLOCK) ON (INSERTED.PMKey = PMH.PMKey)
               WHERE PMH.Sourcetype = 'ASN'
               AND   DELETED.Status < '9' 
               AND   INSERTED.Type = 'WD'
              )
   BEGIN
      SET @n_continue = 3    
      SET @n_err = 63220   -- Should Be Set To The SQL Errmessage but I don't know how to do so.    
      SET @c_errmsg= 'Invalid Withdrawal Transaction type for inbound source type. (ntrPalletMgmtDetailUpdate)' 
      GOTO QUIT 
   END

   IF EXISTS ( SELECT 1
               FROM  INSERTED
               JOIN  DELETED ON (INSERTED.PMKey = DELETED.PMKey)
                             AND(INSERTED.PMLineNumber = DELETED.PMLineNumber)
               JOIN  PALLETMGMT PMH WITH (NOLOCK) ON (INSERTED.PMKey = PMH.PMKey)
               WHERE PMH.Sourcetype IN ('SO', 'LOADPLAN', 'MBOL' )
               AND   DELETED.Status < '9' 
               AND   INSERTED.Type = 'DP'
              )
   BEGIN
      SET @n_continue = 3    
      SET @n_err = 63230   -- Should Be Set To The SQL Errmessage but I don't know how to do so.    
      SET @c_errmsg= 'Invalid Deposit Transaction type for outbound source type. (ntrPalletMgmtUpdate)' 
      GOTO QUIT 
   END

   IF EXISTS ( SELECT 1
               FROM  INSERTED
               JOIN  DELETED   ON (INSERTED.PMKey = DELETED.PMKey)
                               AND(INSERTED.PMLineNumber = DELETED.PMLineNumber)
               JOIN  PALLETMGMT PMH WITH (NOLOCK) ON (INSERTED.PMKey = PMH.PMKey)
               LEFT JOIN  ORDERS     SO  WITH (NOLOCK) ON (PMH.Facility   = SO.Facility)
                                                       AND(PMH.SourceKey  = SO.Orderkey)
               LEFT JOIN  ORDERS     LP  WITH (NOLOCK) ON (PMH.Facility   = LP.Facility)
                                                       AND(PMH.SourceKey  = LP.Loadkey)
               LEFT JOIN  ORDERS     MB  WITH (NOLOCK) ON (PMH.Facility   = MB.Facility)
                                                       AND(PMH.SourceKey  = MB.Mbolkey)    
               WHERE PMH.Sourcetype IN ( 'SO', 'LOADPLAN', 'MBOL' )
               AND   DELETED.Status < '9' 
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
               JOIN  DELETED   ON (INSERTED.PMKey = DELETED.PMKey)
                               AND(INSERTED.PMLineNumber = DELETED.PMLineNumber)
               JOIN  PALLETMGMT PMH WITH (NOLOCK) ON (INSERTED.PMKey = PMH.PMKey)
               LEFT JOIN  ORDERS     SO  WITH (NOLOCK) ON (PMH.Facility   = SO.Facility)
                                                       AND(PMH.SourceKey  = SO.Orderkey)
               LEFT JOIN  ORDERS     LP  WITH (NOLOCK) ON (PMH.Facility   = LP.Facility)
                                                       AND(PMH.SourceKey  = LP.Loadkey)
               LEFT JOIN  ORDERS     MB  WITH (NOLOCK) ON (PMH.Facility   = MB.Facility)
                                                       AND(PMH.SourceKey  = MB.Mbolkey)                                                   
               WHERE PMH.Sourcetype IN ( 'SO', 'LOADPLAN', 'MBOL' )
               AND   DELETED.Status < '9' 
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

   DECLARE CUR_PMDET CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT PALLETMGMT.Facility
         ,INSERTED.PMKey
         ,INSERTED.PMLineNumber
         ,INSERTED.FromStorerkey
         ,INSERTED.ToStorerkey
         ,INSERTED.PMAccountNo
         ,INSERTED.Type
         ,INSERTED.PalletType
         ,INSERTED.Qty 
   FROM   INSERTED
   JOIN   DELETED ON (INSERTED.PMKey = DELETED.PMKey)
                  AND(INSERTED.PMLineNumber = DELETED.PMLineNumber)
   JOIN   PALLETMGMT WITH (NOLOCK) ON (INSERTED.PMKey = PALLETMGMT.PMKey)
   WHERE  INSERTED.Status = '9'
   AND    DELETED.Status < '9'
   AND    INSERTED.Qty > 0

   OPEN CUR_PMDET

   FETCH NEXT FROM CUR_PMDET INTO @c_Facility
                                 ,@c_PMKey
                                 ,@c_PMLineNumber
                                 ,@c_FromStorerkey
                                 ,@c_ToStorerkey
                                 ,@c_AccountNo
                                 ,@c_Type
                                 ,@c_PalletType
                                 ,@n_Qty

   WHILE @@FETCH_STATUS <> -1 AND (@n_Continue = 1 OR @n_Continue = 2)
   BEGIN
      SET @c_SourceKey = RTRIM(@c_PMKey) + RTRIM(@c_PMLineNumber)

      IF @c_Type IN ('WD', 'TRF')
      BEGIN
         SET @b_success = 1
         EXECUTE nspg_getkey
         'PMTranKey'
         , 10
         , @c_PMTranKey  OUTPUT
         , @b_success   OUTPUT
         , @n_err       OUTPUT
         , @c_errmsg    OUTPUT

         IF NOT @b_success = 1
         BEGIN
            SET @n_continue = 3
            SET @n_err = 63240
            SET @c_errmsg = 'ntrPalletMgmtDetailUpdate: ' +RTRIM(@c_errmsg)
            GOTO QUIT
         END

         --SET @n_Qty = -ABS(@n_Qty)
         
         INSERT INTO PMTRN
           (
             PMTranKey
            ,TranType
            ,Facility
            ,StorerKey
            ,AccountNo
            ,PalletType
            ,SourceKey
            ,SourceType
            ,Qty
            ,EffectiveDate
            ,AddWho 
            ,AddDate 
            ,EditWho 
            ,EditDate 
           )
         VALUES
           (
             @c_PMTranKey
            ,'WD'
            ,@c_Facility 
            ,@c_FromStorerkey
            ,@c_AccountNo
            ,@c_PalletType
            ,@c_SourceKey
            ,'ntrPalletMgmtDetailUpdate'
            ,-ABS(@n_Qty)
            ,GETDATE()
            ,SUSER_NAME()
            ,GETDATE()
            ,SUSER_NAME()
            ,GETDATE()
           )
         SET @n_err = @@ERROR

         IF @n_err <> 0
         BEGIN
            SET @n_continue = 3
            SET @c_errmsg = CONVERT(CHAR(250),@n_err)
            SET @n_err = 63250  -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SET @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Insert Failed On to Table PMTRN. (ntrPalletMgmtDetailUpdate)'
                      + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '
            GOTO QUIT
         END
      END

      IF @c_Type IN ('DP', 'TRF')
      BEGIN
         SET @b_success = 1
         EXECUTE  nspg_getkey
         'PMTranKey'
         , 10
         , @c_PMTranKey  OUTPUT
         , @b_success   OUTPUT
         , @n_err       OUTPUT
         , @c_errmsg    OUTPUT

         IF NOT @b_success = 1
         BEGIN
            SET @n_continue = 3
            SET @c_errmsg = CONVERT(CHAR(250),@n_err)
            SET @n_err = 63260
            SET @c_errmsg = 'nspItrnAddWithdrawal: ' +RTRIM(@c_errmsg)
            GOTO QUIT
         END

         INSERT INTO PMTRN
           (
             PMTranKey
            ,TranType
            ,Facility
            ,StorerKey
            ,AccountNo
            ,PalletType
            ,SourceKey
            ,SourceType
            ,Qty
            ,EffectiveDate
            ,AddWho 
            ,AddDate 
            ,EditWho 
            ,EditDate 
           )
         VALUES
           (
             @c_PMTranKey
            ,'DP' 
            ,@c_Facility
            ,@c_ToStorerKey
            ,@c_AccountNo
            ,@c_PalletType
            ,@c_SourceKey
            ,'ntrPalletMgmtDetailUpdate'
            ,@n_Qty
            ,GETDATE()
            ,SUSER_NAME()
            ,GETDATE()
            ,SUSER_NAME()
            ,GETDATE()
           )
         SET @n_err = @@ERROR

         IF @n_err <> 0
         BEGIN
            SET @n_continue = 3
            SET @c_errmsg = CONVERT(CHAR(250),@n_err)
            SET @n_err = 63270  -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SET @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Insert Failed On to Table PMTRN. (ntrPalletMgmtDetailUpdate)'
                      + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '

            GOTO QUIT
         END
      END

      FETCH NEXT FROM CUR_PMDET INTO @c_Facility
                                    ,@c_PMKey
                                    ,@c_PMLineNumber
                                    ,@c_FromStorerkey
                                    ,@c_ToStorerkey
                                    ,@c_AccountNo
                                    ,@c_Type
                                    ,@c_PalletType
                                    ,@n_Qty
   END -- While 
   CLOSE CUR_PMDET
   DEALLOCATE CUR_PMDET
QUIT:
   IF CURSOR_STATUS( 'LOCAL', 'CUR_PMDET') in (0 , 1)  
   BEGIN
      CLOSE CUR_PMDET
      DEALLOCATE CUR_PMDET
   END

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

      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrPalletMgmtDetailUpdate'    
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

