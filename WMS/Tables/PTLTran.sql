CREATE TABLE [dbo].[PTLTran]
(
[PTLKey] [bigint] NOT NULL IDENTITY(1, 1),
[IPAddress] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PTLTran_IPAddress] DEFAULT (''),
[DeviceID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PTLTran_DeviceID] DEFAULT (''),
[DevicePosition] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PTLTran_DevicePosition] DEFAULT (''),
[Status] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PTLTran_Status] DEFAULT ('0'),
[PTL_Type] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DropID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PTLTran_OrderKey] DEFAULT (''),
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PTLTran_Storerkey] DEFAULT (''),
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PTLTran_SKU] DEFAULT (''),
[LOC] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PTLTran_LOC] DEFAULT (''),
[Lot] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExpectedQty] [int] NULL CONSTRAINT [DF_PTLTran_ExpectedQty] DEFAULT ((0)),
[Qty] [int] NULL CONSTRAINT [DF_PTLTran_Qty] DEFAULT ((0)),
[Remarks] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PTLTran_Remarks] DEFAULT (''),
[MessageNum] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PTLTran_MessageNum] DEFAULT (''),
[AddDate] [datetime] NULL CONSTRAINT [DF_PTLTran_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PTLTran_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_PTLTran_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PTLTran_EditWho] DEFAULT (suser_sname()),
[DeviceProfileLogKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrafficCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SourceKey] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PTLTran_SourceKey] DEFAULT (''),
[ConsigneeKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PTLTran_ConsigneeKey] DEFAULT (''),
[CaseID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PTLTran_CaseID] DEFAULT (''),
[LightUp] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PTLTran_LightUp] DEFAULT ((0)),
[LightMode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PTLTran_LightMode] DEFAULT (''),
[LightSequence] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PTLTran_LightSequence] DEFAULT (''),
[UOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PTLTran_UOM] DEFAULT (''),
[RefPTLKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PTLTran_RefPTLKey] DEFAULT ('')
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
  
/*********************************************************************************/    
/* Trigger:  ntrPTLTranUpdate                                                    */  
/* Creation Date:                                                                */  
/* Copyright: IDS                                                                */  
/* Written by:                                                                   */  
/*                                                                               */  
/* Purpose:  Trigger point upon any Update on the PTLTran                        */  
/*                                                                               */  
/* Return Status:  None                                                          */  
/*                                                                               */  
/* Usage:                                                                        */  
/*                                                                               */  
/* Local Variables:                                                              */  
/*                                                                               */  
/* Called By: When records updated                                               */  
/*                                                                               */  
/* PVCS Version: 1.0                                                             */  
/*                                                                               */  
/* Version: 5.4                                                                  */  
/*                                                                               */  
/* Data Modifications:                                                           */  
/*                                                                               */  
/* Updates:                                                                      */  
/* Date         Author    Ver.  Purposes                                         */  
/* 28-Oct-2013  TLTING    1.1  Review Editdate column update                     */
/*********************************************************************************/    
  
CREATE TRIGGER [dbo].[ntrPTLTranUpdate]  
ON  [dbo].[PTLTran]  
FOR UPDATE  
AS  
BEGIN -- main  
   IF @@ROWCOUNT = 0    
   BEGIN    
      RETURN    
   END       
   SET NOCOUNT ON  
   SET ANSI_NULLS OFF  
   SET QUOTED_IDENTIFIER OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  
     
   DECLARE @b_Success            int       -- Populated by calls to stored procedures - was the proc successful?  
         , @n_err                int       -- Error number returned by stored procedure or this trigger  
         , @c_errmsg             nvarchar(250) -- Error message returned by stored procedure or this trigger  
         , @n_continue           int                   
         , @n_starttcnt          int       -- Holds the current transaction count  
         , @n_cnt                int  
  
   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT, @n_cnt = 0  
  
   IF UPDATE(TrafficCop)  
   BEGIN  
      SELECT @n_continue = 4   
   END  
  
   IF (@n_continue = 1 or @n_continue = 2) AND NOT UPDATE(EditDate)    
   BEGIN  
     UPDATE PTLTran WITH (ROWLOCK)  
     SET PTLTran.EditWho = SUSER_SNAME(),  
         PTLTran.EditDate = GETDATE()  
     FROM PTLTran JOIN INSERTED ON PTLTran.PTLKey = INSERTED.PTLKey  
       SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT  
       IF @n_err <> 0  
       BEGIN  
          SELECT @n_continue = 3  
          SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 82202   -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
          SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Update Trigger On Table PTLTran Failed. (ntrPTLTranDelete)" + " ( " + " SQLSvr MESSAGE=" + LTrim(RTrim(@c_errmsg)) + " ) "  
       END  
   END  
  
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
    EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrPTLTranUpdate'  
    RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012  
    RETURN  
   END  
   ELSE  
   BEGIN  
    WHILE @@TRANCOUNT > @n_starttcnt  
    BEGIN  
       COMMIT TRAN  
    END  
    RETURN  
   END  
END -- main  
GO
ALTER TABLE [dbo].[PTLTran] ADD CONSTRAINT [PK_PTLTran] PRIMARY KEY CLUSTERED ([PTLKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_PTLTRAN_DeviceID] ON [dbo].[PTLTran] ([DeviceID]) INCLUDE ([LightUp]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_PTLTRAN_01] ON [dbo].[PTLTran] ([DeviceProfileLogKey], [DevicePosition]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PTLTran_Key1] ON [dbo].[PTLTran] ([IPAddress], [DevicePosition], [Status]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[PTLTran] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[PTLTran] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[PTLTran] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[PTLTran] TO [NSQL]
GO
