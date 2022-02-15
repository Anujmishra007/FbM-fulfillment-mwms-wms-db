CREATE TABLE [RDT].[rdtPutawayLog]
(
[PutawayKey] [int] NOT NULL IDENTITY(1, 1),
[mobile] [int] NOT NULL,
[status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPutawayLog_status] DEFAULT ('0'),
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Lot] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FromLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UOM] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Packkey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Sourcekey] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[caseID] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Qty] [int] NOT NULL CONSTRAINT [DF_rdtPutawayLog_Qty] DEFAULT ((0)),
[ID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPutawayLog_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_rdtPutawayLog_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtPutawayLog_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_rdtPutawayLog_EditDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Trigger: ntrRDTPutawayLogUpdate                                      */
/* Creation Date:                                                       */
/* Copyright: IDS                                                       */
/* Written by:                                                          */
/*                                                                      */
/* Purpose:  RDT.RDTPUTAWAYLOG Update Transaction                       */
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
/* 28-Oct-2013  TLTING     Review Editdate column update                */
/************************************************************************/
CREATE TRIGGER [RDT].[ntrRDTPutawayLogUpdate] ON [RDT].[rdtPutawayLog] 
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

	SELECT @n_continue = 1

	IF ( @n_continue = 1 OR @n_continue = 2 ) AND NOT UPDATE(EditDate)
	BEGIN
	 	UPDATE RDT.RDTPUTAWAYLOG
	 	SET EditDate = GETDATE(),
	 	    EditWho = SUSER_SNAME()
	 	FROM RDTPUTAWAYLOG (NOLOCK),	INSERTED
 	  WHERE RDTPUTAWAYLOG.PutawayKey = INSERTED.PutawayKey
 	  
	END
   /* Return Statement */  
END

GO
ALTER TABLE [RDT].[rdtPutawayLog] ADD CONSTRAINT [PKrdtPutaway] PRIMARY KEY CLUSTERED ([PutawayKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_rdtPutaway_Mobile] ON [RDT].[rdtPutawayLog] ([mobile]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_RDTPUTAWAYLOG_01] ON [RDT].[rdtPutawayLog] ([SKU], [AddWho], [status]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[rdtPutawayLog] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[rdtPutawayLog] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[rdtPutawayLog] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[rdtPutawayLog] TO [NSQL]
GO
