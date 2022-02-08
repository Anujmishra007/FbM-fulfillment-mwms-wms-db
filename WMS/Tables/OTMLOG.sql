CREATE TABLE [dbo].[OTMLOG]
(
[OTMLOGKey] [int] NOT NULL IDENTITY(1, 1),
[Tablename] [nvarchar] (30) NOT NULL CONSTRAINT [DF_OTMLOG_Tablename] DEFAULT (' '),
[Key1] [nvarchar] (10) NOT NULL CONSTRAINT [DF_OTMLOG_Key1] DEFAULT (' '),
[Key2] [nvarchar] (5) NOT NULL CONSTRAINT [DF_OTMLOG_Key2] DEFAULT (' '),
[Key3] [nvarchar] (20) NOT NULL CONSTRAINT [DF_OTMLOG_Key3] DEFAULT (' '),
[TransmitFlag] [nvarchar] (5) NOT NULL CONSTRAINT [DF_OTMLOG_TransmitFlag] DEFAULT ('0'),
[TransmitBatch] [nvarchar] (30) NULL CONSTRAINT [DF_OTMLOG_TransmitBatch] DEFAULT (' '),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_OTMLOG_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) NOT NULL CONSTRAINT [DF_OTMLOG_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_OTMLOG_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) NOT NULL CONSTRAINT [DF_OTMLOG_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) NULL,
[ArchiveCop] [nvarchar] (1) NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/  
/* Trigger: ntrOTMLogUpdate                                             */  
/* Creation Date: 21-Sep-2016                                           */  
/* Copyright: IDS                                                       */  
/* Written by: MCTang                                                   */  
/*                                                                      */  
/* Purpose: Trigger related Update in OTMLOG table.                     */  
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
  
CREATE TRIGGER [dbo].[ntrOTMLogUpdate]  
ON  [dbo].[OTMLOG]  
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
  
   DECLARE @b_debug int  
   SELECT  @b_debug = 0  

   DECLARE @b_Success            int         
         , @n_Err                int         
         , @n_Err2               int         
         , @c_ErrMsg             char(250)   
         , @n_Continue           int  
         , @n_StartTCnt          int   
         , @n_Cnt                int        
  
   SELECT @n_Continue=1, @n_StartTCnt=@@TRANCOUNT  
  
   IF UPDATE(ArchiveCop)
   BEGIN
      SELECT @n_continue = 4
   END

	IF UPDATE(TrafficCop)
	BEGIN
		SELECT @n_continue = 4 
	END
 
   IF ( @n_continue = 1 or @n_continue = 2 ) AND NOT UPDATE(EditDate)
   BEGIN
      UPDATE OTMLOG
      SET    EditDate   = GETDATE()
           , EditWho    = SUSER_SNAME()
           , Trafficcop = NULL
      FROM   OTMLOG, INSERTED
      WHERE  OTMLOG.OTMLOGKey = INSERTED.OTMLOGKey

      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
      IF @n_err <> 0
      BEGIN
         SELECT @n_continue = 3
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=72804   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
         SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Update Failed On Table OTMLOG. (ntrOTMLogUpdate)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
      END
   END
END
GO
ALTER TABLE [dbo].[OTMLOG] ADD CONSTRAINT [PKOTMLOG] PRIMARY KEY CLUSTERED ([OTMLOGKey]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_OTMLOG_CIdx] ON [dbo].[OTMLOG] ([Tablename], [Key1], [Key2], [Key3]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[OTMLOG] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[OTMLOG] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[OTMLOG] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[OTMLOG] TO [NSQL]
GO
