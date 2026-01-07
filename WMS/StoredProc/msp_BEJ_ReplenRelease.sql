SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/***************************************************************************/
/* Stored Procedure: msp_BEJ_ReplenRelease                                 */
/*                                                                         */
/* Copyright: Maersk                                                       */
/*                                                                         */
/* Updates:                                                                */
/* Date           Author      Change                                       */
/* 04/12/2025     PPA374      JCB Replenishment BEJ                        */
/***************************************************************************/

CREATE OR ALTER PROC [dbo].[msp_BEJ_ReplenRelease]
AS

BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @dNextJobRun AS DATETIME
   DECLARE @nTimeGap    AS INT
   DECLARE @cStorerKey  AS NVARCHAR(20) 
   DECLARE @cFacility   AS NVARCHAR(20)
   DECLARE @n_err       AS INT
   DECLARE @c_ErrMsg    AS NVARCHAR(250)

   SELECT TOP 1 
      @cFacility = code2, 
	  @cStorerKey = StorerKey, 
	  @nTimeGap = IIF(UDF03='', 0, UDF03), 
	  @dNextJobRun = IIF(UDF04 = '', '1900-01-01', UDF04) 
   FROM dbo.CODELKUP WITH(NOLOCK)
   WHERE LISTNAME = 'BEJ'
      AND Code = 'BEJ-AutoReplenJCB'

   IF DATEADD(MINUTE, @nTimeGap, @dNextJobRun) <= GETDATE()
   BEGIN
      UPDATE dbo.CODELKUP
	  SET UDF04 = CONVERT(VARCHAR(23), GETDATE(), 121)
      WHERE LISTNAME = 'BEJ'
      AND Code = 'BEJ-AutoReplenJCB'

   EXEC	[dbo].[isp_GenReplenishmentJCB]
      @c_Zone01 = N'',
	  @c_Zone02 = N'',
	  @c_Zone03 = N'',
	  @c_Zone04 = N'',
	  @c_Zone05 = N'',
	  @c_Zone06 = N'',
	  @c_Zone07 = N'',
	  @c_Zone08 = N'',
	  @c_Zone09 = N'',
	  @c_Zone10 = N'',
	  @c_Zone11 = N'',
	  @c_Zone12 = N'',
	  @c_ReplenFlag = N'',
	  @c_storerkey = @cStorerKey

   EXEC [dbo].[ispRLREPDM]
      @c_Facility  = @cFacility,
      @c_zone02    = '',
      @c_zone03    = '',
      @c_zone04    = '',
      @c_zone05    = '',
      @c_zone06    = '',
      @c_zone07    = '',
      @c_zone08    = '',
      @c_zone09    = '',
      @c_zone10    = '',
      @c_zone11    = '',
      @c_zone12    = '',
      @c_Storerkey = @cStorerKey,
      @n_err       = @n_err OUTPUT,
      @c_ErrMsg    = @c_ErrMsg OUTPUT

   END
END
