IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[isp_exec_populate_receipt]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[isp_exec_populate_receipt]
GO

/****** Object:  StoredProcedure [dbo].[isp_exec_populate_receipt]    Script Date: 11/09/2007 17:42:29 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[isp_exec_populate_receipt] (
@c_spname NVARCHAR(100),
@c_stdkey NVARCHAR(10),
@c_storer NVARCHAR(18),
@c_logwhse NVARCHAR(18),
@c_vessel NVARCHAR(10), 
@c_facility NVARCHAR(5),
@c_receiptkey NVARCHAR(10) OUTPUT
)

AS
BEGIN
	 SET NOCOUNT ON
	 SET QUOTED_IDENTIFIER OFF	
   SET CONCAT_NULL_YIELDS_NULL OFF
	-- Created by MaryVong on 04-Feb-2004 (FBR18043: NZMM Project)
	
	DECLARE @c_SQLstmt nvarchar(3000)

	SELECT @c_SQLstmt = 'EXEC @ac_spname @ac_stdkey, @ac_storer, @ac_logwhse, @ac_vessel, @ac_facility, @ac_receiptkey OUTPUT'

	EXEC sp_executesql @c_SQLstmt, N'@ac_spname NVARCHAR(100), @ac_stdkey NVARCHAR(10), @ac_storer NVARCHAR(18), 
												@ac_logwhse NVARCHAR(18), @ac_vessel NVARCHAR(10), @ac_facility NVARCHAR(5), 
												@ac_receiptkey NVARCHAR(10) OUTPUT', 
												@ac_spname = @c_spname, @ac_stdkey = @c_stdkey, @ac_storer = @c_storer, 
												@ac_logwhse = @c_logwhse, @ac_vessel = @c_vessel, @ac_facility = @c_facility, 
												@ac_receiptkey = @c_receiptkey OUTPUT 

END
GO

GRANT EXECUTE on isp_exec_populate_receipt to nSQL
GO
