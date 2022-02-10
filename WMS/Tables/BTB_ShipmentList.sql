CREATE TABLE [dbo].[BTB_ShipmentList]
(
[BTB_ShipmentKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BTB_ShipmentListNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_ShipmentList_Storerkey] DEFAULT (''),
[COO] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_ShipmentList_COO] DEFAULT (''),
[BTBFNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_ShipmentList_BTBFNo] DEFAULT (''),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_ShipmentList_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_BTB_ShipmentList_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_BTB_ShipmentList_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_BTB_ShipmentList_EditDate] DEFAULT (getdate()),
[TrafficCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/************************************************************************/
/* Trigger: ntrBTB_ShipmentListDelete                                 */
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
CREATE TRIGGER [dbo].[ntrBTB_ShipmentListDelete]
ON  [dbo].[BTB_ShipmentList]
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

   DELETE BTB_SHIPMENTDETAIL 
   FROM BTB_SHIPMENTDETAIL
   JOIN DELETED ON (BTB_SHIPMENTDETAIL.BTB_ShipmentKey = DELETED.BTB_ShipmentKey)
                AND(BTB_SHIPMENTDETAIL.BTB_ShipmentListNo = DELETED.BTB_ShipmentListNo)

   SET @n_err = @@ERROR 

   IF @n_err <> 0
   BEGIN
      SET @n_continue = 3
      SET @c_errmsg = CONVERT(CHAR(5),@n_err)
      SET @n_err = 81010   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
      SET @c_errmsg  = 'NSQL'+CONVERT(char(5),@n_err)+': Delete FROM BTB_SHIPMENTDETAIL Failed. (ntrBTB_ShipmentListDelete)' 
                     + ' ( ' + ' SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
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

      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'ntrBTB_ShipmentListDelete'
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
/* Trigger: ntrBTB_ShipmentListUpdate                                   */
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
CREATE TRIGGER [dbo].[ntrBTB_ShipmentListUpdate]
ON  [dbo].[BTB_ShipmentList]
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
      UPDATE BTB_SHIPMENTLIST WITH (ROWLOCK)
      SET EditWho = SUSER_SNAME()
         ,EditDate= GETDATE()
         ,TrafficCop = NULL
      FROM BTB_SHIPMENTLIST
      JOIN INSERTED ON (BTB_SHIPMENTLIST.BTB_ShipmentKey    = INSERTED.BTB_ShipmentKey)
                    AND(BTB_SHIPMENTLIST.BTB_ShipmentListNo = INSERTED.BTB_ShipmentListNo)

      SET @n_err = @@ERROR 
      IF @n_err <> 0
      BEGIN
         SET @n_continue = 3
         SET @c_errmsg = CONVERT(CHAR(250),@n_err)
         SET @n_err=80010   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
         SET @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Failed On Table BTB_SHIPMENTLIST. (ntrBTB_ShipmentListUpdate)' 
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

      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'ntrBTB_ShipmentListUpdate'
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
ALTER TABLE [dbo].[BTB_ShipmentList] ADD CONSTRAINT [PK__BTB_Ship__A8A22DBEA7AF1413] PRIMARY KEY CLUSTERED ([BTB_ShipmentKey], [BTB_ShipmentListNo]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_BTB_ShipmentList_COO] ON [dbo].[BTB_ShipmentList] ([BTB_ShipmentKey], [BTB_ShipmentListNo], [Storerkey], [COO]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[BTB_ShipmentList] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[BTB_ShipmentList] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[BTB_ShipmentList] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[BTB_ShipmentList] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Back To Back Shipment', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentList', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'The date in which the load is created', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentList', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentList', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Back To Back Shipment #', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentList', 'COLUMN', N'BTB_ShipmentKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Back To Back Shipment Listing', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentList', 'COLUMN', N'BTB_ShipmentListNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'BTBFNo', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentList', 'COLUMN', N'BTBFNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'COO', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentList', 'COLUMN', N'COO'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentList', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentList', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Storerkey', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentList', 'COLUMN', N'Storerkey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'BTB_ShipmentList', 'COLUMN', N'TrafficCop'
GO
