CREATE TABLE [dbo].[Dropid]
(
[Dropid] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Dropid_Dropid] DEFAULT (''),
[Droploc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Dropid_Droploc] DEFAULT (' '),
[AdditionalLoc] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Dropid_AdditionalLoc] DEFAULT (' '),
[DropIDType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Dropid_DropIDType] DEFAULT ('0'),
[LabelPrinted] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Dropid_LabelPrinted] DEFAULT ('0'),
[ManifestPrinted] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Dropid_ManifestPrinted] DEFAULT ('0'),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Dropid_Status] DEFAULT ('0'),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_Dropid_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Dropid_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_Dropid_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Dropid_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Loadkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Dropid_Loadkey] DEFAULT (' '),
[PickSlipNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Dropid_PickSlipNo] DEFAULT (' '),
[UDF01] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Dropid_UDF01] DEFAULT (''),
[UDF02] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Dropid_UDF02] DEFAULT (''),
[UDF03] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Dropid_UDF03] DEFAULT (''),
[UDF04] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Dropid_UDF04] DEFAULT (''),
[UDF05] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Dropid_UDF05] DEFAULT ('')
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Trigger: ntrDropidDelete                                             */
/* Creation Date: 17 May 2012                                           */
/* Copyright: IDS                                                       */
/* Written by: KHLim                                                    */
/*                                                                      */
/* Purpose:                                                             */
/*                                                                      */
/* Usage:                                                               */
/*                                                                      */
/* Called By: When records removed from Dropid                          */
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Modifications:                                                       */
/* Date         Author   Ver  Purposes                                  */
/*                                                                      */
/************************************************************************/

CREATE TRIGGER [dbo].[ntrDropidDelete]
ON [dbo].[Dropid]
FOR DELETE
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

   DECLARE  @b_Success     int,       -- Populated by calls to stored procedures - was the proc successful?
            @n_err         int,       -- Error number returned by stored procedure or this trigger
            @c_errmsg      NVARCHAR(250), -- Error message returned by stored procedure or this trigger
            @n_continue    int,       -- continuation flag: 1=Continue, 2=failed but continue processsing, 3=failed do not continue processing, 4=successful but skip further processing
            @n_starttcnt   int,       -- Holds the current transaction count
            @n_cnt         int,       -- Holds the number of rows affected by the DELETE statement that fired this trigger.
            @c_authority   NVARCHAR(1)
   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT

   IF (SELECT COUNT(*) FROM DELETED) = (SELECT COUNT(*) FROM DELETED WHERE DELETED.ArchiveCop = '9')
   BEGIN
      SELECT @n_continue = 4
   END

      /* #INCLUDE <TRCONHD1.SQL> */     
   IF @n_continue = 1 or @n_continue = 2
   BEGIN
      SELECT @b_success = 0
      EXECUTE nspGetRight  NULL,             -- facility  
                           NULL,             -- Storerkey  
                           NULL,             -- Sku  
                           'DataMartDELLOG', -- Configkey  
                           @b_success     OUTPUT, 
                           @c_authority   OUTPUT, 
                           @n_err         OUTPUT, 
                           @c_errmsg      OUTPUT  
      IF @b_success <> 1
      BEGIN
         SELECT @n_continue = 3
               ,@c_errmsg = 'ntrDropidDelete' + dbo.fnc_RTrim(@c_errmsg)
      END
      ELSE 
      IF @c_authority = '1'
      BEGIN
         INSERT INTO dbo.Dropid_DELLOG 
               ( Dropid )
         SELECT  Dropid FROM DELETED

         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 68101   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Delete Trigger On Table Dropid Failed. (ntrDropidDelete)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
         END
      END
   END

      /* #INCLUDE <TRCOND2.SQL> */
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
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrDropidDelete'
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
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/******************************************************************************/  
/* Trigger: ntrDropidUpdate                                                   */  
/* Creation Date: 24 May 2012                                                 */  
/* Copyright: IDS                                                             */  
/* Written by: KHLim                                                          */  
/*                                                                            */  
/* Purpose:  Update Dropid.                                                   */  
/*                                                                            */  
/* Return Status:                                                             */  
/*                                                                            */  
/* Usage:                                                                     */  
/*                                                                            */  
/* Called By: When records Updated                                            */  
/*                                                                            */  
/* PVCS Version: 1.3                                                          */  
/*                                                                            */  
/* Version: 5.4                                                               */  
/*                                                                            */  
/* Modifications:                                                             */  
/* Date         Author   Ver  Purposes                                        */  
/* 06-Sep-2012  KHLim    1.1  Move up ArchiveCop (KH01)                       */
/* 28-Oct-2013  TLTING   1.2  Review Editdate column update                   */
/* 03-Dec-2014  KHLim    1.3  Remove SET ANSI_WARNINGS OFF to avoid recompile */
/******************************************************************************/  
  
CREATE TRIGGER [dbo].[ntrDropidUpdate]  
ON  [dbo].[Dropid]   
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
   DECLARE @b_Success int          -- Populated by calls to stored procedures - was the proc successful?  
         , @n_err int              -- Error number returned by stored procedure or this trigger  
         , @n_err2 int             -- For Additional Error Detection  
         , @c_errmsg NVARCHAR(250)     -- Error message returned by stored procedure or this trigger  
         , @n_continue int                   
         , @n_starttcnt int        -- Holds the current transaction count  
         , @c_preprocess NVARCHAR(250) -- preprocess  
         , @c_pstprocess NVARCHAR(250) -- post process  
         , @n_cnt int                    
  
   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT  
   IF UPDATE(ArchiveCop)      --KH01
   BEGIN          
      SELECT @n_continue = 4          
   END

   IF ( @n_continue = 1 OR @n_continue = 2 ) AND NOT UPDATE(EditDate) 
   BEGIN  
      UPDATE Dropid  with (ROWLOCK)
         SET EditDate = GETDATE(),  
             EditWho = SUSER_SNAME(),  
             TrafficCop = NULL  
        FROM Dropid, INSERTED  
       WHERE Dropid.Dropid = INSERTED.Dropid

      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT  
      IF @n_err <> 0  
      BEGIN  
         SELECT @n_continue = 3  
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=85803   -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
         SELECT @c_errmsg='NSQL'+CONVERT(CHAR(5),ISNULL(@n_err,0))  
                         +': Update Failed On Table Dropid. (ntrDropidUpdate)' + ' ( '   
                         +' SQLSvr MESSAGE=' + ISNULL(dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)),'') + ' ) '  
      END  
   END  
  
   IF UPDATE(TrafficCop)  
   BEGIN  
      SELECT @n_continue = 4   
   END  
  
   /* #INCLUDE <TRPU_2.SQL> */  
   IF @n_continue=3  -- Error Occured - Process And Return  
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
  
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrDropidUpdate'  
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
GO
ALTER TABLE [dbo].[Dropid] ADD CONSTRAINT [PKDropid] PRIMARY KEY CLUSTERED ([Dropid]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[Dropid] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[Dropid] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[Dropid] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[Dropid] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[Dropid] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'The Drop ID number is used to consolidate picks and packs. All Drop IDs are generated by the system (either from RDT or WCS).', 'SCHEMA', N'dbo', 'TABLE', N'Dropid', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'Dropid', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'Dropid', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'This field is populated by the system once a sorter scans the ID that is used to identify the customerÆs outbound packing container. This allows the sorter to apply the Drop ID label to the outbound container and simply scan the barcode for the location to verify proper sortation. The system then records the sort into the Drop ID assigned to the scanned sortation location.', 'SCHEMA', N'dbo', 'TABLE', N'Dropid', 'COLUMN', N'Dropid'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the physical drop Location in the facility.', 'SCHEMA', N'dbo', 'TABLE', N'Dropid', 'COLUMN', N'Droploc'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'Dropid', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'Dropid', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'Dropid', 'COLUMN', N'TrafficCop'
GO
