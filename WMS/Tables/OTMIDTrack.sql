CREATE TABLE [dbo].[OTMIDTrack]
(
[MUID] [int] NOT NULL IDENTITY(1, 1),
[TrackingNo] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CaseID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PalletKey] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Principal] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MUStatus] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderID] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShipmentID] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Length] [float] NULL,
[Width] [float] NULL,
[Height] [float] NULL,
[GrossWeight] [float] NULL,
[GrossVolume] [float] NULL,
[TruckID] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MUType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DropLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExternOrderKey] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ConsigneeKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LocationName] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine01] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine02] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine03] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine04] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserDefine05] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_OTMIDTrack_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_OTMIDTrack_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_OTMIDTrack_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_OTMIDTrack_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CartonGID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_OTMIDTrack_CartonGID] DEFAULT (''),
[CartonQty] [float] NULL CONSTRAINT [DF_OTMIDTrack_CartonQty] DEFAULT ((0))
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


/************************************************************************/  
/* Trigger: ntrOTMIDTrackAdd                                            */  
/* Creation Date: 05-Apr-2016                                           */  
/* Copyright: IDS                                                       */  
/* Written by: MCTang                                                   */  
/*                                                                      */  
/* Purpose: Trigger related Update in OTMIDTrack table.                 */  
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
  
CREATE TRIGGER [dbo].[ntrOTMIDTrackAdd]  
ON  [dbo].[OTMIDTrack]  
FOR INSERT
AS  
BEGIN   
   SET NOCOUNT ON  
   SET QUOTED_IDENTIFIER OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  
  
   DECLARE @b_debug int  
   SELECT @b_debug = 0  
   DECLARE @b_Success            INT         
         , @n_Err                INT                 
         , @c_ErrMsg             CHAR(250)   
         , @n_Continue           INT  
         , @n_StartTCnt          INT         

         , @n_MUID               INT   
         , @c_StorerKey          NVARCHAR(15)
         , @c_MUStatus           NVARCHAR(10)
  
   SELECT @n_Continue=1, @n_StartTCnt=@@TRANCOUNT  

   SET @n_MUID       = 0
   SET @c_StorerKey  = ''
   SET @c_MUStatus   = ''
  
   IF EXISTS( SELECT 1 FROM INSERTED WHERE ArchiveCop = '9')
      SELECT @n_continue = 4

   IF @n_Continue = 1 OR @n_Continue = 2   
   BEGIN    
   
      DECLARE OrdCur CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
      SELECT INSERTED.MUID
           , INSERTED.Principal
           , INSERTED.MUStatus
      FROM   INSERTED

      OPEN OrdCur

      FETCH NEXT FROM OrdCur INTO @n_MUID, @c_StorerKey, @c_MUStatus
      WHILE @@FETCH_STATUS <> -1
      BEGIN

         IF @c_MUStatus = '5'
         BEGIN
            IF EXISTS ( SELECT 1 FROM ITFTriggerConfig ITC WITH (NOLOCK)    
                        JOIN   StorerConfig STC WITH (NOLOCK)                                                          
                        ON    (STC.StorerKey   = @c_StorerKey AND STC.ConfigKey = 'OTMITF' AND STC.SValue = '1' AND STC.ConfigKey = ITC.ConfigKey)   
                        WHERE  ITC.StorerKey   = 'ALL'   
                        AND    ITC.SourceTable = 'OTMIDTrack'  
                        AND    ITC.sValue      = '1' )  
            BEGIN

               EXEC ispGenOTMLog 'IDTCK5OTM', @n_MUID, '', @c_StorerKey, ''  
                               , @b_Success   OUTPUT  
                               , @n_Err       OUTPUT  
                               , @c_ErrMsg    OUTPUT 

               IF @b_Success <> 1
               BEGIN
                  SET @n_Continue = 3
                  SELECT @c_ErrMsg = CONVERT(CHAR(250),@n_Err), @n_Err=62900   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
                  SELECT @c_ErrMsg = 'NSQL' + CONVERT(CHAR(5),ISNULL(@n_Err,0))
                                    + ': Insert Into OTMLOG Table Failed (ntrOTMIDTrackAdd) ( '
                                    + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_ErrMsg),'') + ' ) '
               END

            END -- IF EXISTS ( SELECT 1 FROM ITFTriggerConfig WITH (NOLOCK)   
         END -- IF @c_MUStatus = '5'
                  
         FETCH NEXT FROM OrdCur INTO @n_MUID, @c_StorerKey, @c_MUStatus
      END -- WHILE
      CLOSE OrdCur
      DEALLOCATE OrdCur
   END

/* #INCLUDE <TROHU2.SQL> */
   IF @n_Continue=3  -- Error Occured - Process And Return
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
      EXECUTE dbo.nsp_logerror @n_Err, @c_ErrMsg, 'ntrOTMIDTrackAdd'
      RAISERROR (@c_ErrMsg, 16, 1) WITH SETERROR    -- SQL2012
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
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/  
/* Trigger: ntrOTMIDTrackUpdate                                         */  
/* Creation Date: 05-Apr-2016                                           */  
/* Copyright: IDS                                                       */  
/* Written by: MCTang                                                   */  
/*                                                                      */  
/* Purpose: Trigger related Update in OTMIDTrack table.                 */  
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
  
CREATE TRIGGER [dbo].[ntrOTMIDTrackUpdate]  
ON  [dbo].[OTMIDTrack]  
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
   DECLARE @b_Success            INT         
         , @n_Err                INT                 
         , @c_ErrMsg             CHAR(250)   
         , @n_Continue           INT  
         , @n_StartTCnt          INT         

         , @n_MUID               INT   
         , @c_StorerKey          NVARCHAR(15)
         , @c_MUStatus           NVARCHAR(10)
  
   SELECT @n_Continue=1, @n_StartTCnt=@@TRANCOUNT  

   SET @n_MUID       = 0
   SET @c_StorerKey  = ''
   SET @c_MUStatus   = ''
  
   IF UPDATE(ArchiveCop)     
   BEGIN
      SELECT @n_Continue = 4
   END

   IF UPDATE(TrafficCop)
   BEGIN
      SELECT @n_Continue = 4
   END

   IF @n_Continue = 1 OR @n_Continue = 2   
   BEGIN    
   
      DECLARE OrdCur CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
      SELECT INSERTED.MUID
           , INSERTED.Principal
           , INSERTED.MUStatus
      FROM   INSERTED, DELETED
      WHERE  INSERTED.MUID = DELETED.MUID

      OPEN OrdCur

      FETCH NEXT FROM OrdCur INTO @n_MUID, @c_StorerKey, @c_MUStatus
      WHILE @@FETCH_STATUS <> -1
      BEGIN

         IF @c_MUStatus = '5'
         BEGIN
            IF EXISTS ( SELECT 1 FROM ITFTriggerConfig ITC WITH (NOLOCK)    
                        JOIN   StorerConfig STC WITH (NOLOCK)                                                          
                        ON    (STC.StorerKey   = @c_StorerKey AND STC.ConfigKey = 'OTMITF' AND STC.SValue = '1' AND STC.ConfigKey = ITC.ConfigKey)   
                        WHERE  ITC.StorerKey   = 'ALL'   
                        AND    ITC.SourceTable = 'OTMIDTrack'  
                        AND    ITC.sValue      = '1' )  
            BEGIN

               EXEC ispGenOTMLog 'IDTCK5OTM', @n_MUID, '', @c_StorerKey, ''  
                                 , @b_Success   OUTPUT  
                                 , @n_Err       OUTPUT  
                                 , @c_ErrMsg    OUTPUT 

               IF @b_Success <> 1
               BEGIN
                  SET @n_Continue = 3
                  SELECT @c_ErrMsg = CONVERT(CHAR(250),@n_Err), @n_Err=62900   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
                  SELECT @c_ErrMsg = 'NSQL' + CONVERT(CHAR(5),ISNULL(@n_Err,0))
                                    + ': Insert Into OTMLOG Table Failed (ntrOTMIDTrackUpdate) ( '
                                    + ' SQLSvr MESSAGE=' + ISNULL(RTRIM(@c_ErrMsg),'') + ' ) '
               END

            END -- IF EXISTS ( SELECT 1 FROM ITFTriggerConfig WITH (NOLOCK)   
         END -- IF @c_MUStatus = '5'
                  
         FETCH NEXT FROM OrdCur INTO @n_MUID, @c_StorerKey, @c_MUStatus
      END -- WHILE
      CLOSE OrdCur
      DEALLOCATE OrdCur
   END

/* #INCLUDE <TROHU2.SQL> */
   IF @n_Continue=3  -- Error Occured - Process And Return
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
      EXECUTE dbo.nsp_logerror @n_Err, @c_ErrMsg, 'ntrOTMIDTrackUpdate'
      RAISERROR (@c_ErrMsg, 16, 1) WITH SETERROR    -- SQL2012
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
ALTER TABLE [dbo].[OTMIDTrack] ADD CONSTRAINT [PK_OTMIDTrack_MUID] PRIMARY KEY CLUSTERED ([MUID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_OTMIDTrack_MUID_OrderID] ON [dbo].[OTMIDTrack] ([MUID], [OrderID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[OTMIDTrack] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[OTMIDTrack] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[OTMIDTrack] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[OTMIDTrack] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', N'OTM Carton GID', 'SCHEMA', N'dbo', 'TABLE', N'OTMIDTrack', 'COLUMN', N'CartonGID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'OTM Carton Qty', 'SCHEMA', N'dbo', 'TABLE', N'OTMIDTrack', 'COLUMN', N'CartonQty'
GO
