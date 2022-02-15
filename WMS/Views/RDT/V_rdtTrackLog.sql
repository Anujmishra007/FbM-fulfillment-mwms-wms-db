SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [RDT].[V_rdtTrackLog] 
AS 
SELECT [RowRef]
      ,[Mobile]
      ,[Username]
      ,[Storerkey]
      ,[Orderkey]
      ,[TrackNo]
      ,[SKU]
      ,[Qty]
      ,[QtyAllocated]
      ,[Status]
      ,[ErrMsg]
      ,[AddWho]
      ,[AddDate]
      ,[EditWho]
      ,[EditDate]
      ,[TrafficCop]
      ,[ArchiveCop]
  FROM [RDT].[rdtTrackLog] WITH (NOLOCK)
GO
