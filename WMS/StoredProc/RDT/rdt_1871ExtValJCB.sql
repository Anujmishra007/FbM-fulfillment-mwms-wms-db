
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*******************************************************************************/
/* Store procedure: rdt_1871ExtValJCB                                          */
/* Copyright      : Maersk                                                     */
/*                                                                             */
/* Purpose: RDT Task Manager - Move                                            */
/*                                                                             */
/* Modifications log:                                                          */
/*                                                                             */
/* Date        Rev    Author   Purposes                                        */
/* 2025-11-11  1.0.0  PPA374   Check if to loc is on hold                      */
/*******************************************************************************/
CREATE OR ALTER PROC [RDT].[rdt_1871ExtValJCB](
   @nMobile         INT,          
   @nFunc           INT,          
   @cLangCode       NVARCHAR( 3),             
   @nStep           INT,          
   @nScn            INT,          
   @cAreaKey        NVARCHAR( 10),            
   @cID             NVARCHAR( 18),            
   @cToLoc          NVARCHAR( 10),            
   @cEquipmentProfileKey NVARCHAR( 10),       
   @cNewEquipmentProfileKey NVARCHAR( 10),    
   @cTaskdetailKey  NVARCHAR( 10),            
   @cReasonCode     NVARCHAR(10),              
   @nErrNo          INT OUTPUT,   
   @cErrMsg         NVARCHAR( 20) OUTPUT
) AS

BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @nInputKey AS INT
   DECLARE @cLocToCheck AS NVARCHAR(20)

   SELECT TOP 1 @nInputKey = InputKey FROM RDT.RDTMOBREC WITH(NOLOCK) WHERE Mobile = @nMobile
   SELECT TOP 1 @cLocToCheck = ToLoc FROM dbo.TaskDetail WITH(NOLOCK) WHERE Status IN ('0','3') AND FromID = @cID

   IF @nStep = 3
   BEGIN
      IF @nInputKey = 1
	  BEGIN
	     IF EXISTS (SELECT 1 FROM LOC WITH(NOLOCK) WHERE LOC = @cLocToCheck AND (Status <> 'OK' OR LocationFlag NOT IN ('','NONE')))
		 BEGIN
		    SET @nErrNo = 218260
		    SET @cErrMsg = rdt.rdtgetmessage( @nErrNo, @cLangCode,'DSP')--'ID got loc on hold'
	     END
	  END
   END
END
GO
GRANT EXECUTE ON rdt_1871ExtValJCB TO NSQL
GO
