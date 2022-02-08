CREATE TABLE [API].[AppSection]
(
[APPName] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AppSection_APPName] DEFAULT (''),
[DeviceID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AppSection_DeviceID] DEFAULT (''),
[UserID] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AppSection_UserID] DEFAULT (''),
[SectionTime] [datetime] NULL,
[ScanNo] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_AppSection_ScanNo] DEFAULT (''),
[PickslipNo] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_AppSection_PickslipNo] DEFAULT (''),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AppSection_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_AppSection_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AppSection_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_AppSection_EditDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


/************************************************************************/
/* Trigger: ntrAppSectionUpdate                                         */
/* Creation Date:                                                       */
/* Copyright: IDS                                                       */
/* Written by:                                                          */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author    Purposes                                      */
/* 17-03-2020  Chermaine  Review Editdate column update                 */
/************************************************************************/
CREATE TRIGGER [API].[ntrAppSectionUpdate] ON [API].[AppSection] 
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
	
   DECLARE @n_continue int
         , @b_success  int       -- Populated by calls to stored procedures - was the proc successful?
		   , @n_err      int       -- Error number returned by stored procedure or this trigger  
		   , @c_errmsg   NVARCHAR(250) -- Error message returned by stored procedure or this trigger 

	

	IF NOT UPDATE(EditDate)
	BEGIN
	 	UPDATE API.AppSection
	 	SET EditDate = GETDATE(),
	 	    EditWho = SUSER_SNAME()
	 	FROM API.AppSection (NOLOCK),	INSERTED
 	  WHERE AppSection.DeviceID = INSERTED.DeviceID
 	  
	END
   /* Return Statement */  
END
GO
ALTER TABLE [API].[AppSection] ADD CONSTRAINT [PK_AppSection] PRIMARY KEY CLUSTERED ([DeviceID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
GRANT DELETE ON  [API].[AppSection] TO [NSQL]
GO
GRANT INSERT ON  [API].[AppSection] TO [NSQL]
GO
GRANT SELECT ON  [API].[AppSection] TO [NSQL]
GO
GRANT UPDATE ON  [API].[AppSection] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'APP Name', 'SCHEMA', N'API', 'TABLE', N'AppSection', 'COLUMN', N'APPName'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Device ID', 'SCHEMA', N'API', 'TABLE', N'AppSection', 'COLUMN', N'DeviceID'
GO
EXEC sp_addextendedproperty N'MS_Description', 'PickslipNo', 'SCHEMA', N'API', 'TABLE', N'AppSection', 'COLUMN', N'PickslipNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Scan No', 'SCHEMA', N'API', 'TABLE', N'AppSection', 'COLUMN', N'ScanNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Section Time', 'SCHEMA', N'API', 'TABLE', N'AppSection', 'COLUMN', N'SectionTime'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User ID', 'SCHEMA', N'API', 'TABLE', N'AppSection', 'COLUMN', N'UserID'
GO
