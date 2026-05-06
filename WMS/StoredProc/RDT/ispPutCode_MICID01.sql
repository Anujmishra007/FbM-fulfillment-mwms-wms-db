
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store procedure: ispPutCode_MICID01                                  */
/* Copyright: Maersk WMS                                                */
/*                                                                      */
/* Purpose:                                                             */
/*                                                                      */
/* Date         Author    Ver.  Purposes                                */
/* 2025-11-12   PYU015    1.0   UWP-54107 Created                       */
/************************************************************************/

CREATE OR ALTER   PROCEDURE [dbo].[ispPutCode_MICID01]
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
   ,@c_SQL       NVARCHAR(1000)  OUTPUT
   ,@b_RestrictionsPassed INT    OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @c_Reason            NVARCHAR(80)

   -- Generate T-SQL

   IF @c_ToLoc != ''
   BEGIN
       IF dbo.fnc_GetDot_MichWeek_Mix_Rule(@c_StorerKey,@c_ID,@c_ToLoc) = 0
       BEGIN
         IF @b_debug = 1
         BEGIN
            SELECT @c_Reason = 'FAILED PutCode: ispPutCode_MICID01, ToLoc is MixWeek, ToLoc = ' + @c_ToLoc
            EXEC nspPTD 'nspRDTPASTD', @n_pTraceHeadKey, @c_PutawayStrategyKey, @c_PutawayStrategyLineNumber, @n_PtraceDetailKey, @c_ToLoc, @c_Reason
         END
         SET @b_RestrictionsPassed = 0 --False
         RETURN
       END

       IF EXISTS(
          SELECT 1
            FROM dbo.LOTxLOCxID WITH(NOLOCK)
           WHERE StorerKey = @c_StorerKey
             AND Loc = @c_ToLoc
             AND QtyAllocated > 0)
       BEGIN
         IF @b_debug = 1
         BEGIN
            SELECT @c_Reason = 'FAILED PutCode: ispPutCode_MICID01, Not allocate in the ToLoc,ToLoc = ' + @c_ToLoc
            EXEC nspPTD 'nspRDTPASTD', @n_pTraceHeadKey, @c_PutawayStrategyKey, @c_PutawayStrategyLineNumber, @n_PtraceDetailKey, @c_ToLoc, @c_Reason
         END
         SET @b_RestrictionsPassed = 0 --False
         RETURN
       END

      IF EXISTS(
              SELECT 1
               FROM dbo.LOTxLOCxID INV WITH(NOLOCK)
               INNER JOIN ID I WITH(NOLOCK) ON INV.Id = I.Id
               WHERE INV.StorerKey = @c_StorerKey
                AND INV.Loc = @c_ToLoc
                AND EXISTS (
                        SELECT 1
                         FROM ID D WITH(NOLOCK)
                        WHERE D.Id = @c_ID
                          AND D.Status <> I.Status
                        )
               )
        BEGIN
          IF @b_debug = 1
          BEGIN
            SELECT @c_Reason = 'FAILED PutCode: ispPutCode_MICID01, inventory Status is not the same as ID,ToLoc = ' + @c_ToLoc
            EXEC nspPTD 'nspRDTPASTD', @n_pTraceHeadKey, @c_PutawayStrategyKey, @c_PutawayStrategyLineNumber, @n_PtraceDetailKey, @c_ToLoc, @c_Reason
          END
          SET @b_RestrictionsPassed = 0 --False
          RETURN         
      END

   END
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

GRANT EXECUTE ON [dbo].[ispPutCode_MICID01] TO [NSQL]
GO