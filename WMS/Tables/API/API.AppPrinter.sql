CREATE TABLE [API].[AppPrinter]
(
[APPName] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AppPrinter_APPName] DEFAULT (''),
[Workstation] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AppPrinter_Workstation] DEFAULT (''),
[PrinterID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AppPrinter_PrinterID] DEFAULT (''),
[PrinterType] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AppPrinter_PrinterType] DEFAULT (''),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AppPrinter_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_AppPrinter_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AppPrinter_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_AppPrinter_EditDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


/************************************************************************/
/* Trigger: ntrAppPrinterUpdate                                         */
/* Creation Date:                                                       */
/* Copyright: IDS                                                       */
/* Written by:                                                          */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author    Purposes                                      */
/* 07-04-2020  Chermaine  Review Editdate column update                 */
/************************************************************************/
CREATE TRIGGER [API].[ntrAppPrinterUpdate] ON [API].[AppPrinter] 
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
	 	UPDATE API.AppPrinter
	 	SET EditDate = GETDATE(),
	 	    EditWho = SUSER_SNAME()
	 	FROM API.AppPrinter (NOLOCK),	INSERTED
 	  WHERE AppPrinter.Workstation = INSERTED.Workstation
 	  AND AppPrinter.PrinterType = INSERTED.PrinterType
 	  
	END
   /* Return Statement */  
END

--ALTER TABLE [API].[AppPrinter]  ENABLE TRIGGER [ntrAppPrinterUpdate]
GO
ALTER TABLE [API].[AppPrinter] ADD CONSTRAINT [PK_AppPrinter] PRIMARY KEY CLUSTERED ([Workstation], [PrinterID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
GRANT DELETE ON  [API].[AppPrinter] TO [NSQL]
GO
GRANT INSERT ON  [API].[AppPrinter] TO [NSQL]
GO
GRANT SELECT ON  [API].[AppPrinter] TO [NSQL]
GO
GRANT UPDATE ON  [API].[AppPrinter] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'APP Name', 'SCHEMA', N'API', 'TABLE', N'AppPrinter', 'COLUMN', N'APPName'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Printer ID', 'SCHEMA', N'API', 'TABLE', N'AppPrinter', 'COLUMN', N'PrinterID'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Printer Type', 'SCHEMA', N'API', 'TABLE', N'AppPrinter', 'COLUMN', N'PrinterType'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Workstation', 'SCHEMA', N'API', 'TABLE', N'AppPrinter', 'COLUMN', N'Workstation'
GO
