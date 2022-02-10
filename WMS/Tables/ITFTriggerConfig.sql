CREATE TABLE [dbo].[ITFTriggerConfig]
(
[SeqNo] [int] NOT NULL IDENTITY(1, 1),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ITFTriggerConfig_Facility] DEFAULT (' '),
[ConfigKey] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Tablename] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RecordType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ITFTriggerConfig_RecordType] DEFAULT (' '),
[RecordStatus] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ITFTriggerConfig_RecordStatus] DEFAULT (' '),
[sValue] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ITFTriggerConfig_sValue] DEFAULT (' '),
[SourceTable] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TargetTable] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StoredProc] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ITFTriggerConfig_StoredProc] DEFAULT (' '),
[UpdatedColumns] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ITFTriggerConfig_UpdatedColumns] DEFAULT (''),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_ITFTriggerConfig_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ITFTriggerConfig_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_ITFTriggerConfig_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ITFTriggerConfig_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QCommanderSP] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ITFTriggerConfig_QCommanderSP] DEFAULT (' ')
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/  
/* Trigger: ntrITFTriggerConfigUpdate                                   */  
/* Creation Date: 24-May-2018                                           */  
/* Copyright: IDS                                                       */  
/* Written by: MCTang                                                   */  
/*                                                                      */  
/* Purpose: Trigger related Update in ITFTriggerConfig table.           */  
/*                                                                      */  
/* Input Parameters:                                                    */  
/*                                                                      */  
/* Output Parameters:                                                   */  
/*                                                                      */  
/* Usage:                                                               */  
/*                                                                      */  
/* Called By:  Interface                                                */  
/*                                                                      */  
/* PVCS Version: 1.1                                                    */  
/*                                                                      */  
/* Version: 5.4                                                         */  
/*                                                                      */  
/* Data Modifications:                                                  */  
/* Date         Author    Ver.  Purposes                                */  
/************************************************************************/  
  
CREATE TRIGGER [dbo].[ntrITFTriggerConfigUpdate]  
ON  [dbo].[ITFTriggerConfig]  
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
  
   DECLARE @b_debug int  
   SELECT @b_debug = 0  
   DECLARE     
     @b_Success            int         
   , @n_Err                int         
   , @n_Err2               int         
   , @c_ErrMsg             char(250)   
   , @n_Continue           int  
   , @n_StartTCnt          int  
   , @c_preprocess         char(250)   
   , @c_pstprocess         char(250)   
   , @n_Cnt                int        
  
   SELECT @n_Continue=1, @n_StartTCnt=@@TRANCOUNT  
  
   IF @n_Continue = 1 OR @n_Continue = 2   
   BEGIN    
      UPDATE ITFTriggerConfig   
      SET    EditWho  = SUSER_SNAME()
           , EditDate = GETDATE()
      FROM   ITFTriggerConfig, INSERTED  
      WHERE  ITFTriggerConfig.SeqNo = INSERTED.SeqNo
     
      SELECT @n_Err = @@ERROR, @n_Cnt = @@ROWCOUNT
     
      IF @@ERROR <> 0
      BEGIN  
         SELECT @n_Continue = 3  
         SELECT @c_ErrMsg = CONVERT(CHAR(250),@n_Err), @n_Err=68002     
         SELECT @c_ErrMsg = 'NSQL' + CONVERT(char(5),ISNULL(@n_Err,0))   
                           + ': Update Failed On Table ITFTriggerConfig. (ntrITFTriggerConfigUpdate) ( '   
                           + ' SQLSvr MESSAGE=' + LTRIM(RTRIM(@c_ErrMsg)) + ' ) '  
      END
   END
END
GO
ALTER TABLE [dbo].[ITFTriggerConfig] ADD CONSTRAINT [PKITFTriggerConfig] PRIMARY KEY CLUSTERED ([SeqNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ITFTRIGGERCONFIG_SOURCETABLE] ON [dbo].[ITFTriggerConfig] ([SourceTable], [StorerKey], [sValue]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_ITFTriggerConfig_CIdx] ON [dbo].[ITFTriggerConfig] ([StorerKey], [Facility], [ConfigKey], [Tablename], [SourceTable]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ITFTriggerConfig] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[ITFTriggerConfig] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[ITFTriggerConfig] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[ITFTriggerConfig] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Queue Commander Stored Procedure', 'SCHEMA', N'dbo', 'TABLE', N'ITFTriggerConfig', 'COLUMN', N'QCommanderSP'
GO
