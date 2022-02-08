CREATE TABLE [dbo].[PackSerialNo]
(
[PackSerialNoKey] [bigint] NOT NULL IDENTITY(1, 1),
[PickSlipNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CartonNo] [int] NOT NULL,
[LabelNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LabelLine] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SerialNo] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[QTY] [int] NOT NULL,
[PickDetailKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PackSerialNo_PickDetailKey] DEFAULT (''),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PackSerialNo_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_PackSerialNo_AddDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PackSerialNo_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_PackSerialNo_EditDate] DEFAULT (getdate()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Trigger: ntrPackSerialNoAdd                                          */
/* Copyright: LF Logistics                                              */
/*                                                                      */
/* Date         Author     Ver.  Purposes                               */
/* 2017-May-29  Ung        1.1   WMS-1919 Created                       */
/************************************************************************/
CREATE TRIGGER [dbo].[ntrPackSerialNoAdd] ON [dbo].[PackSerialNo]
FOR  INSERT
AS
BEGIN
   IF @@ROWCOUNT = 0
      RETURN
   
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
   
   DECLARE @b_Success   int,       -- Populated by calls to stored procedures - was the proc successful?      
           @n_err       int,       -- Error number returned by stored procedure or this trigger      
           @c_errmsg    NVARCHAR(250), -- Error message returned by stored procedure or this trigger      
           @n_continue  int,       -- continuation flag: 1=Continue, 2=failed but continue processsing, 3=failed do not continue processing, 4=successful but skip further processing      
           @n_starttcnt int,       -- Holds the current transaction count      
           @n_cnt       int        -- Holds the number of rows affected by the Update statement that fired this trigger.      
  
   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT, @b_success=0, @n_err=0, @c_errmsg=''  

   
   IF EXISTS( SELECT 1 FROM INSERTED WHERE ArchiveCop = '9')
      SELECT @n_continue = 4
      
   -- Check pack confirmed
   IF @n_continue = 1 OR @n_continue = 2
   BEGIN
      IF EXISTS( SELECT TOP 1 1 
         FROM INSERTED
            JOIN PackHeader PH WITH (NOLOCK) ON (PH.PickSlipNo = INSERTED.PickSlipNo)
         WHERE PH.Status = '9')    
      BEGIN
         SELECT @n_continue = 3
         SELECT @c_errmsg = CONVERT(char(250),@n_err), @n_err = 110351
         SELECT @c_errmsg="NSQL"+CONVERT(char(6), @n_err)+": Insert fail due to Pack confirmed (ntrPackSerialNoAdd) (SQLSvr MESSAGE=" + LTRIM(RTRIM(@c_errmsg)) + ") "
      END
   END

   IF @n_continue = 3  -- Error Occured - Process And Return      
   BEGIN      
      SELECT @b_success = 0      
      DECLARE @n_IsRDT INT      
      EXECUTE RDT.rdtIsRDT @n_IsRDT OUTPUT      
      
      IF @n_IsRDT = 1      
      BEGIN      
         -- RDT cannot handle rollback (blank XML will generate). So we are not going to issue a rollback here      
         -- Instead we commit and raise an error back to parent, let the parent decide      
      
         -- Commit until the level we begin with      
         WHILE @@TRANCOUNT > @n_starttcnt      
            COMMIT TRAN      
      
         -- Raise error with severity = 10, instead of the default severity 16.      
         -- RDT cannot handle error with severity > 10, which stop the processing after executed this trigger      
         RAISERROR (@n_err, 10, 1) WITH SETERROR      
      
         -- The RAISERROR has to be last line, to ensure @@ERROR is not getting overwritten      
      END      
      ELSE      
      BEGIN      
         IF @@TRANCOUNT = 1 AND @@TRANCOUNT >= @n_starttcnt      
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
         EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrPackSerialNoAdd'      
         RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012      
         RETURN      
      END      
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
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/    
/* Trigger: ntrPackSerialNoDelete                                       */    
/* Creation Date: 2017-May-29                                           */    
/* Copyright: LFL                                                       */    
/* Written by:                                                          */    
/*                                                                      */    
/* Purpose: PackSerialNo Delete trigger                                 */
/*                                                                      */
/* Called By:                                                           */    
/*                                                                      */    
/* PVCS Version: 1.0                                                    */    
/*                                                                      */    
/* Version: 1.0                                                         */    
/*                                                                      */    
/* Data Modifications:                                                  */    
/*                                                                      */    
/* Updates:                                                             */    
/* Date         Author  Ver.  Purposes                                  */   
/* 2017-May-29  Ung     1.1   WMS-1919 Created                          */
/* 2021-Dec-08  NJOW01  1.2   WMS-18599 remove orderkey when reverse    */
/*                            serial number.                            */
/* 2021-Dec-08  NJOW01  1.2   DEVOPS combine script                     */
/************************************************************************/    

CREATE TRIGGER [ntrPackSerialNoDelete] ON [PackSerialNo] 
FOR  DELETE
AS
BEGIN
   IF @@ROWCOUNT = 0
      RETURN
   
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @b_Success   int,       -- Populated by calls to stored procedures - was the proc successful?      
           @n_err       int,       -- Error number returned by stored procedure or this trigger      
           @c_errmsg    NVARCHAR(250), -- Error message returned by stored procedure or this trigger      
           @n_continue  int,       -- continuation flag: 1=Continue, 2=failed but continue processsing, 3=failed do not continue processing, 4=successful but skip further processing      
           @n_starttcnt int,       -- Holds the current transaction count      
           @n_cnt       int        -- Holds the number of rows affected by the Update statement that fired this trigger.      
  
   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT, @b_success=0, @n_err=0, @c_errmsg=''

   if (select count(*) from DELETED) = 
      (select count(*) from DELETED where DELETED.ArchiveCop = '9')
   BEGIN
      SELECT @n_continue = 4
   END

   -- Check pack confirmed
   IF @n_continue = 1 OR @n_continue = 2
   BEGIN
      IF EXISTS( SELECT TOP 1 1 
         FROM DELETED
            JOIN PackHeader PH WITH (NOLOCK) ON (PH.PickSlipNo = DELETED.PickSlipNo)
         WHERE PH.Status = '9')    
      BEGIN
         SELECT @n_continue = 3
         SELECT @c_errmsg = CONVERT(char(250),@n_err), @n_err = 110251
         SELECT @c_errmsg="NSQL"+CONVERT(char(6), @n_err)+": Delete fail due to Pack confirmed (ntrPackSerialNoDelete) (SQLSvr MESSAGE=" + LTRIM(RTRIM(@c_errmsg)) + ") "
      END
   END

   -- Reverse SerialNo.Status
   IF @n_continue = 1 OR @n_continue = 2
   BEGIN
      DECLARE @c_SerialNoKey NVARCHAR(10)
      DECLARE @curPSNO CURSOR
      SET @curPSNO = CURSOR FOR
         SELECT SerialNoKey
         FROM DELETED D
            JOIN SerialNo SNO WITH (NOLOCK) ON (D.StorerKey = SNO.StorerKey AND D.SKU = SNO.SKU AND D.SerialNo = SNO.SerialNo)
         WHERE SNO.Status = '6'
      OPEN @curPSNO 
      FETCH NEXT FROM @curPSNO INTO @c_SerialNoKey
      WHILE @@FETCH_STATUS = 0
      BEGIN
         UPDATE SerialNo SET
            Status = '1', -- Received
            Orderkey = '',  --NJOW01
            OrderLineNumber = '',  --NJOW01
            EditDate = GETDATE(), 
            EditWho = SUSER_SNAME()
         WHERE SerialNoKey = @c_SerialNoKey
         IF @@ERROR <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(char(250),@n_err), @n_err = 110252
            SELECT @c_errmsg="NSQL"+CONVERT(char(6), @n_err)+": Update SerialNo table fail (ntrPackSerialNoDelete) (SQLSvr MESSAGE=" + LTRIM(RTRIM(@c_errmsg)) + ") "
         END
         FETCH NEXT FROM @curPSNO INTO @c_SerialNoKey
      END
   END

   IF @n_continue = 3  -- Error Occured - Process And Return      
   BEGIN      
      SELECT @b_success = 0      
      DECLARE @n_IsRDT INT      
      EXECUTE RDT.rdtIsRDT @n_IsRDT OUTPUT      
      
      IF @n_IsRDT = 1      
      BEGIN      
         -- RDT cannot handle rollback (blank XML will generate). So we are not going to issue a rollback here      
         -- Instead we commit and raise an error back to parent, let the parent decide      
      
         -- Commit until the level we begin with      
         WHILE @@TRANCOUNT > @n_starttcnt      
            COMMIT TRAN      
      
         -- Raise error with severity = 10, instead of the default severity 16.      
         -- RDT cannot handle error with severity > 10, which stop the processing after executed this trigger      
         RAISERROR (@n_err, 10, 1) WITH SETERROR      
      
         -- The RAISERROR has to be last line, to ensure @@ERROR is not getting overwritten      
      END      
      ELSE      
      BEGIN      
         IF @@TRANCOUNT = 1 AND @@TRANCOUNT >= @n_starttcnt      
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
         EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrPackSerialNoDelete'      
         RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012      
         RETURN      
      END      
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
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Trigger: ntrPackSerialNoUpdate                                       */
/* Copyright: LF Logistics                                              */
/*                                                                      */
/* Date         Author     Ver.  Purposes                               */
/* 2017-May-29  Ung        1.1   WMS-1919 Created                       */
/************************************************************************/
CREATE TRIGGER [dbo].[ntrPackSerialNoUpdate] ON [dbo].[PackSerialNo]
FOR  UPDATE
AS
BEGIN
   IF @@ROWCOUNT = 0
      RETURN
   
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @b_Success   int,       -- Populated by calls to stored procedures - was the proc successful?      
           @n_err       int,       -- Error number returned by stored procedure or this trigger      
           @c_errmsg    NVARCHAR(250), -- Error message returned by stored procedure or this trigger      
           @n_continue  int,       -- continuation flag: 1=Continue, 2=failed but continue processsing, 3=failed do not continue processing, 4=successful but skip further processing      
           @n_starttcnt int,       -- Holds the current transaction count      
           @n_cnt       int        -- Holds the number of rows affected by the Update statement that fired this trigger.      
  
   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT, @b_success=0, @n_err=0, @c_errmsg=''  

   IF UPDATE(ArchiveCop)        
   BEGIN        
      SELECT @n_continue = 4      
   END 

   IF (@n_continue = 1 OR @n_continue = 2) AND NOT UPDATE(EditDate)
   BEGIN     
      UPDATE PackSerialNo WITH (ROWLOCK) SET 
         EditDate = GETDATE(),     
         EditWho = SUSER_SNAME(),    
         TrafficCop = NULL     
      FROM INSERTED
         JOIN PackSerialNo ON (PackSerialNo.PackSerialNoKey = INSERTED.PackSerialNoKey)  
      SELECT @n_err = @@ERROR
      IF @n_err <> 0    
      BEGIN    
         SELECT @n_continue = 3    
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 110301
         SELECT @c_errmsg="NSQL"+CONVERT(char(6),@n_err)+": Update Failed On Table PackSerialNo (ntrPackSerialNoUpdate) (SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ") "    
      END    
   END  

   IF UPDATE(TrafficCop)        
   BEGIN        
      SELECT @n_continue = 4 /* No Error But Skip Processing */        
   END

   -- Check pack confirmed
   IF @n_continue = 1 OR @n_continue = 2
   BEGIN
      IF EXISTS( SELECT TOP 1 1 
         FROM INSERTED
            JOIN PackHeader PH WITH (NOLOCK) ON (PH.PickSlipNo = INSERTED.PickSlipNo)
         WHERE PH.Status = '9')    
      BEGIN
         SELECT @n_continue = 3
         SELECT @c_errmsg = CONVERT(char(250),@n_err), @n_err = 110302
         SELECT @c_errmsg="NSQL"+CONVERT(char(6), @n_err)+": Update fail due to Pack confirmed (ntrPackSerialNoUpdate) (SQLSvr MESSAGE=" + LTRIM(RTRIM(@c_errmsg)) + ") "
      END
   END

   IF @n_continue = 3  -- Error Occured - Process And Return      
   BEGIN      
      SELECT @b_success = 0      
      DECLARE @n_IsRDT INT      
      EXECUTE RDT.rdtIsRDT @n_IsRDT OUTPUT      
      
      IF @n_IsRDT = 1      
      BEGIN      
         -- RDT cannot handle rollback (blank XML will generate). So we are not going to issue a rollback here      
         -- Instead we commit and raise an error back to parent, let the parent decide      
      
         -- Commit until the level we begin with      
         WHILE @@TRANCOUNT > @n_starttcnt      
            COMMIT TRAN      
      
         -- Raise error with severity = 10, instead of the default severity 16.      
         -- RDT cannot handle error with severity > 10, which stop the processing after executed this trigger      
         RAISERROR (@n_err, 10, 1) WITH SETERROR      
      
         -- The RAISERROR has to be last line, to ensure @@ERROR is not getting overwritten      
      END      
      ELSE      
      BEGIN      
         IF @@TRANCOUNT = 1 AND @@TRANCOUNT >= @n_starttcnt      
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
         EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrPackSerialNoUpdate'      
         RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012      
         RETURN      
      END      
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
ALTER TABLE [dbo].[PackSerialNo] ADD CONSTRAINT [PK_PackSerialNo] PRIMARY KEY CLUSTERED ([PackSerialNoKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PACKSERIALNO_PickDetailkey] ON [dbo].[PackSerialNo] ([PickDetailKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PackSerialNo_PickSlipNo_CartonNo_LabelNo_LabelLine] ON [dbo].[PackSerialNo] ([PickSlipNo], [CartonNo], [LabelNo], [LabelLine]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_PACKSERIALNO_SERIALNO] ON [dbo].[PackSerialNo] ([SerialNo], [StorerKey]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[PackSerialNo] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[PackSerialNo] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[PackSerialNo] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[PackSerialNo] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[PackSerialNo] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Serial no of a pack detail line', 'SCHEMA', N'dbo', 'TABLE', N'PackSerialNo', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Optional link to PickDetail, mainly for outbound interface', 'SCHEMA', N'dbo', 'TABLE', N'PackSerialNo', 'COLUMN', N'PickDetailKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'QTY this serial no represent (could be more than 1)', 'SCHEMA', N'dbo', 'TABLE', N'PackSerialNo', 'COLUMN', N'QTY'
GO
