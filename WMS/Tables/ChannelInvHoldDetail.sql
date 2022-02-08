CREATE TABLE [dbo].[ChannelInvHoldDetail]
(
[RefID] [bigint] NOT NULL IDENTITY(1, 1),
[InvHoldkey] [bigint] NOT NULL CONSTRAINT [DF_ChannelInvHoldDetail_InvHoldkey] DEFAULT ((0)),
[SourceLineNo] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelInvHoldDetail_SourceLineNo] DEFAULT (''),
[Channel_ID] [bigint] NOT NULL CONSTRAINT [DF_ChannelInvHoldDetail_Channel_ID] DEFAULT ((0)),
[Qty] [int] NOT NULL CONSTRAINT [DF_ChannelInvHoldDetail_Qty] DEFAULT ((0)),
[Hold] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelInvHoldDetail_Hold] DEFAULT ('0'),
[DateOn] [datetime] NOT NULL CONSTRAINT [DF_ChannelInvHoldDetail_DateOn] DEFAULT (getdate()),
[WhoOn] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelInvHoldDetail_WhoOn] DEFAULT (suser_sname()),
[DateOff] [datetime] NOT NULL CONSTRAINT [DF_ChannelInvHoldDetail_DateOff] DEFAULT (getdate()),
[WhoOff] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ChannelInvHoldDetail_WhoOff] DEFAULT (suser_sname()),
[TrafficCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/************************************************************************/
/* Trigger: ntrChannelInvHoldDetailDelete                               */
/* Creation Date: 29-JUL-2019                                           */
/* Copyright: LF Logistics                                              */
/* Written by: Wan                                                      */
/*                                                                      */
/* Purpose: WMS-9995 [CN] NIKESDC_Exceed_Hold ASN for Channel           */
/*        :                                                             */
/* Called By:                                                           */
/*          :                                                           */
/* PVCS Version: 1.1                                                    */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */
/* 2021-05-10  Wan01    1.1   Fixed- Skip Archive checking              */
/************************************************************************/
CREATE TRIGGER [dbo].[ntrChannelInvHoldDetailDelete]
ON  [dbo].[ChannelInvHoldDetail]
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

   DECLARE  
           @n_StartTCnt       INT = @@TRANCOUNT
         , @n_Continue        INT = 1
         , @n_err             INT = 0
         , @c_errmsg          NVARCHAR(255) = ''

         , @CUR_HOLD          CURSOR

   IF (SELECT COUNT(1) FROM DELETED) = (SELECT COUNT(1) FROM DELETED WHERE DELETED.ArchiveCop = '9') -- Wan01     
   BEGIN
      SET @n_continue = 4 
      GOTO QUIT_TR
   END

   --IF UPDATE(TrafficCop)
   --BEGIN
   --   SET @n_continue = 4 
   --   GOTO QUIT_TR
   --END
 
   IF EXISTS ( SELECT 1
               FROM   DELETED
               WHERE  DELETED.Hold = '1'
            )
   BEGIN 
      SET @n_continue = 3 
      SET @n_err = 70100  
      SET @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Delete rejected. Channel Inventory Still On Hold. (ntrChannelInvHoldDetailDelete)'
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

      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'ntrChannelInvHoldDetailDelete'
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
ALTER TABLE [dbo].[ChannelInvHoldDetail] ADD CONSTRAINT [PK_ChannelInvHoldDetail] PRIMARY KEY CLUSTERED ([RefID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_ChannelInvHoldDetail_InvHoldkey] ON [dbo].[ChannelInvHoldDetail] ([InvHoldkey], [SourceLineNo], [Channel_ID], [Hold]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ChannelInvHoldDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[ChannelInvHoldDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[ChannelInvHoldDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[ChannelInvHoldDetail] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Channel Inventory Hold Detail table', 'SCHEMA', N'dbo', 'TABLE', N'ChannelInvHoldDetail', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'ArchiveCop purpose, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'ChannelInvHoldDetail', 'COLUMN', N'ArchiveCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Channel ID', 'SCHEMA', N'dbo', 'TABLE', N'ChannelInvHoldDetail', 'COLUMN', N'Channel_ID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date to unhold channel', 'SCHEMA', N'dbo', 'TABLE', N'ChannelInvHoldDetail', 'COLUMN', N'DateOff'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date to hold channel', 'SCHEMA', N'dbo', 'TABLE', N'ChannelInvHoldDetail', 'COLUMN', N'DateOn'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Hold/Unhold', 'SCHEMA', N'dbo', 'TABLE', N'ChannelInvHoldDetail', 'COLUMN', N'Hold'
GO
EXEC sp_addextendedproperty N'MS_Description', N'InvHoldkey', 'SCHEMA', N'dbo', 'TABLE', N'ChannelInvHoldDetail', 'COLUMN', N'InvHoldkey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Hold/Unhold Qty', 'SCHEMA', N'dbo', 'TABLE', N'ChannelInvHoldDetail', 'COLUMN', N'Qty'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Row Reference ID', 'SCHEMA', N'dbo', 'TABLE', N'ChannelInvHoldDetail', 'COLUMN', N'RefID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'SourceLineNo + Source Line #', 'SCHEMA', N'dbo', 'TABLE', N'ChannelInvHoldDetail', 'COLUMN', N'SourceLineNo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'TrafficCop purpose, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'ChannelInvHoldDetail', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Who Unhold Channel', 'SCHEMA', N'dbo', 'TABLE', N'ChannelInvHoldDetail', 'COLUMN', N'WhoOff'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Who Hold Channel', 'SCHEMA', N'dbo', 'TABLE', N'ChannelInvHoldDetail', 'COLUMN', N'WhoOn'
GO
