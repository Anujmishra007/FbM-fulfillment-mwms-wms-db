if exists (select * from dbo.sysobjects where id = object_id(N'[RDT].[rdtPrintZPL_Confirm]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
   drop procedure [RDT].[rdtPrintZPL_Confirm]
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Store procedure: rdtPrintZPL_Confirm                                 */
/* Copyright      : LF Logistics                                        */
/*                                                                      */
/* Date       Rev  Author      Purposes                                 */
/* 05-03-2018 1.0  Ung         Created                                  */
/* 05-11-2018 1.1  James       Add to rdtprintjob_log (james01)         */
/************************************************************************/

CREATE PROC rdt.rdtPrintZPL_Confirm (
    @cParam1      NVARCHAR(MAX)  -- rdtPrintJob.JobID
   ,@cParam2      NVARCHAR(MAX)  
   ,@cParam3      NVARCHAR(MAX)
   ,@cStatus	   NVARCHAR( 1) 
   ,@cStatusDesc  NVARCHAR(MAX)
   ,@nErrNo       INT            OUTPUT
   ,@cErrMsg      NVARCHAR( 250) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @cJobID   NVARCHAR( 10)
   DECLARE @nJobID   INT
   DECLARE @bSuccess INT

   -- Param mapping
   SET @cJobID = @cParam1 

   -- Update print job
   UPDATE rdt.rdtPrintJob SET
      JobStatus = @cStatus, 
      EditDate = GETDATE(), 
      EditWho = SUSER_SNAME()
   WHERE JobID = @cJobID

   SET @nJobID = CAST( @cJobID AS INT)

   -- Status either 5 (error), 9 (success). move record to log if success
   IF @cStatus = '9'
   BEGIN
      EXEC [dbo].[isp_UpdateRDTPrintJobStatus]
          @n_JobID      = @nJobID
         ,@c_JobStatus  = @cStatus
         ,@c_JobErrMsg  = ''
         ,@b_Success    = @bSuccess OUTPUT
         ,@n_Err        = @nErrNo   OUTPUT
         ,@c_ErrMsg     = @cErrMsg  OUTPUT
   END
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON RDT.rdtPrintZPL_Confirm TO NSQL
GO
