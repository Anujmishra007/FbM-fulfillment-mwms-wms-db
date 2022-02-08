CREATE TABLE [dbo].[PALLETMGMT]
(
[PMKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PALLETMGMT_PMKey] DEFAULT (''),
[Sourcekey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PALLETMGMT_Sourcekey] DEFAULT (''),
[Sourcetype] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PALLETMGMT_Sourcetype] DEFAULT (''),
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PALLETMGMT_Facility] DEFAULT (''),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PALLETMGMT_Status] DEFAULT ('0'),
[DispatchDate] [datetime] NULL,
[DeliveryDate] [datetime] NULL,
[EffectiveDate] [datetime] NULL,
[Addwho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PALLETMGMT_Addwho] DEFAULT (suser_sname()),
[Adddate] [datetime] NULL CONSTRAINT [DF_PALLETMGMT_Adddate] DEFAULT (getdate()),
[Editwho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PALLETMGMT_Editwho] DEFAULT (suser_sname()),
[Editdate] [datetime] NULL CONSTRAINT [DF_PALLETMGMT_Editdate] DEFAULT (getdate()),
[Trafficcop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Archivecop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/***************************************************************************/
/* Trigger: ntrPalletMgmtDelete                                            */
/* Creation Date: 03-MAR-2016                                              */
/* Copyright: LF                                                           */
/* Written by: YTWan                                                       */
/*                                                                         */
/* Purpose: Pallet Management Maintenance Screen                           */
/*        : PalletMgmt Delete Trigger                                      */
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
/* Date         Author   Ver  Purposes                                     */
/***************************************************************************/
CREATE TRIGGER [dbo].[ntrPalletMgmtDelete] ON [dbo].[PALLETMGMT]
FOR DELETE
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
         , @c_authority       NVARCHAR(10)

   SET @n_Continue  = 1
   SET @n_StartTCnt = @@TRANCOUNT   

   IF EXISTS( SELECT 1 FROM DELETED WHERE ArchiveCop = '9')
   BEGIN
      SET @n_continue = 4
      GOTO QUIT
   END

   IF EXISTS ( SELECT 1
               FROM DELETED 
               JOIN PALLETMGMTDETAIL WITH (NOLOCK) ON (DELETED.PMKey = PALLETMGMTDETAIL.PMKey)
               WHERE PALLETMGMTDETAIL.Status = '9'
             ) 
   BEGIN
      SET @n_continue = 3
      SET @n_err = 63810
      SET @c_ErrMsg='Not Allow to delete posted Pallet Management. (ntrPalletMgmtDelete)' 
      GOTO QUIT               
   END

   DELETE PALLETMGMTDETAIL WITH (ROWLOCK)
   FROM DELETED
   JOIN PALLETMGMTDETAIL ON (DELETED.PMKey = PALLETMGMTDETAIL.PMKey)
 
   SET @n_err = @@ERROR
   IF @n_err <> 0
   BEGIN
      SET @n_continue = 3
      SET @c_errmsg = CONVERT(CHAR(250),@n_err)
      SET @n_err = 63820   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
      SET @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Delete Trigger On Table PALLETMGMTDETAIL Failed. (ntrPalletMgmtDelete)' 
                   + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
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

      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrPalletMgmtDelete'    
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
/***************************************************************************/
/* Trigger: ntrPalletMgmtUpdate                                            */
/* Creation Date: 03-Mar-2016                                              */
/* Copyright: LF                                                           */
/* Written by: YTWan                                                       */
/*                                                                         */
/* Purpose: Pallet Management Maintenance Screen                           */
/*        : PalletMgmt Update Trigger                                      */
/*                                                                         */
/* Return Status:                                                          */
/*                                                                         */
/* Usage:                                                                  */
/*                                                                         */
/* Called By: When records Updated                                         */
/*                                                                         */
/* PVCS Version: 1.0                                                       */
/*                                                                         */
/* Version: 7.0                                                            */
/*                                                                         */
/* Modifications:                                                          */
/* Date         Author  Ver   Purposes                                     */
/***************************************************************************/
CREATE TRIGGER [dbo].[ntrPalletMgmtUpdate] ON [dbo].[PALLETMGMT]
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

         , @b_debug           INT

   SET @n_Continue  = 1
   SET @n_StartTCnt = @@TRANCOUNT   

   IF UPDATE(ArchiveCop)
   BEGIN
      SET @n_Continue = 4
      GOTO QUIT
   END

   IF ( @n_continue=1 or @n_continue=2 ) AND NOT UPDATE(EditDate)
   BEGIN
      UPDATE PALLETMGMT WITH (ROWLOCK)
      SET EditDate = GETDATE() 
         ,EditWho  = SUSER_SNAME() 
         ,TrafficCop = NULL
      FROM PALLETMGMT
      JOIN DELETED  ON (DELETED.PMKey = PALLETMGMT.PMKey)
      JOIN INSERTED ON (DELETED.PMKey = INSERTED.PMKey)
      WHERE ( DELETED.Status < '9' OR DELETED.Status < '9' )

      SET @n_err = @@ERROR
      IF @n_err <> 0
      BEGIN
         SET @n_continue = 3
         SET @n_err = 63210  -- Should Be Set To The SQL Errmessage but I don't know how to do so.
         SET @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Failed On Table PALLETMGMT. (ntrPalletMgmtUpdate)'
                      + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '
         GOTO QUIT
      END
   END

   IF UPDATE(TrafficCop)
   BEGIN
      SET @n_Continue = 4
      GOTO QUIT
   END
  
   --Checking
   IF EXISTS ( SELECT 1
               FROM  INSERTED
               JOIN  DELETED ON (INSERTED.PMKey = DELETED.PMKey)
               JOIN  PALLETMGMTDETAIL PMD WITH (NOLOCK) ON (INSERTED.PMKey = PMD.PMKey)
               LEFT JOIN  ORDERS      SO  WITH (NOLOCK) ON (INSERTED.Facility   = SO.Facility)
                                                        AND(INSERTED.SourceKey  = SO.Orderkey)
               LEFT JOIN  ORDERS      LP  WITH (NOLOCK) ON (INSERTED.Facility   = LP.Facility)
                                                        AND(INSERTED.SourceKey  = LP.Loadkey)
               LEFT JOIN  ORDERS      MB  WITH (NOLOCK) ON (INSERTED.Facility   = MB.Facility)
                                                        AND(INSERTED.SourceKey  = MB.Mbolkey)  
               WHERE INSERTED.Sourcetype = 'ASN'
               AND INSERTED.Sourcekey <> '' 
               AND PMD.Type = 'WD'
              )
   BEGIN
      SET @n_continue = 3    
      SET @n_err = 63220   -- Should Be Set To The SQL Errmessage but I don't know how to do so.    
      SET @c_errmsg= 'Unmatch Inbound Source type with Withdrawal PM Transaction type. (ntrPalletMgmtUpdate)' 
      GOTO QUIT 
   END

   IF EXISTS ( SELECT 1
               FROM  INSERTED
               JOIN  DELETED ON (INSERTED.PMKey = DELETED.PMKey)
               JOIN  PALLETMGMTDETAIL PMD WITH (NOLOCK) ON (INSERTED.PMKey = PMD.PMKey)
               LEFT JOIN  ORDERS      SO  WITH (NOLOCK) ON (INSERTED.Facility   = SO.Facility)
                                                        AND(INSERTED.SourceKey  = SO.Orderkey)
               LEFT JOIN  ORDERS      LP  WITH (NOLOCK) ON (INSERTED.Facility   = LP.Facility)
                                                        AND(INSERTED.SourceKey  = LP.Loadkey)
               LEFT JOIN  ORDERS      MB  WITH (NOLOCK) ON (INSERTED.Facility   = MB.Facility)
                                                        AND(INSERTED.SourceKey  = MB.Mbolkey)  
               WHERE INSERTED.Sourcetype IN ('SO', 'LOADPLAN', 'MBOL' )
               AND INSERTED.Sourcekey <> '' 
               AND PMD.Type = 'DP'
              )
   BEGIN
      SET @n_continue = 3    
      SET @n_err = 63230   -- Should Be Set To The SQL Errmessage but I don't know how to do so.    
      SET @c_errmsg= 'Unmatch Outbound Source type with Deposit PM Transaction type. (ntrPalletMgmtUpdate)' 
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

      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrPalletMgmtUpdate'    
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
ALTER TABLE [dbo].[PALLETMGMT] ADD CONSTRAINT [PK_PALLETMGMT] PRIMARY KEY CLUSTERED ([PMKey]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[PALLETMGMT] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[PALLETMGMT] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[PALLETMGMT] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[PALLETMGMT] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pallet Management', 'SCHEMA', N'dbo', 'TABLE', N'PALLETMGMT', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record Created On Date', 'SCHEMA', N'dbo', 'TABLE', N'PALLETMGMT', 'COLUMN', N'Adddate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record Created by', 'SCHEMA', N'dbo', 'TABLE', N'PALLETMGMT', 'COLUMN', N'Addwho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Archivecop', 'SCHEMA', N'dbo', 'TABLE', N'PALLETMGMT', 'COLUMN', N'Archivecop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Delivery Date', 'SCHEMA', N'dbo', 'TABLE', N'PALLETMGMT', 'COLUMN', N'DeliveryDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Dispatch Date', 'SCHEMA', N'dbo', 'TABLE', N'PALLETMGMT', 'COLUMN', N'DispatchDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record Edits on', 'SCHEMA', N'dbo', 'TABLE', N'PALLETMGMT', 'COLUMN', N'Editdate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record Edits by', 'SCHEMA', N'dbo', 'TABLE', N'PALLETMGMT', 'COLUMN', N'Editwho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Effective Date', 'SCHEMA', N'dbo', 'TABLE', N'PALLETMGMT', 'COLUMN', N'EffectiveDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Facility', 'SCHEMA', N'dbo', 'TABLE', N'PALLETMGMT', 'COLUMN', N'Facility'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Pallet Management Key', 'SCHEMA', N'dbo', 'TABLE', N'PALLETMGMT', 'COLUMN', N'PMKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Source key', 'SCHEMA', N'dbo', 'TABLE', N'PALLETMGMT', 'COLUMN', N'Sourcekey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Source type; ASN,SO,MBOL,LOADPLAN', 'SCHEMA', N'dbo', 'TABLE', N'PALLETMGMT', 'COLUMN', N'Sourcetype'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Status', 'SCHEMA', N'dbo', 'TABLE', N'PALLETMGMT', 'COLUMN', N'Status'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Trafficcop', 'SCHEMA', N'dbo', 'TABLE', N'PALLETMGMT', 'COLUMN', N'Trafficcop'
GO
