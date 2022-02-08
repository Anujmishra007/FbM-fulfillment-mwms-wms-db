CREATE TABLE [dbo].[RDSColor]
(
[RDSColorLine] [int] NOT NULL,
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ColorCode] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_RDSColor_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDSColor_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_RDSColor_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RDSColor_EditWho] DEFAULT (suser_sname()),
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

-- =============================================
-- Author: WANYT
-- Create date: 20-May-2008
-- Description: Delete Details if Header was deleted
-- =============================================
/************************************************************************/
/* Trigger: ntrRDSColorDelete                                           */
/* Creation Date: 20-May-2008                                           */
/* Copyright: IDS                                                       */
/* Written by: WANYT                                                    */
/*                                                                      */
/* Purpose: Delete in rdsColor table.                                   */
/*                                                                      */
/* Input Parameters:                                                    */
/*                                                                      */
/* Output Parameters:                                                   */
/*                                                                      */
/* Usage:                                                               */
/*                                                                      */
/* Called By:  Exceed                                                   */
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Date         Author    Ver.  Purposes                                */
/* 6Jan2008     TLTING    1.1   @@TRANCOUNT >= @n_starttcnt to rollback */
/*                              (tlting01)                              */
/*                                                                      */
/************************************************************************/

CREATE TRIGGER [dbo].[ntrRDSColorDelete]
   ON  [dbo].[RDSColor]
   AFTER DELETE
AS 
BEGIN
   DECLARE @n_StartTCnt int, 
           @n_Continue  int, 
           @b_success   int,
           @n_Err       int, 
           @c_ErrMsg    NVARCHAR(215) 

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
   SET NOCOUNT ON 
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF 
   SET CONCAT_NULL_YIELDS_NULL OFF
   
   SET @n_StartTCnt = @@TRANCOUNT
   SET @n_Continue = 1  

   IF EXISTS(SELECT 1 FROM rdsColorDetail WITH (NOLOCK) 
             JOIN DELETED ON DELETED.rdsColorLine = rdsColorDetail.rdsColorLine)
   BEGIN
      DELETE rdsColorDetail 
      FROM   rdsColorDetail
      JOIN DELETED ON DELETED.rdsColorLine = rdsColorDetail.rdsColorLine
      SET @n_Err = @@ERROR
      IF @n_Err <> 0 
      BEGIN
         SET @n_Continue = 3
         SET @b_success = -1
         SET @c_ErrMsg = 'Delete rdsColorDetail Failed!'
         GOTO QUIT
      END            
   END 

QUIT:
   IF @n_continue = 3  -- Error Occured - Process And Return
   BEGIN
      SELECT @b_success = 0
      -- Start tlting01
      IF @@TRANCOUNT = 1 AND @@TRANCOUNT >= @n_starttcnt     -- tlting01    -- @@TRANCOUNT > @n_starttcnt
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
      -- End tlting01      
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrRDSColorDelete'
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
      RETURN
   END
   ELSE
   BEGIN
      SELECT @b_success = 1
      WHILE @@TRANCOUNT > @n_starttcnt
      BEGIN
         COMMIT TRAN
      END
      RETURN
   END   

END

GO
ALTER TABLE [dbo].[RDSColor] ADD CONSTRAINT [PK_RDSColor] PRIMARY KEY CLUSTERED ([RDSColorLine]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_RDSColor_ColorCode] ON [dbo].[RDSColor] ([Storerkey], [ColorCode]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[RDSColor] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[RDSColor] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[RDSColor] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[RDSColor] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'RDSColor', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'RDSColor', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'RDSColor', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'RDSColor', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'RDSColor', 'COLUMN', N'Storerkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'RDSColor', 'COLUMN', N'TrafficCop'
GO
