
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/************************************************************************/
/* Store procedure: ispPutCode_SkipLOC                                  */
/* Copyright: Maersk                                                    */
/* Purpose: Skip location                                               */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date         Author    Ver.  Purposes                                */
/* 2026-03-29   Ung       1.0   FCR-8112 Created                        */
/************************************************************************/

CREATE OR ALTER PROCEDURE dbo.ispPutCode_SkipLOC
    @n_PTraceHeadKey             NVARCHAR(10)
   ,@n_PTraceDetailKey           NVARCHAR(10)
   ,@c_PutawayStrategyKey        NVARCHAR(10)
   ,@c_PutawayStrategyLineNumber NVARCHAR(5)
   ,@c_StorerKey NVARCHAR(15)
   ,@c_SKU       NVARCHAR(20)
   ,@c_LOT       NVARCHAR(10)
   ,@c_FromLoc   NVARCHAR(10)
   ,@c_ID        NVARCHAR(18)
   ,@n_Qty       INT     
   ,@c_ToLoc     NVARCHAR(10)
   ,@c_Param1    NVARCHAR(20)
   ,@c_Param2    NVARCHAR(20)
   ,@c_Param3    NVARCHAR(20)
   ,@c_Param4    NVARCHAR(20)
   ,@c_Param5    NVARCHAR(20)
   ,@b_debug     INT
   ,@c_SQL       NVARCHAR( 1000) OUTPUT
   ,@b_RestrictionsPassed INT    OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_IsRDT INT 
   EXECUTE RDT.rdtIsRDT @n_IsRDT OUTPUT 
 
   -- RDT only feature. SCE does not have skip LOC screen. 
   IF @n_IsRDT = 1 
   BEGIN            
      -- Get session info
      DECLARE @nMobile  INT
      DECLARE @nFunc    INT
      SELECT 
         @nMobile = Mobile, 
         @nFunc = Func
      FROM rdt.rdtMobRec WITH (NOLOCK) 
      WHERE UserName = SUSER_SNAME()
      
      -- Generate T-SQL
      IF @c_ToLoc = ''
      BEGIN
         IF @b_debug = 1
            -- Putaway trace turn on, LOC is not pre-filter out
            SET @c_SQL = '' 
         ELSE
            SET @c_SQL = 
               ' AND NOT EXISTS( ' + 
                  ' SELECT 1 ' + 
                  ' FROM rdt.rdtPutawaySkipLOCLog SkipLOC WITH (NOLOCK) ' + 
                  ' WHERE SkipLOC.Mobile = ' + CAST( @nMobile AS NVARCHAR( 5)) + 
                     ' AND SkipLOC.Func = ' + CAST( @nFunc AS NVARCHAR( 5)) + 
                     ' AND SkipLOC.LOC = LOC.LOC) '
         RETURN
      END
      
      -- Restriction test
      IF @c_ToLoc <> ''
      BEGIN
         DECLARE @c_Reason NVARCHAR( 80)
         DECLARE @cSkipLOC NVARCHAR( 10) = ''

         -- Get skip LOC
         SELECT TOP 1 
            @cSkipLOC = LOC
         FROM rdt.rdtPutawaySkipLOCLog WITH (NOLOCK)
         WHERE Mobile = @nMobile
            AND Func = @nFunc
            AND LOC = @c_ToLoc

         IF @cSkipLOC = ''
         BEGIN
            IF @b_debug = 1
            BEGIN
               SELECT @c_Reason = 'PASSED PutCode: ispPutCode_SkipLOC. LOC is not skip = ' + @c_ToLoc
               EXEC nspPTD 'nspRDTPASTD', @n_pTraceHeadKey, @c_PutawayStrategyKey, @c_PutawayStrategyLineNumber, @n_PtraceDetailKey, @c_ToLoc, @c_Reason
            END
         END
         ELSE
         BEGIN
            IF @b_debug = 1
            BEGIN
               SELECT @c_Reason = 'FAILED PutCode: ispPutCode_SkipLOC. LOC is skipped = ' + @c_ToLoc
               EXEC nspPTD 'nspRDTPASTD', @n_pTraceHeadKey, @c_PutawayStrategyKey, @c_PutawayStrategyLineNumber, @n_PtraceDetailKey, @c_ToLoc, @c_Reason
            END
            SET @b_RestrictionsPassed = 0 --False
         END
      END
   END
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON dbo.ispPutCode_SkipLOC TO NSQL
GO
