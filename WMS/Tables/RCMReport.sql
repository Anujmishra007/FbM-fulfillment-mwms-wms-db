CREATE TABLE [dbo].[RCMReport]
(
[ComputerName] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ReportType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PB_Datawindow] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Rpt_Printer] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RCMReport_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_RCMReport_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RCMReport_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_RCMReport_EditDate] DEFAULT (getdate()),
[ExtendParmName1] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtendParmName2] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtendParmName3] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtendParmName4] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtendParmName5] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtendParmDefault1] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RCMReport_ExtendParmDefault1] DEFAULT (''),
[ExtendParmDefault2] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RCMReport_ExtendParmDefault2] DEFAULT (''),
[ExtendParmDefault3] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RCMReport_ExtendParmDefault3] DEFAULT (''),
[ExtendParmDefault4] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RCMReport_ExtendParmDefault4] DEFAULT (''),
[ExtendParmDefault5] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RCMReport_ExtendParmDefault5] DEFAULT (''),
[AutoPrint] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RCMREPORT_AutoPrint] DEFAULT ('N'),
[JReportCatalog] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[JReportFileName] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[JReportFlag] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtendParmName6] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtendParmName7] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtendParmName8] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtendParmName9] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtendParmName10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtendParmDefault6] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RCMReport_ExtendParmDefault6] DEFAULT (''),
[ExtendParmDefault7] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RCMReport_ExtendParmDefault7] DEFAULT (''),
[ExtendParmDefault8] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RCMReport_ExtendParmDefault8] DEFAULT (''),
[ExtendParmDefault9] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RCMReport_ExtendParmDefault9] DEFAULT (''),
[ExtendParmDefault10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_RCMReport_ExtendParmDefault10] DEFAULT ('')
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Trigger: ntrRCMReportUpdate                                			   */
/* Creation Date: 04.May.2006                                           */
/* Copyright: IDS                                                       */
/* Written by: June                                                     */
/*                                                                      */
/* Purpose:  RCM Report Update Transaction                     			*/
/*                                                                      */
/* Input Parameters:                                                    */
/*                                                                      */
/* Output Parameters:                                                   */
/*                                                                      */
/* Return Status:                                                       */
/*                                                                      */
/* Usage:                                                               */
/*                                                                      */
/* Local Variables:                                                     */
/*                                                                      */
/* Called By: When update records                                       */
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 6.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author    Purposes                                      */
/* 17-Mar-2009  TLTING     Change user_name() to SUSER_SNAME()          */
/* 28-Oct-2013  TLTING     Review Editdate column update                */
/************************************************************************/

CREATE TRIGGER [dbo].[ntrRCMReportUpdate] 
ON [dbo].[RCMReport]
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
	DECLARE @b_success  int       -- Populated by calls to stored procedures - was the proc successful?
	      , @n_err      int       -- Error number returned by stored procedure or this trigger  
	      , @c_errmsg   NVARCHAR(250) -- Error message returned by stored procedure or this trigger 
	      , @n_continue int                 /* continuation flag 
	                                             1=Continue
	                                             2=failed but continue processsing 
	                                             3=failed do not continue processing 
	                                             4=successful but skip furthur processing */
	      , @n_starttcnt int                -- Holds the current transaction count                                               
	      , @n_cnt       int                      /* variable to hold @@ROWCOUNT */ 

	SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT

	IF ( @n_continue = 1 or @n_continue = 2 ) AND NOT UPDATE(EditDate)
	BEGIN
		UPDATE RCMReport
		SET EditDate = GETDATE(),
	  	    EditWho = SUSER_SNAME()
		FROM  RCMReport,INSERTED
		WHERE RCMReport.ComputerName = INSERTED.ComputerName
		AND   RCMReport.StorerKey = INSERTED.StorerKey
		AND   RCMReport.ReportType = INSERTED.ReportType
		
		SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
		IF @n_err <> 0
		BEGIN
			SELECT @n_continue = 3
			SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=90205   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
			SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Editdate/User Failed On Table RCMReport. (ntrRCMReportUpdate)' + ' ( ' + ' SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
		END
	END

	/* Return Statement */
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
	   Execute nsp_logerror @n_err, @c_errmsg, 'ntrRCMReportUpdate'
	   RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012          
	   RETURN
	END
	ELSE
	BEGIN
	    /* Error Did Not Occur , Return Normally */
	    WHILE @@TRANCOUNT > @n_starttcnt 
	    BEGIN
	         COMMIT TRAN
	    END
	    RETURN
	END
	/* End Return Statement */ 
END

GO
ALTER TABLE [dbo].[RCMReport] ADD CONSTRAINT [PKRCMReport] PRIMARY KEY CLUSTERED ([ComputerName], [StorerKey], [ReportType]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[RCMReport] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[RCMReport] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[RCMReport] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[RCMReport] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'RCMReport', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'RCMReport', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Auto Print at end of a event/function', 'SCHEMA', N'dbo', 'TABLE', N'RCMReport', 'COLUMN', N'AutoPrint'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'RCMReport', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'RCMReport', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'RCMReport Extend Parameter Default value 10 ', 'SCHEMA', N'dbo', 'TABLE', N'RCMReport', 'COLUMN', N'ExtendParmDefault10'
GO
EXEC sp_addextendedproperty N'MS_Description', N'RCMReport Extend Parameter Default value 6 ', 'SCHEMA', N'dbo', 'TABLE', N'RCMReport', 'COLUMN', N'ExtendParmDefault6'
GO
EXEC sp_addextendedproperty N'MS_Description', N'RCMReport Extend Parameter Default value 7 ', 'SCHEMA', N'dbo', 'TABLE', N'RCMReport', 'COLUMN', N'ExtendParmDefault7'
GO
EXEC sp_addextendedproperty N'MS_Description', N'RCMReport Extend Parameter Default value 8 ', 'SCHEMA', N'dbo', 'TABLE', N'RCMReport', 'COLUMN', N'ExtendParmDefault8'
GO
EXEC sp_addextendedproperty N'MS_Description', N'RCMReport Extend Parameter Default value 9 ', 'SCHEMA', N'dbo', 'TABLE', N'RCMReport', 'COLUMN', N'ExtendParmDefault9'
GO
EXEC sp_addextendedproperty N'MS_Description', N'RCMReport Extend Parameter Name 10 ', 'SCHEMA', N'dbo', 'TABLE', N'RCMReport', 'COLUMN', N'ExtendParmName10'
GO
EXEC sp_addextendedproperty N'MS_Description', N'RCMReport Extend Parameter Name 6 ', 'SCHEMA', N'dbo', 'TABLE', N'RCMReport', 'COLUMN', N'ExtendParmName6'
GO
EXEC sp_addextendedproperty N'MS_Description', N'RCMReport Extend Parameter Name 7 ', 'SCHEMA', N'dbo', 'TABLE', N'RCMReport', 'COLUMN', N'ExtendParmName7'
GO
EXEC sp_addextendedproperty N'MS_Description', N'RCMReport Extend Parameter Name 8 ', 'SCHEMA', N'dbo', 'TABLE', N'RCMReport', 'COLUMN', N'ExtendParmName8'
GO
EXEC sp_addextendedproperty N'MS_Description', N'RCMReport Extend Parameter Name 9 ', 'SCHEMA', N'dbo', 'TABLE', N'RCMReport', 'COLUMN', N'ExtendParmName9'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer records.', 'SCHEMA', N'dbo', 'TABLE', N'RCMReport', 'COLUMN', N'StorerKey'
GO
