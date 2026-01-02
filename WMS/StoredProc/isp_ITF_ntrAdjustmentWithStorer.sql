IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[isp_ITF_ntrAdjustmentWithStorer]') AND type in (N'P', N'PC'))
DROP PROCEDURE
[dbo].[isp_ITF_ntrAdjustmentWithStorer]
GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO


/************************************************************************/
/* Store Procedure:  isp_ITF_ntrAdjustmentWithStorer                    */
/* Creation Date: 31-Dec-2025                                           */
/* Written by: Preetham NV                                              */
/*                                                                      */
/* Purpose:  Handling trigger points for Adjustment's module.           */
/*           Including Adjustment Header trigger points for Add         */
/*                                                                      */
/* Output Parameters:  @b_Success                                       */
/*                     @n_Err                                           */
/*                     @c_ErrMsg                                        */
/*                                                                      */
/* Return Status:  @b_Success = 0 or 1                                  */
/*                                                                      */
/* Usage:  Trigger Points verification & add on                         */
/*         configuration table - ITFTriggerConfig.                      */
/*                                                                      */
/* Called By:  Trigger/Store Procedure.                                 */
/*             -ntrAdjustmentHeaderAdd                                  */
/*             -ntrAdjustmentDetailAdd                                  */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 1.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/* Date            Author    Ver.      Purposes                         */
/* 31-12-2025      VNI056    1.0       FCR-9732                         */
/************************************************************************/

CREATE OR ALTER   PROC [dbo].[isp_ITF_ntrAdjustmentWithStorer]
            @c_TriggerName          nvarchar(120)
          , @c_SourceTable          nvarchar(60)
          , @c_Storerkey            nvarchar(15)
          , @c_AdjustmentKey        nvarchar(10)
          , @b_Success              int           OUTPUT
          , @n_Err                  int           OUTPUT
          , @c_ErrMsg               nvarchar(250) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
    -- Variables Declaration & Initialization - (Start)
   DECLARE @n_continue              int
         , @n_StartTCnt             int

   -- ITFTriggerConfig table
   DECLARE @c_ConfigKey             nvarchar(30)
         , @c_Tablename             nvarchar(30)
         , @c_RecordType            nvarchar(10)
         , @c_RecordStatus          nvarchar(10)
         , @c_sValue                nvarchar(10)
         , @c_TargetTable           nvarchar(60)
         , @c_StoredProc            nvarchar(200)
         , @c_ConfigFacility        nvarchar(5)
         , @c_UpdatedColumns        NVARCHAR(250)

   SET @n_StartTCnt = @@TRANCOUNT
   SET @n_continue = 1
   SET @b_success = 0
   SET @n_Err = 0
   SET @c_ErrMsg = ''
   --Variables Declaration & Initialization - (End)

   /* Std - Verify Parameter variables, no values found, return to core program (Start) */
   IF (ISNULL(RTRIM(@c_TriggerName),'') = '') OR
      (ISNULL(RTRIM(@c_SourceTable),'') = '') OR
      (ISNULL(RTRIM(@c_AdjustmentKey),'') = '')
   BEGIN
      RETURN
   END

   IF (ISNULL(RTRIM(@c_TriggerName),'') <> 'ntrAdjustmentHeaderAdd' )
   BEGIN
     IF (ISNULL(RTRIM(@c_TriggerName),'') <> 'ntrAdjustmentDetailAdd' )
     BEGIN
        RETURN
     END
   END

   IF (ISNULL(RTRIM(@c_SourceTable),'') <> 'ADJUSTMENT')
   BEGIN
     IF (ISNULL(RTRIM(@c_SourceTable),'') <> 'ADJUSTMENTDETAIL' )
     BEGIN
       RETURN
     END
   END
   /* Std - Verify Parameter variables, no values found, return to core program (End) */
   /* Std - Extract values for required variables (Start) */
   IF @n_continue = 1 OR @n_continue = 2
   BEGIN
      IF (UPPER(RTRIM(@c_SourceTable)) = 'ADJUSTMENT')
      BEGIN
         SELECT @c_StorerKey = RTRIM(A.StorerKey)
         FROM dbo.Adjustment AS A WITH (NOLOCK)
         WHERE A.AdjustmentKey = @c_AdjustmentKey;
      END
      ELSE
      BEGIN
         SELECT @c_StorerKey = RTRIM(D.StorerKey)
         FROM dbo.AdjustmentDetail AS D WITH (NOLOCK)
         WHERE D.AdjustmentKey = @c_AdjustmentKey;
      END
   END
   /* Std - Extract values for required variables (End) */

   /* Main Program (Start) */
   IF @n_continue = 1 OR @n_continue = 2
   BEGIN
      IF EXISTS ( SELECT 1 FROM ITFTriggerConfig WITH (NOLOCK)
                  WHERE StorerKey   = @c_StorerKey
                  AND   SourceTable = @c_SourceTable
                  AND   sValue      = '1' )
      BEGIN
          DECLARE Cur_ITFTriggerConfig CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
          SELECT DISTINCT  ConfigKey
                          , Facility
                          , Tablename
                          , RecordType
                          , RecordStatus
                          , sValue
                          , TargetTable
                          , StoredProc
                          , UpdatedColumns
          FROM  ITFTriggerConfig WITH (NOLOCK)
          WHERE StorerKey   = @c_StorerKey
          AND   SourceTable = @c_SourceTable
          AND   sValue      = '1'

          OPEN Cur_ITFTriggerConfig
          FETCH NEXT FROM Cur_ITFTriggerConfig INTO @c_ConfigKey, @c_ConfigFacility, @c_Tablename, @c_RecordType, @c_RecordStatus
              , @c_sValue, @c_TargetTable, @c_StoredProc, @c_UpdatedColumns

          WHILE @@FETCH_STATUS <> -1
          BEGIN
            SET @b_Success = 0
            --FOR CUSTOM SP'S WITH ADJ KEY
            IF ISNULL(RTRIM(@c_StoredProc),'') <> ''
            BEGIN
               SET @b_Success = 0
               EXEC sys.sp_executesql @c_StoredProc, N'@c_AdjustmentKey NVARCHAR(10), @b_Success INT OUTPUT, @c_ErrNo INT OUTPUT, @c_ErrMsg NVARCHAR(215) OUTPUT',
                           @c_AdjustmentKey,
                           @b_Success OUTPUT,
                           @n_Err     OUTPUT,
                           @c_ErrMsg  OUTPUT
            END
            ELSE
            BEGIN
                SET @b_Success = 1
            END
            IF @b_Success = 1
            BEGIN
               IF @c_TargetTable = 'TRANSMITLOG2'
               BEGIN
                  EXEC ispGenTransmitLog2 @c_Tablename, @c_AdjustmentKey, @c_StorerKey, '', ''
                              , @b_success OUTPUT
                              , @n_Err OUTPUT
                              , @c_ErrMsg OUTPUT

                  --Below Lines are to set TransmitLog2.TransmitFlag to '0' during individual detail item update to re-trigger data if transmitFlag Not in ('0', '1')
                  DECLARE @tranflag  VARCHAR(1) = (SELECT transmitFlag FROM [DBO].[TRANSMITLOG2] WHERE tablename = @c_Tablename AND key1 = @c_AdjustmentKey AND key2 = @c_Storerkey)
                  IF @tranflag >= '5'
                  BEGIN
                    SET @tranflag = '0'
                  END
                  UPDATE [DBO].[TRANSMITLOG2] SET transmitflag = @tranflag WHERE tablename = @c_Tablename AND key1 = @c_AdjustmentKey AND key2 = @c_Storerkey

                  IF @b_success <> 1
                  BEGIN
                     SET @n_continue = 3
                     SET @n_Err = 68001
                     SET @c_ErrMsg = 'NSQL' + CONVERT(CHAR(5),ISNULL(@n_Err,0)) +
                         ': Insert into TRANSMITLOG2 Failed. (isp_ITF_ntrAdjustmentWithStorer) ( SQLSvr MESSAGE = ' +
                         ISNULL(LTRIM(RTRIM(@c_ErrMsg)),'') + ' ) '
                     GOTO QUIT
                  END
               END
            END
            GET_NEXT_Record:
            FETCH NEXT FROM Cur_ITFTriggerConfig INTO @c_ConfigKey, @c_ConfigFacility, @c_Tablename, @c_RecordType, @c_RecordStatus
                                                            , @c_sValue, @c_TargetTable, @c_StoredProc, @c_UpdatedColumns
          END
          CLOSE Cur_ITFTriggerConfig
          DEALLOCATE Cur_ITFTriggerConfig
      END
   END

/* Std - Error Handling (Start) */
QUIT:
    WHILE @@TRANCOUNT < @n_StartTCnt
    BEGIN TRAN
       IF @n_continue=3  -- Error Occured - Process And Return
       BEGIN
           SELECT @b_success = 0
           IF @@TRANCOUNT > @n_StartTCnt
           BEGIN
              ROLLBACK TRAN
           END
           ELSE
           BEGIN
              WHILE @@TRANCOUNT > @n_StartTCnt
              BEGIN
                 COMMIT TRAN
              END
           END
           EXECUTE dbo.nsp_logerror @n_Err, @c_ErrMsg, 'isp_ITF_ntrAdjustmentWithStorer'
           RAISERROR (@c_ErrMsg, 16, 1) WITH SETERROR
           RETURN
       END
       ELSE
       BEGIN
          SELECT @b_success = 1
          WHILE @@TRANCOUNT > @n_StartTCnt
          BEGIN
             COMMIT TRAN
          END
          RETURN
       END
/* Std - Error Handling (End) */
END -- procedure
GO

GRANT EXECUTE ON isp_ITF_ntrAdjustmentWithStorer TO NSQL
GO
