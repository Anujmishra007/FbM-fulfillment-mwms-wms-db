CREATE TABLE [RDT].[rdtPTLStationLog]
(
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[Station] [nvarchar] (10) NOT NULL,
[IPAddress] [nvarchar] (40) NOT NULL,
[Position] [nvarchar] (10) NOT NULL,
[LOC] [nvarchar] (10) NOT NULL CONSTRAINT [DF_rdtPTLStationLog_LOC] DEFAULT (''),
[Method] [nvarchar] (1) NOT NULL CONSTRAINT [DF_rdtPTLStationLog_Method] DEFAULT (''),
[CartonID] [nvarchar] (20) NOT NULL CONSTRAINT [DF_rdtPTLStationLog_CartonID] DEFAULT (''),
[OrderKey] [nvarchar] (10) NOT NULL CONSTRAINT [DF_rdtPTLStationLog_OrderKey] DEFAULT (''),
[LoadKey] [nvarchar] (10) NOT NULL CONSTRAINT [DF_rdtPTLStationLog_LoadKey] DEFAULT (''),
[WaveKey] [nvarchar] (10) NOT NULL CONSTRAINT [DF_rdtPTLStationLog_WaveKey] DEFAULT (''),
[PickSlipNo] [nvarchar] (10) NOT NULL CONSTRAINT [DF_rdtPTLStationLog_PickSlipNo] DEFAULT (''),
[BatchKey] [nvarchar] (20) NOT NULL CONSTRAINT [DF_rdtPTLStationLog_BatchKey] DEFAULT (''),
[ConsigneeKey] [nvarchar] (15) NOT NULL CONSTRAINT [DF_rdtPTLStationLog_ConsigneeKey] DEFAULT (''),
[ShipTo] [nvarchar] (15) NOT NULL CONSTRAINT [DF_rdtPTLStationLog_ShipTo] DEFAULT (''),
[StorerKey] [nvarchar] (15) NOT NULL CONSTRAINT [DF_rdtPTLStationLog_StorerKey] DEFAULT (''),
[MaxTask] [int] NOT NULL CONSTRAINT [DF_rdtPTLStationLog_MaxTask] DEFAULT ((0)),
[UserDefine01] [nvarchar] (30) NOT NULL CONSTRAINT [DF_rdtPTLStationLog_UserDefine01] DEFAULT (''),
[UserDefine02] [nvarchar] (30) NOT NULL CONSTRAINT [DF_rdtPTLStationLog_UserDefine02] DEFAULT (''),
[UserDefine03] [nvarchar] (30) NOT NULL CONSTRAINT [DF_rdtPTLStationLog_UserDefine03] DEFAULT (''),
[SourceKey] [nvarchar] (20) NOT NULL CONSTRAINT [DF_rdtPTLStationLog_SourceKey] DEFAULT (''),
[SourceType] [nvarchar] (30) NOT NULL CONSTRAINT [DF_rdtPTLStationLog_SourceType] DEFAULT (''),
[CreatedPTLTran] [nvarchar] (1) NOT NULL CONSTRAINT [DF_rdtPTLStationLog_CreatedPTLTran] DEFAULT (''),
[AddWho] [nvarchar] (128) NOT NULL CONSTRAINT [DF_rdtPTLStationLog_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_rdtPTLStationLog_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) NOT NULL CONSTRAINT [DF_rdtPTLStationLog_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_rdtPTLStationLog_EditDate] DEFAULT (getdate()),
[SKU] [nvarchar] (20) NOT NULL CONSTRAINT [DF_rdtPTLStationLog_SKU] DEFAULT (''),
[ItemClass] [nvarchar] (10) NOT NULL CONSTRAINT [DF_rdtPTLStationLog_ItemClass] DEFAULT ('')
) ON [PRIMARY]
GO


/************************************************************************/
/* Trigger: ntrrdtPTLStationLogDelete                                   */
/* Creation Date: 14 July 2016                                          */
/* Copyright: LF                                                        */
/* Written by: ChewKP                                                   */
/*                                                                      */
/* Purpose:                                                             */
/*                                                                      */
/* Usage:                                                               */
/*                                                                      */
/* Called By: When records removed from rdt.rdtPTLStationLog            */
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Modifications:                                                       */
/* Date         Author   Ver  Purposes                                  */
/*                                                                      */
/************************************************************************/

CREATE TRIGGER [RDT].[ntrrdtPTLStationLogDelete]
ON [RDT].[rdtPTLStationLog]
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

   DECLARE  @b_Success     int,       -- Populated by calls to stored procedures - was the proc successful?
            @n_err         int,       -- Error number returned by stored procedure or this trigger
            @c_errmsg      NVARCHAR(250), -- Error message returned by stored procedure or this trigger
            @n_continue    int,       -- continuation flag: 1=Continue, 2=failed but continue processsing, 3=failed do not continue processing, 4=successful but skip further processing
            @n_starttcnt   int,       -- Holds the current transaction count
            @n_cnt         int,       -- Holds the number of rows affected by the DELETE statement that fired this trigger.
            @c_authority   NVARCHAR(1)
   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT

   --IF (SELECT COUNT(*) FROM DELETED) = (SELECT COUNT(*) FROM DELETED WHERE DELETED.ArchiveCop = '9')
   --BEGIN
   --   SELECT @n_continue = 4
   --END

      /* #INCLUDE <TRCONHD1.SQL> */     
   IF @n_continue = 1 or @n_continue = 2
   BEGIN
      SELECT @b_success = 0
      EXECUTE nspGetRight  NULL,             -- facility  
                           NULL,             -- Storerkey  
                           NULL,             -- Sku  
                           'DataMartDELLOG', -- Configkey  
                           @b_success     OUTPUT, 
                           @c_authority   OUTPUT, 
                           @n_err         OUTPUT, 
                           @c_errmsg      OUTPUT  
      IF @b_success <> 1
      BEGIN
         SELECT @n_continue = 3
               ,@c_errmsg = 'ntrrdtPTLStationLogDelete' + dbo.fnc_RTrim(@c_errmsg)
      END
      ELSE 
      IF @c_authority = '1'
      BEGIN
         INSERT INTO rdt.rdtPTLStationLog_DELLOG 
               ( Station, IPAddress, Position, LOC, Method, CartonID, OrderKey, LoadKey, WaveKey, PickSlipNo, BatchKey, ConsigneeKey, ShipTo,  StorerKey, 
                 MaxTask, UserDefine01, UserDefine02, UserDefine03, SourceKey, SourceType, AddWho,  AddDate, EditWho, EditDate, CreatedPTLTran )
         SELECT  Station, IPAddress, Position, LOC, Method, CartonID, OrderKey, LoadKey, WaveKey, PickSlipNo, BatchKey, ConsigneeKey, ShipTo,  StorerKey, 
                 MaxTask, UserDefine01, UserDefine02, UserDefine03, SourceKey, SourceType, EditWho,  Editdate, suser_sname(), GetDate(), CreatedPTLTran
         FROM DELETED

         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 60714   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Delete Trigger On Table Dropid Failed. (ntrrdtPTLStationLogDelete)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
         END
      END
   END

   /* #INCLUDE <TRCOND2.SQL> */
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
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrrdtPTLStationLogDelete'
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
END
GO
ALTER TABLE [RDT].[rdtPTLStationLog] ADD CONSTRAINT [PK_rdtPTLStationLog] PRIMARY KEY CLUSTERED ([RowRef]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_rdtPTLStationLog_Loc] ON [RDT].[rdtPTLStationLog] ([LOC]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_rdtPTLStationLog_Orderkey] ON [RDT].[rdtPTLStationLog] ([OrderKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_rdtPTLStationLog_Station_CartonID_Position] ON [RDT].[rdtPTLStationLog] ([Station], [CartonID], [Position]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[rdtPTLStationLog] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[rdtPTLStationLog] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[rdtPTLStationLog] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[rdtPTLStationLog] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[rdtPTLStationLog] TO [JReportRole]
GO

