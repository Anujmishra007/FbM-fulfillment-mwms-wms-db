/****** Object:  Trigger [ntrChannelTransferUpdate]    Script Date: 10/18/2018 6:14:09 PM ******/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ntrChannelTransferUpdate]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
DROP TRIGGER [dbo].[ntrChannelTransferUpdate]
GO

  
/*******************************************************************************/    
/* Store Procedure:  ntrChannelTransferUpdate                                  */    
/* Creation Date: 16-Oct-2018                                                  */    
/* Copyright: LFL                                                              */    
/* Written by: YokeBeen                                                        */    
/*                                                                             */    
/* Purpose:  ChannelTransfer Update Trigger                                    */    
/*                                                                             */    
/* Usage: Trigger Points                                                       */    
/*                                                                             */    
/* Called By:                                                                  */    
/*                                                                             */    
/* PVCS Version: 1.0                                                           */    
/*                                                                             */    
/* Version: 1.0                                                                */    
/*                                                                             */    
/* Data Modifications:                                                         */    
/*                                                                             */    
/* Updates:                                                                    */    
/* Date         Author       Ver.   Purposes                                   */    
/* DD-MMM-YYYY                                                                 */    
/*******************************************************************************/    
    
CREATE TRIGGER [dbo].[ntrChannelTransferUpdate]    
ON  [dbo].[ChannelTransfer]    
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
    
   DECLARE @b_Success               int            -- Populated by calls to stored procedures - was the proc successful?    
         , @n_err                   int            -- Error number returned by stored procedure or this trigger    
         , @n_err2                  int            -- For Additional Error Detection    
         , @c_errmsg                NVARCHAR(250)  -- Error message returned by stored procedure or this trigger    
         , @n_continue              int     
         , @n_starttcnt             int            -- Holds the current transaction count    
         , @n_cnt                   int                      
  
   DECLARE @c_ChannelTransferKey    NVARCHAR(10)     
         , @c_FromStorerKey         nvarchar(15)     
         , @c_ToStorerKey           nvarchar(15)     
         , @c_Type                  NVARCHAR(12)     
         , @c_ReasonCode            NVARCHAR(10)       
         , @c_Status                nvarchar(10)    
         , @c_TriggerName           nvarchar(120)    
         , @c_SourceTable           nvarchar(60)    
  
   SET @c_TriggerName = 'ntrChannelTransferUpdate'    
   SET @c_SourceTable = 'CHANNELTRANSFER'    
     
   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT    
    
   IF UPDATE(ArchiveCop)    
   BEGIN    
      SELECT @n_continue = 4     
   END    
       
   IF UPDATE(TrafficCop)    
   BEGIN    
      SELECT @n_continue = 4     
   END    
    
/********************************************************/    
/* Interface Trigger Points Calling Process - (Start)   */    
/********************************************************/    
   IF @n_continue = 1 OR @n_continue = 2     
   BEGIN     
      IF UPDATE(Status)    
      BEGIN   
         IF EXISTS (SELECT 1 FROM DELETED    
                      JOIN ChannelTransfer WITH (NOLOCK) ON (DELETED.ChannelTransferkey = ChannelTransfer.ChannelTransferkey)     
                     WHERE DELETED.[STATUS] <> '9'    
                       AND ChannelTransfer.[STATUS] = '9')    
         BEGIN    
            DECLARE Cur_ChannelTransfer_TriggerPoints CURSOR LOCAL FAST_FORWARD READ_ONLY FOR     
            -- Extract values for required variables    
             SELECT ChannelTransfer.FromStorerkey     
                  , ChannelTransfer.ToStorerkey     
                  , ChannelTransfer.ChannelTransferkey    
                  , ChannelTransfer.[Type]    
                  , ChannelTransfer.ReasonCode     
                  , ChannelTransfer.[Status]    
               FROM INSERTED     
               JOIN DELETED WITH (NOLOCK) ON (INSERTED.ChannelTransferkey = DELETED.ChannelTransferkey)     
               JOIN ChannelTransfer WITH (NOLOCK) ON (INSERTED.ChannelTransferkey = ChannelTransfer.ChannelTransferkey)     
              WHERE DELETED.[Status] <> '9'    
                AND INSERTED.[Status] = '9'    
    
            OPEN Cur_ChannelTransfer_TriggerPoints    
            FETCH NEXT FROM Cur_ChannelTransfer_TriggerPoints INTO @c_FromStorerKey, @c_ToStorerKey, @c_ChannelTransferKey    
                                                                 , @c_Type, @c_ReasonCode, @c_Status    
    
            WHILE @@FETCH_STATUS <> -1    
            BEGIN    
               -- Execute SP - isp_ITF_ntrChannelTransfer    
               EXECUTE dbo.isp_ITF_ntrChannelTransfer     
                        @c_TriggerName    
                      , @c_SourceTable    
                      , @c_FromStorerKey    
                      , @c_ToStorerKey    
                      , @c_ChannelTransferKey    
                      , @b_Success  OUTPUT    
                      , @n_err      OUTPUT    
                      , @c_errmsg   OUTPUT    
    
               FETCH NEXT FROM Cur_ChannelTransfer_TriggerPoints INTO @c_FromStorerKey, @c_ToStorerKey, @c_ChannelTransferKey    
                                                                    , @c_Type, @c_ReasonCode, @c_Status    
            END -- WHILE @@FETCH_STATUS <> -1    
            CLOSE Cur_ChannelTransfer_TriggerPoints    
            DEALLOCATE Cur_ChannelTransfer_TriggerPoints    
         END -- IF EXISTS (SELECT 1 FROM INSERTED, DELETED)    
      END -- IF UPDATE(Status)    
   END -- IF @n_continue = 1 OR @n_continue = 2     
/********************************************************/    
/* Interface Trigger Points Calling Process - (End)     */    
/********************************************************/    
    
   QUIT_TR:  
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
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrChannelTransferUpdate'    
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    
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
END -- End PROC   
GO

