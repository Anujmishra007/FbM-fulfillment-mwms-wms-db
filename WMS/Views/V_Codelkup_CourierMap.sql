SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[V_Codelkup_CourierMap]
AS
select * from codelkup 
WHERE listname='CourierMap'
GO
