CREATE TABLE [dbo].[UploadC4PODetail]
(
[POkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PoLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExternPOkey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[POGroup] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExternLinenumber] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QtyOrdered] [int] NULL,
[UOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UploadC4PODetail_UOM] DEFAULT ('PIECE'),
[MODE] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[STATUS] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UploadC4PODetail_STATUS] DEFAULT ('0'),
[REMARKS] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[adddate] [datetime] NULL CONSTRAINT [DF_UploadC4PODetail_adddate] DEFAULT (getdate()),
[Best_bf_Date] [datetime] NULL CONSTRAINT [DF_UploadC4PODetail_Best_bf_Date] DEFAULT (getdate()),
[RFF] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StoreOrderNo] [nvarchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StoreID] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_UploadC4PODetail_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_UploadC4PODetail_EditWho] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/************************************************************************/
/* Trigger: ntrUploadC4PODetailUpdate                                   */
/* Creation Date: 11-Apr-2014                                           */
/* Copyright: IDS                                                       */
/* Written by: IDS                                                      */
/*                                                                      */
/* Purpose: Trigger related Update in UploadC4PODetail table.           */
/*                                                                      */
/* Input Parameters:                                                    */
/*                                                                      */
/* Output Parameters:                                                   */
/*                                                                      */
/* Usage:                                                               */
/*                                                                      */
/* Called By:  Interface                                                */
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Date         Author    Ver.  Purposes                                */
/* 11-Apr-2014  Leong     1.0   SOS308367 - Created.                    */
/************************************************************************/

CREATE TRIGGER [dbo].[ntrUploadC4PODetailUpdate]
ON  [dbo].[UploadC4PODetail]
FOR UPDATE
AS
BEGIN
   IF @@ROWCOUNT = 0
   BEGIN
      RETURN
   END

   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @b_Success   INT
         , @n_Err       INT
         , @c_ErrMsg    NVARCHAR(250)
         , @n_Continue  INT
         , @n_StartTCnt INT
         , @n_Cnt       INT

   SELECT @n_Continue = 1, @n_StartTCnt = @@TRANCOUNT

   IF @n_Continue = 1 OR @n_Continue = 2
   BEGIN
      UPDATE UploadC4PODetail
         SET EditDate = GETDATE()
           , EditWho  = SUSER_SNAME()
      FROM UploadC4PODetail
      JOIN INSERTED
        ON UploadC4PODetail.POKey = INSERTED.POKey
       AND UploadC4PODetail.POLineNumber = INSERTED.POLineNumber

      SELECT @n_Err = @@ERROR, @n_Cnt = @@ROWCOUNT

      IF @@ERROR <> 0
      BEGIN
         SELECT @n_Continue = 3
         SELECT @n_Err = 68802
         SELECT @c_ErrMsg = 'NSQL' + CONVERT(CHAR(5),ISNULL(@n_Err,0))
                          + ': Update Failed On Table UploadC4PODetail. (UploadC4PODetail) ( SQLSvr MESSAGE='
                          + ISNULL(LTRIM(RTRIM(@c_ErrMsg)),'') + ' )'
      END
   END
END
GO
ALTER TABLE [dbo].[UploadC4PODetail] ADD CONSTRAINT [PK_UploadC4PODetail] PRIMARY KEY CLUSTERED ([POkey], [PoLineNumber]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_UploadC4PODetail_ExtOrdKey] ON [dbo].[UploadC4PODetail] ([ExternPOkey], [ExternLinenumber]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_UploadC4PODetail_SKU] ON [dbo].[UploadC4PODetail] ([Storerkey], [SKU]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[UploadC4PODetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[UploadC4PODetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[UploadC4PODetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[UploadC4PODetail] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'UploadC4PODetail', 'COLUMN', N'adddate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'UploadC4PODetail', 'COLUMN', N'Storerkey'
GO
