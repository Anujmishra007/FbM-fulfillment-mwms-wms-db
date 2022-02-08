CREATE TABLE [dbo].[BTB_Shipment]
(
[BTB_ShipmentKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ShipmentDate] [datetime] NOT NULL,
[ShipToCountry] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_Shipment_ShipToCountry] DEFAULT (''),
[Vessel] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_Shipment_Vessel] DEFAULT (''),
[BLNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_Shipment_BLNo] DEFAULT (''),
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_Shipment_Storerkey] DEFAULT (''),
[FormType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_Shipment_FormType] DEFAULT (''),
[PermitNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_Shipment_PermitNo] DEFAULT (''),
[UserDefine01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_Shipment_UserDefine01] DEFAULT (''),
[UserDefine02] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_Shipment_UserDefine02] DEFAULT (''),
[UserDefine03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_Shipment_UserDefine03] DEFAULT (''),
[UserDefine04] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_Shipment_UserDefine04] DEFAULT (''),
[UserDefine05] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_Shipment_UserDefine05] DEFAULT (''),
[UserDefine06] [datetime] NULL,
[UserDefine07] [datetime] NULL,
[UserDefine08] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_Shipment_UserDefine08] DEFAULT (''),
[UserDefine09] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_Shipment_UserDefine09] DEFAULT (''),
[UserDefine10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_Shipment_UserDefine10] DEFAULT (''),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_Shipment_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_BTB_Shipment_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_Shipment_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_BTB_Shipment_EditDate] DEFAULT (getdate()),
[TrafficCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_SHIPMENT_Status] DEFAULT ('0')
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/************************************************************************/
/* Trigger: ntrBTB_ShipmentDelete                                       */
/* Creation Date: 22-MAR-2017                                           */
/* Copyright: LF Logistics                                              */
/* Written by: Wan                                                      */
/*                                                                      */
/* Purpose:                                                             */
/*        :                                                             */
/* Called By:                                                           */
/*          :                                                           */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author    Ver Purposes                                  */
/************************************************************************/
CREATE TRIGGER [dbo].[ntrBTB_ShipmentDelete]
ON  [dbo].[BTB_Shipment]
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

   DECLARE @n_StartTCnt       INT
         , @n_Continue        INT
         , @n_err             INT
         , @c_errmsg          NVARCHAR(250)

   DECLARE @c_FormType        NVARCHAR(10)
         , @c_FormNo          NVARCHAR(40)
         , @c_HSCode          NVARCHAR(20)
         , @c_Storerkey       NVARCHAR(15)     
         , @c_Sku             NVARCHAR(20)
         , @n_QtyExported     INT

   SET @n_StartTCnt= @@TRANCOUNT
   SET @n_Continue = 1

   IF (SELECT COUNT(1) FROM DELETED) = (SELECT COUNT(1) FROM DELETED WHERE DELETED.ArchiveCop = '9')
   BEGIN
      SET @n_Continue = 4
      GOTO QUIT_TR
   END

   DELETE BTB_SHIPMENTLIST
   FROM BTB_SHIPMENTLIST
   JOIN DELETED ON (BTB_SHIPMENTLIST.BTB_ShipmentKey = DELETED.BTB_ShipmentKey)

   SET @n_err = @@ERROR 

   IF @n_err <> 0
   BEGIN
      SET @n_continue = 3
      SET @c_errmsg = CONVERT(CHAR(5),@n_err)
      SET @n_err = 81010   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
      SET @c_errmsg  = 'NSQL'+CONVERT(char(5),@n_err)+': Delete FROM BTB_SHIPMENTLIST Failed. (ntrBTB_ShipmentDelete)' 
                     + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '
   END
QUIT_TR:
   IF @n_Continue=3  -- Error Occured - Process And Return
   BEGIN
      IF  @@TRANCOUNT = 1 AND @@TRANCOUNT >= @n_StartTCnt
      BEGIN
         ROLLBACK TRAN
      END
      ELSE
      BEGIN
         WHILE @@TRANCOUNT > @n_StartTCnt
         BEGIN
            COMMIT TRAN
         END
      END

      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'ntrBTB_ShipmentDelete'
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
   END
   ELSE
   BEGIN
      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
         COMMIT TRAN
      END
   END
END -- procedure
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/************************************************************************/
/* Trigger: ntrBTB_ShipmentUpdate                                       */
/* Creation Date: 20-MAR-2017                                           */
/* Copyright: LF Logistics                                              */
/* Written by: Wan                                                      */
/*                                                                      */
/* Purpose:                                                             */
/*        :                                                             */
/* Called By:                                                           */
/*          :                                                           */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author    Ver Purposes                                  */
/************************************************************************/
CREATE TRIGGER [dbo].[ntrBTB_ShipmentUpdate]
ON  [dbo].[BTB_Shipment]
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

   DECLARE @n_StartTCnt       INT
         , @n_Continue        INT
         , @n_err             INT
         , @c_errmsg          NVARCHAR(250)

   DECLARE @c_FormType        NVARCHAR(10)
         , @c_ShipmentKey     NVARCHAR(10)
         , @c_ShipmentListNo  NVARCHAR(10)
         , @c_ShipmentLineNo  NVARCHAR(5)
         , @c_FormNo          NVARCHAR(40)
         , @c_HSCode          NVARCHAR(20)
         , @c_Storerkey       NVARCHAR(15)     
         , @c_Sku             NVARCHAR(20)
         , @n_QtyExported     INT

         , @c_FormNo_DEL      NVARCHAR(40)
         , @c_HSCode_DEL      NVARCHAR(20)
         , @c_Sku_DEL         NVARCHAR(20)
         , @n_QtyExported_DEL INT

   SET @n_StartTCnt= @@TRANCOUNT
   SET @n_Continue = 1

   IF UPDATE(ArchiveCop)
   BEGIN
      SET @n_continue = 4 
      GOTO QUIT_TR
   END

   IF NOT UPDATE(EditDate) 
   BEGIN
      UPDATE BTB_SHIPMENT WITH (ROWLOCK)
      SET EditWho = SUSER_SNAME()
         ,EditDate= GETDATE()
         ,TrafficCop = NULL
      FROM BTB_SHIPMENT
      JOIN INSERTED ON (BTB_SHIPMENT.BTB_ShipmentKey = INSERTED.BTB_ShipmentKey)

      SET @n_err = @@ERROR 
      IF @n_err <> 0
      BEGIN
         SET @n_continue = 3
         SET @c_errmsg = CONVERT(CHAR(250),@n_err)
         SET @n_err=80010   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
         SET @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Failed On Table BTB_SHIPMENT. (ntrBTB_ShipmentUpdate)' 
                      + ' ( ' + ' SQLSvr MESSAGE=' + RTRIM(@c_errmsg) + ' ) '
         GOTO QUIT_TR
      END
   END

   IF UPDATE(TrafficCop)
   BEGIN
      SET @n_continue = 4 
      GOTO QUIT_TR
   END

QUIT_TR:

   IF @n_Continue=3  -- Error Occured - Process And Return
   BEGIN
      IF  @@TRANCOUNT = 1 AND @@TRANCOUNT >= @n_StartTCnt
      BEGIN
         ROLLBACK TRAN
      END
      ELSE
      BEGIN
         WHILE @@TRANCOUNT > @n_StartTCnt
         BEGIN
            COMMIT TRAN
         END
      END

      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'ntrBTB_ShipmentUpdate'
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
   END
   ELSE
   BEGIN
      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
         COMMIT TRAN
      END
   END
END -- procedure
GO
ALTER TABLE [dbo].[BTB_Shipment] ADD CONSTRAINT [PK__BTB_Ship__3809C58544C0098F] PRIMARY KEY CLUSTERED ([BTB_ShipmentKey]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[BTB_Shipment] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[BTB_Shipment] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[BTB_Shipment] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[BTB_Shipment] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Back To Back Shipment', 'SCHEMA', N'dbo', 'TABLE', N'BTB_Shipment', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date in which the load is created', 'SCHEMA', N'dbo', 'TABLE', N'BTB_Shipment', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'BTB_Shipment', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'BL No', 'SCHEMA', N'dbo', 'TABLE', N'BTB_Shipment', 'COLUMN', N'BLNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Back To Back Shipment #', 'SCHEMA', N'dbo', 'TABLE', N'BTB_Shipment', 'COLUMN', N'BTB_ShipmentKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'BTB_Shipment', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'BTB_Shipment', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Form Type', 'SCHEMA', N'dbo', 'TABLE', N'BTB_Shipment', 'COLUMN', N'FormType'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Permit No', 'SCHEMA', N'dbo', 'TABLE', N'BTB_Shipment', 'COLUMN', N'PermitNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Shipment Date', 'SCHEMA', N'dbo', 'TABLE', N'BTB_Shipment', 'COLUMN', N'ShipmentDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ship To Country', 'SCHEMA', N'dbo', 'TABLE', N'BTB_Shipment', 'COLUMN', N'ShipToCountry'
GO
EXEC sp_addextendedproperty N'MS_Description', N'BTB Shipment Status', 'SCHEMA', N'dbo', 'TABLE', N'BTB_Shipment', 'COLUMN', N'Status'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Storerkey', 'SCHEMA', N'dbo', 'TABLE', N'BTB_Shipment', 'COLUMN', N'Storerkey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'BTB_Shipment', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 01', 'SCHEMA', N'dbo', 'TABLE', N'BTB_Shipment', 'COLUMN', N'UserDefine01'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 02', 'SCHEMA', N'dbo', 'TABLE', N'BTB_Shipment', 'COLUMN', N'UserDefine02'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 03', 'SCHEMA', N'dbo', 'TABLE', N'BTB_Shipment', 'COLUMN', N'UserDefine03'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 04', 'SCHEMA', N'dbo', 'TABLE', N'BTB_Shipment', 'COLUMN', N'UserDefine04'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 05', 'SCHEMA', N'dbo', 'TABLE', N'BTB_Shipment', 'COLUMN', N'UserDefine05'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 06', 'SCHEMA', N'dbo', 'TABLE', N'BTB_Shipment', 'COLUMN', N'UserDefine06'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 07', 'SCHEMA', N'dbo', 'TABLE', N'BTB_Shipment', 'COLUMN', N'UserDefine07'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 08', 'SCHEMA', N'dbo', 'TABLE', N'BTB_Shipment', 'COLUMN', N'UserDefine08'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 09', 'SCHEMA', N'dbo', 'TABLE', N'BTB_Shipment', 'COLUMN', N'UserDefine09'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Userdefine column 10', 'SCHEMA', N'dbo', 'TABLE', N'BTB_Shipment', 'COLUMN', N'UserDefine10'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Vessel', 'SCHEMA', N'dbo', 'TABLE', N'BTB_Shipment', 'COLUMN', N'Vessel'
GO
