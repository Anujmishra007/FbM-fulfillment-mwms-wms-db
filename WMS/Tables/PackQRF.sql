CREATE TABLE [dbo].[PackQRF]
(
[PackQRFKey] [bigint] NOT NULL IDENTITY(1, 1),
[PickSlipNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PackQRF_PickSlipNo] DEFAULT (''),
[CartonNo] [int] NOT NULL CONSTRAINT [DF_PackQRF_CartonNo] DEFAULT ((0)),
[LabelLine] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PackQRF_LabelLine] DEFAULT (''),
[QRCode] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PackQRF_QRCode] DEFAULT (''),
[RFIDNo] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PackQRF_RFIDNo] DEFAULT (''),
[TIDNo] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PackQRF_TIDNo] DEFAULT (''),
[AddDate] [datetime] NULL CONSTRAINT [DF_PackQRF_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PackQRF_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_PackQRF_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PackQRF_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QRFGroupKey] [int] NOT NULL CONSTRAINT [DF_PackQRF_QRFGroupKey] DEFAULT ((0))
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/        
/* Trigger: ntrPackQRFDelete                                            */        
/* Creation Date:                                                       */        
/* Copyright: IDS                                                       */        
/* Written by: Wan                                                      */        
/*                                                                      */        
/* Purpose: WMS-14315 - [CN] NIKE_O2_Ecom Packing_CR                    */        
/*                                                                      */        
/* Usage:                                                               */        
/*                                                                      */        
/* Called By: When records delete from PackDetail                       */        
/*                                                                      */        
/* PVCS Version: 2.0                                                    */        
/*                                                                      */        
/* Version: 5.4                                                         */        
/*                                                                      */        
/* Modifications:                                                       */        
/* Date         Author     Ver.  Purposes                               */    
/************************************************************************/        
CREATE TRIGGER [dbo].[ntrPackQRFDelete] ON [dbo].[PackQRF]      
FOR  DELETE      
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
          
 DECLARE @b_Success     INT = 1 -- Populated by calls to stored procedures - was the proc successful?      
       , @n_err         INT = 0 -- Error number returned by stored procedure or this trigger      
       , @c_errmsg      NVARCHAR(250) = ''-- Error message returned by stored procedure or this trigger      
       , @n_continue    INT = 1     
       , @n_starttcnt   INT = @@TRANCOUNT  -- Holds the current transaction count      
  
       , @n_ExternOrdersKey         BIGINT = 0  
       , @n_ExternOrderDetailKey    BIGINT = 0

       , @c_Facility                NVARCHAR(5) = ''     
       , @c_Storerkey               NVARCHAR(15)= ''  
       
       , @c_PickSlipNo              NVARCHAR(10)= ''          
       , @c_Orderkey                NVARCHAR(10)= ''   
         
       , @cur_PQRF                  CURSOR 
       , @cur_EOD                   CURSOR        
                  
   IF (SELECT COUNT(1) FROM   DELETED) =      
      (SELECT COUNT(1) FROM   DELETED WHERE  DELETED.ArchiveCop = '9')      
   BEGIN      
      SET @n_continue = 4      
   END       
   
   --(Wan01) - START PackQRF
   IF @n_continue=1 OR @n_continue=2   
   BEGIN
      SET @cur_PQRF = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR   
      SELECT DISTINCT D.PickSlipNo
            , PH.Orderkey
            , EO.ExternOrdersKey
      FROM DELETED D
      JOIN PACKHEADER   PH WITH (NOLOCK) ON D.PickSlipNo= PH.PickSlipNo 
      JOIN EXTERNORDERS EO WITH (NOLOCK) ON EO.Orderkey = PH.Orderkey 
      LEFT OUTER JOIN PACKQRF PQRF WITH (NOLOCK) ON D.PickSlipNo= PQRF.PickSlipNo
      WHERE PH.[Status] < '9'
      AND   PH.Orderkey <> ''
      AND   PQRF.PackQRFKey IS NULL
      ORDER BY D.PickSlipNo

      OPEN @cur_PQRF  
          
      FETCH NEXT FROM @cur_PQRF INTO   @c_PickSlipNo
                                    ,  @c_Orderkey
                                    ,  @n_ExternOrdersKey  
        
      WHILE @@FETCH_STATUS = 0 
      BEGIN
         DELETE ExternOrders 
         WHERE ExternOrdersKey = @n_ExternOrdersKey    

         SET @n_err = @@ERROR      
         
         IF @n_err <> 0      
         BEGIN      
            SET @n_continue = 3      
            SET @c_errmsg = CONVERT(char(250),@n_err)
            SET @n_err = 62010
            SET @c_errmsg='NSQL'+CONVERT(char(6), @n_err)+': Delete Failed On Table ExternOrders. (ntrPackQRFDelete)' 
                           + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg), '') + ' ) '      
            BREAK
         END 

         SET @cur_EOD = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR 
         SELECT EOD.ExternOrderDetailKey
         FROM ExternOrdersDetail EOD WITH (NOLOCK)
         WHERE EOD.Orderkey = @c_Orderkey

         OPEN @cur_EOD

         FETCH NEXT FROM @cur_EOD INTO @n_ExternOrderDetailKey

         WHILE @@FETCH_STATUS <> -1
         BEGIN
            DELETE ExternOrdersDetail 
            WHERE ExternOrderDetailKey = @n_ExternOrderDetailKey  

            SET @n_err = @@ERROR      
         
            IF @n_err <> 0      
            BEGIN      
               SET @n_continue = 3      
               SET @c_errmsg = CONVERT(char(250),@n_err)
               SET @n_err = 62020
               SET @c_errmsg='NSQL'+CONVERT(char(6), @n_err)+': Delete Failed On Table ExternOrdersDetail. (ntrPackQRFDelete)' 
                              + ' ( ' + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_errmsg), '') + ' ) '      
               BREAK
            END     

            FETCH NEXT FROM @cur_EOD INTO @n_ExternOrderDetailKey
         END
         CLOSE @cur_EOD
         DEALLOCATE @cur_EOD

         FETCH NEXT FROM @cur_PQRF INTO   @c_PickSlipNo
                                       ,  @c_Orderkey
                                       ,  @n_ExternOrdersKey 
      END
      CLOSE @cur_PQRF
      DEALLOCATE @cur_PQRF
   END
   --(Wan01) - END PackQRF
 
   IF @n_continue=3 -- Error Occured - Process And Return      
   BEGIN      
      IF @@TRANCOUNT = 1      
      AND @@TRANCOUNT >= @n_starttcnt      
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
      EXECUTE nsp_logerror @n_err, @c_errmsg, "ntrPackQRFDelete"       
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
ALTER TABLE [dbo].[PackQRF] ADD CONSTRAINT [PK_PackQRF] PRIMARY KEY CLUSTERED ([PackQRFKey]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_PackQRF_PackCartonLine] ON [dbo].[PackQRF] ([PickSlipNo], [CartonNo], [LabelLine]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_PackQRF_QRFGroupKey] ON [dbo].[PackQRF] ([PickSlipNo], [CartonNo], [LabelLine], [QRFGroupKey]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_PackQRF_QRCode] ON [dbo].[PackQRF] ([QRCode]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_PackQRF_RFIDNo_TIDNo] ON [dbo].[PackQRF] ([RFIDNo], [TIDNo]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[PackQRF] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[PackQRF] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[PackQRF] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[PackQRF] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Keep Packing QRCOde/RFIDNo/TIDNo', 'SCHEMA', N'dbo', 'TABLE', N'PackQRF', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'AddDate', 'SCHEMA', N'dbo', 'TABLE', N'PackQRF', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'AddWho', 'SCHEMA', N'dbo', 'TABLE', N'PackQRF', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'ArchiveCop', 'SCHEMA', N'dbo', 'TABLE', N'PackQRF', 'COLUMN', N'ArchiveCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Carton #', 'SCHEMA', N'dbo', 'TABLE', N'PackQRF', 'COLUMN', N'CartonNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'EditDate', 'SCHEMA', N'dbo', 'TABLE', N'PackQRF', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'EditWho', 'SCHEMA', N'dbo', 'TABLE', N'PackQRF', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Label Line #', 'SCHEMA', N'dbo', 'TABLE', N'PackQRF', 'COLUMN', N'LabelLine'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Primary key', 'SCHEMA', N'dbo', 'TABLE', N'PackQRF', 'COLUMN', N'PackQRFKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Pick Slip #', 'SCHEMA', N'dbo', 'TABLE', N'PackQRF', 'COLUMN', N'PickSlipNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'QR Code', 'SCHEMA', N'dbo', 'TABLE', N'PackQRF', 'COLUMN', N'QRCode'
GO
EXEC sp_addextendedproperty N'MS_Description', 'QRF Group Key', 'SCHEMA', N'dbo', 'TABLE', N'PackQRF', 'COLUMN', N'QRFGroupKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'RFID No', 'SCHEMA', N'dbo', 'TABLE', N'PackQRF', 'COLUMN', N'RFIDNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'TID No', 'SCHEMA', N'dbo', 'TABLE', N'PackQRF', 'COLUMN', N'TIDNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'TrafficCop', 'SCHEMA', N'dbo', 'TABLE', N'PackQRF', 'COLUMN', N'TrafficCop'
GO
