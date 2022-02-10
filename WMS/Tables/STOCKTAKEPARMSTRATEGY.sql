CREATE TABLE [dbo].[STOCKTAKEPARMSTRATEGY]
(
[RowRef] [bigint] NOT NULL IDENTITY(1, 1),
[StockTakeKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_STOCKTAKEPARMSTRATEGY_StockTakeKey] DEFAULT (''),
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_STOCKTAKEPARMSTRATEGY_Storerkey] DEFAULT (''),
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_STOCKTAKEPARMSTRATEGY_Sku] DEFAULT (''),
[Loc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_STOCKTAKEPARMSTRATEGY_Loc] DEFAULT (''),
[Addwho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STOCKTAKEPARMSTRATEGY_Addwho] DEFAULT (suser_sname()),
[Adddate] [datetime] NULL CONSTRAINT [DF_STOCKTAKEPARMSTRATEGY_Adddate] DEFAULT (getdate()),
[Editwho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STOCKTAKEPARMSTRATEGY_Editwho] DEFAULT (suser_sname()),
[Editdate] [datetime] NULL CONSTRAINT [DF_STOCKTAKEPARMSTRATEGY_Editdate] DEFAULT (getdate()),
[Trafficcop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Archivecop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Trigger: ntrStockTakeParmStrategyUpdate                              */
/* Creation Date:  18-March-2020                                        */
/* Copyright: IDS                                                       */
/* Written by:  TLTING                                                  */
/*                                                                      */
/* Purpose: StockTakeParmStrategy Update                                */
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
/* Called By: When records updated                                      */
/*                                                                      */
/* PVCS Version: 1.5                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author   Ver  Purposes                                  */
/************************************************************************/

CREATE TRIGGER [dbo].[ntrStockTakeParmStrategyUpdate]
ON [dbo].[STOCKTAKEPARMSTRATEGY] FOR UPDATE
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
	
	DECLARE	 @n_err              INT           -- Error number returned by stored procedure or this trigger
	,         @c_errmsg           NVARCHAR(250) -- Error message returned by stored procedure or this trigger
	,         @n_continue         INT                 
	,         @n_starttcnt        INT           -- Holds the current transaction count
	,         @n_cnt              INT                  
	
	SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT

   IF UPDATE(ArchiveCop)
   BEGIN
   	SELECT @n_continue = 4 
   END
   
   -- TLTING01
	IF ( @n_continue = 1 or @n_continue=2 ) AND NOT UPDATE(EditDate)
	BEGIN
		UPDATE StockTakeParmStrategy WITH (ROWLOCK)
		SET EditDate = GETDATE(),
		    EditWho  = SUSER_SNAME(),
		    TrafficCop = NULL	
		FROM StockTakeParmStrategy , INSERTED WITH (NOLOCK)
		WHERE StockTakeParmStrategy.RowRef = INSERTED.RowRef

		SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
		IF @n_err <> 0
		BEGIN
			SELECT @n_continue = 3
			SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=62303   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
			SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": UPDATE Failed on StockTakeParmStrategy table. (ntrStockTakeParmStrategyUpdate)" + " ( " + " SQLSvr MESSAGE=" + LTrim(RTrim(@c_errmsg)) + " ) "
		END
	END

   IF UPDATE(TrafficCop)
   BEGIN
   	SELECT @n_continue = 4 
   END   
    
	
	IF @n_continue=3  -- Error Occured - Process And Return
	BEGIN
		IF @@TRANCOUNT = 1 and @@TRANCOUNT >= @n_starttcnt
		BEGIN
			ROLLBACK TRAN
		END
		EXECUTE nsp_logerror @n_err, @c_errmsg, "ntrStockTakeParmStrategyUpdate"
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
ALTER TABLE [dbo].[STOCKTAKEPARMSTRATEGY] ADD CONSTRAINT [PK_STOCKTAKEPARMSTRATEGY] PRIMARY KEY CLUSTERED ([RowRef]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_STOCKTAKEPARMSTRATEGY_Sku] ON [dbo].[STOCKTAKEPARMSTRATEGY] ([StockTakeKey], [Loc]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_STOCKTAKEPARMSTRATEGY_SkuxLoc] ON [dbo].[STOCKTAKEPARMSTRATEGY] ([StockTakeKey], [Storerkey], [Sku], [Loc]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[STOCKTAKEPARMSTRATEGY] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[STOCKTAKEPARMSTRATEGY] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[STOCKTAKEPARMSTRATEGY] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[STOCKTAKEPARMSTRATEGY] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Stock Take Record Generated By Strategy', 'SCHEMA', N'dbo', 'TABLE', N'STOCKTAKEPARMSTRATEGY', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record Created On Date', 'SCHEMA', N'dbo', 'TABLE', N'STOCKTAKEPARMSTRATEGY', 'COLUMN', N'Adddate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record Created by', 'SCHEMA', N'dbo', 'TABLE', N'STOCKTAKEPARMSTRATEGY', 'COLUMN', N'Addwho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Archivecop', 'SCHEMA', N'dbo', 'TABLE', N'STOCKTAKEPARMSTRATEGY', 'COLUMN', N'Archivecop'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record Edits on', 'SCHEMA', N'dbo', 'TABLE', N'STOCKTAKEPARMSTRATEGY', 'COLUMN', N'Editdate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Record Edits by', 'SCHEMA', N'dbo', 'TABLE', N'STOCKTAKEPARMSTRATEGY', 'COLUMN', N'Editwho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Location', 'SCHEMA', N'dbo', 'TABLE', N'STOCKTAKEPARMSTRATEGY', 'COLUMN', N'Loc'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Row Reference Key', 'SCHEMA', N'dbo', 'TABLE', N'STOCKTAKEPARMSTRATEGY', 'COLUMN', N'RowRef'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sku', 'SCHEMA', N'dbo', 'TABLE', N'STOCKTAKEPARMSTRATEGY', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Stock Take Key', 'SCHEMA', N'dbo', 'TABLE', N'STOCKTAKEPARMSTRATEGY', 'COLUMN', N'StockTakeKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Storer', 'SCHEMA', N'dbo', 'TABLE', N'STOCKTAKEPARMSTRATEGY', 'COLUMN', N'Storerkey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Trafficcop', 'SCHEMA', N'dbo', 'TABLE', N'STOCKTAKEPARMSTRATEGY', 'COLUMN', N'Trafficcop'
GO
