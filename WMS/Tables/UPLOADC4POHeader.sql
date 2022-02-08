CREATE TABLE [dbo].[UPLOADC4POHeader]
(
[POkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ExternPOKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[POGROUP] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[POType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SellerName] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MODE] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[STATUS] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_UPLOADC4POHeader_STATUS] DEFAULT ('0'),
[REMARKS] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadingDate] [datetime] NULL CONSTRAINT [DF_UPLOADC4POHeader_LoadingDate] DEFAULT (getdate()),
[adddate] [datetime] NULL CONSTRAINT [DF_UPLOADC4POHeader_adddate] DEFAULT (getdate()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_UploadC4POHeader_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_UploadC4POHeader_EditWho] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/************************************************************************/
/* Trigger: ntrUploadC4POHeaderUpdate                                   */
/* Creation Date: 11-Apr-2014                                           */
/* Copyright: IDS                                                       */
/* Written by: IDS                                                      */
/*                                                                      */
/* Purpose: Trigger related Update in UploadC4POHeader table.           */
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

CREATE TRIGGER [dbo].[ntrUploadC4POHeaderUpdate]
ON  [dbo].[UPLOADC4POHeader]
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
      UPDATE UploadC4POHeader
         SET EditDate = GETDATE()
           , EditWho  = SUSER_SNAME()
      FROM UploadC4POHeader
      JOIN INSERTED
        ON UploadC4POHeader.POKey = INSERTED.POKey

      SELECT @n_Err = @@ERROR, @n_Cnt = @@ROWCOUNT

      IF @@ERROR <> 0
      BEGIN
         SELECT @n_Continue = 3
         SELECT @n_Err = 68802
         SELECT @c_ErrMsg = 'NSQL' + CONVERT(CHAR(5),ISNULL(@n_Err,0))
                          + ': Update Failed On Table UploadC4POHeader. (ntrUploadC4POHeaderUpdate) ( SQLSvr MESSAGE='
                          + ISNULL(LTRIM(RTRIM(@c_ErrMsg)),'') + ' )'
      END
   END
END
GO
ALTER TABLE [dbo].[UPLOADC4POHeader] ADD CONSTRAINT [PK_UPLOADC4POHeader] PRIMARY KEY CLUSTERED ([POkey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_UPLOADC4POHeader_ExtPOKey] ON [dbo].[UPLOADC4POHeader] ([ExternPOKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[UPLOADC4POHeader] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[UPLOADC4POHeader] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[UPLOADC4POHeader] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[UPLOADC4POHeader] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADC4POHeader', 'COLUMN', N'adddate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Purchase Orders used by the Storer.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADC4POHeader', 'COLUMN', N'ExternPOKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Purchase Orders.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADC4POHeader', 'COLUMN', N'POkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Additional information.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADC4POHeader', 'COLUMN', N'REMARKS'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'UPLOADC4POHeader', 'COLUMN', N'Storerkey'
GO
