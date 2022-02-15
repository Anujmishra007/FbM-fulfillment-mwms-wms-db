CREATE TABLE [RDT].[rdtQCInquiryLog]
(
[QCInquiryLogKey] [int] NOT NULL IDENTITY(1, 1),
[Mobile] [int] NOT NULL,
[UserID] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtQCInquiryLog_Status] DEFAULT ('0'),
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DropID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DropIDType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReasonKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Loc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lot] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TaskdetailKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtQCInquiryLog_TaskdetailKey] DEFAULT (''),
[QtyAllocated] [int] NULL CONSTRAINT [DF_rdtQCInquiryLog_QtyAllocated] DEFAULT ((0)),
[QtyPicked] [int] NULL CONSTRAINT [DF_rdtQCInquiryLog_QtyPicked] DEFAULT ((0)),
[QtyShortPick] [int] NULL,
[ResolvedSPQty] [int] NULL CONSTRAINT [DF_rdtQCInquiryLog_ResolvedSPQty] DEFAULT ((0)),
[NewDropID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddDate] [datetime] NULL CONSTRAINT [DF_rdtQCInquiryLog_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtQCInquiryLog_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_rdtQCInquiryLog_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_rdtQCInquiryLog_EditWho] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Trigger: ntrrdtQCInquiryLogUpdate                                    */
/* Creation Date:   23 Sept 2010                                        */
/* Copyright: IDS                                                       */
/* Written by:  TLTING                                                  */
/*                                                                      */
/* Purpose:  RDT.rdtQCInquiryLog Update Transaction                     */
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

CREATE TRIGGER [RDT].[ntrrdtQCInquiryLogUpdate]
ON  [RDT].[rdtQCInquiryLog]
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

   IF NOT UPDATE(EditDate)
   BEGIN
      UPDATE rdtQCInquiryLog WITH (ROWLOCK) 
         SET EditDate = GetDate(), EditWho = suser_sname()
      FROM rdtQCInquiryLog 
      JOIN INSERTED ON INSERTED.QCInquiryLogKey = rdtQCInquiryLog.QCInquiryLogKey 
	END 
END
GO
ALTER TABLE [RDT].[rdtQCInquiryLog] ADD CONSTRAINT [PK_rdtQCInquiryLog] PRIMARY KEY CLUSTERED ([QCInquiryLogKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_rdtQCInquiryLog_USerID] ON [RDT].[rdtQCInquiryLog] ([UserID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[rdtQCInquiryLog] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[rdtQCInquiryLog] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[rdtQCInquiryLog] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[rdtQCInquiryLog] TO [NSQL]
GO
