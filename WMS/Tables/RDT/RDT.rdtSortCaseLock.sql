CREATE TABLE [RDT].[rdtSortCaseLock]
(
[RowRef] [int] NOT NULL IDENTITY(1, 1),
[WaveKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtSortCaseLock_WaveKey] DEFAULT (''),
[LoadKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtSortCaseLock_LoadKey] DEFAULT (''),
[OrderKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtSortCaseLock_OrderKey] DEFAULT (''),
[LOC] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtSortCaseLock_LOC] DEFAULT (''),
[ID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtSortCaseLock_ID] DEFAULT (''),
[StorerKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtSortCaseLock_StorerKey] DEFAULT (''),
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtSortCaseLock_SKU] DEFAULT (''),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_rdtSortCaseLock_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_rdtSortCaseLock_AddDate] DEFAULT (getdate()),
[OptimizeCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/******************************************************************************/
/* Trigger:  rdtSortCaseLockAdd                                               */
/* Copyright: LF Logistics                                                    */
/*                                                                            */
/* Date        Author     Ver   Purposes                                      */
/* 06-03-2018  Ung        1.0   WMS-4202 Created                              */
/******************************************************************************/

CREATE TRIGGER [RDT].[ntrSortCaseLockAdd]
ON  [RDT].[rdtSortCaseLock]
FOR INSERT
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
      @n_err                int           -- Error number returned by stored procedure or this trigger
     ,@n_continue           int
     ,@n_starttcnt          int           -- Holds the current transaction count

   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT

   -- Skip trigger process if archive
   IF EXISTS( SELECT 1 FROM INSERTED WHERE ArchiveCop = '9')
   BEGIN
      SELECT @n_continue = 4
      GOTO QUIT
   END

   -- Skip trigger process if special requested
   IF EXISTS( SELECT 1 FROM INSERTED WHERE OptimizeCop IS NOT NULL)
   BEGIN
      SELECT @n_continue = 4
      GOTO QUIT
   END

   DECLARE @cWaveKey    NVARCHAR(10)
   DECLARE @cLoadKey    NVARCHAR(10)
   DECLARE @cOrderKey   NVARCHAR(10)
   DECLARE @cLOC        NVARCHAR(10)
   DECLARE @cID         NVARCHAR(18)
   DECLARE @cStorerKey  NVARCHAR(15)
   DECLARE @cSKU        NVARCHAR(20)

   IF @n_continue = 1 OR @n_continue=2
   BEGIN
      DECLARE @curSortCaseLock CURSOR
      SET @curSortCaseLock = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT WaveKey, LoadKey, OrderKey, LOC, ID, StorerKey, SKU
         FROM inserted WITH (NOLOCK)
   
      OPEN @curSortCaseLock
      FETCH NEXT FROM @curSortCaseLock INTO @cWaveKey, @cLoadKey, @cOrderKey, @cLOC, @cID, @cStorerKey, @cSKU
   
      WHILE @@FETCH_STATUS = 0
      BEGIN
         -- Check location locked by different user
         IF EXISTS( SELECT TOP 1 1
            FROM rdt.rdtSortCaseLock WITH (NOLOCK)
            WHERE WaveKey = @cWaveKey
               AND LoadKey = @cLoadKey
               AND OrderKey = @cOrderKey
               AND StorerKey = @cStorerKey
               AND SKU = @cSKU
               AND LOC = @cLOC
               AND ID = @cID
               AND AddWho <> SUSER_SNAME())
         BEGIN
            SELECT @n_continue = 3
            SELECT @n_err = 106901
            GOTO Quit
         END
         FETCH NEXT FROM @curSortCaseLock INTO @cWaveKey, @cLoadKey, @cOrderKey, @cLOC, @cID, @cStorerKey, @cSKU
      END
   END
   
Quit:

   IF @n_continue=3  -- Error Occured - Process And Return
   BEGIN
      -- RDT cannot handle rollback (blank XML will generate). So we are not going to issue a rollback here
      -- Instead we commit and raise an error back to parent, let the parent decide

      -- Commit until the level we begin with
      WHILE @@TRANCOUNT > @n_starttcnt
         COMMIT TRAN

      -- Raise error with severity = 10, instead of the default severity 16.
      -- RDT cannot handle error with severity > 10, which stop the processing after executed this trigger
      RAISERROR (@n_err, 10, 1) WITH SETERROR
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
ALTER TABLE [RDT].[rdtSortCaseLock] ADD CONSTRAINT [PK_rdtSortCaseLock] PRIMARY KEY CLUSTERED ([RowRef]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
GRANT DELETE ON  [RDT].[rdtSortCaseLock] TO [NSQL]
GO
GRANT INSERT ON  [RDT].[rdtSortCaseLock] TO [NSQL]
GO
GRANT SELECT ON  [RDT].[rdtSortCaseLock] TO [NSQL]
GO
GRANT UPDATE ON  [RDT].[rdtSortCaseLock] TO [NSQL]
GO
