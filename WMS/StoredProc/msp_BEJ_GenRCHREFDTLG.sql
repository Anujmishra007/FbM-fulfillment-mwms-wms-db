SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Stored Proc: msp_BEJ_GenRCHREFDTLG                                   */
/* Creation Date: 2025-07-25                                            */
/* Copyright: Maersk Logistics                                          */
/* Written by: AlexK                                                    */
/*                                                                      */
/* Purpose: FCR-5632 HP - Generate transmitlog3 for RCHPEFDTLG if       */
/*                        receipt.EffectiveDate - 3 = today             */
/*          :                                                           */
/* Called By: Call by SQL Scheduler Job                                 */
/*          :                                                           */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */
/* 2025-07-25  AlexK    1.0   FCR-5632 - initial.                       */
/************************************************************************/

CREATE OR ALTER PROC [dbo].[msp_BEJ_GenRCHREFDTLG]
     @c_StorerKey   NVARCHAR(15)   = ''
   , @c_Facility    NVARCHAR(5)    = ''
   , @c_OtherConfig NVARCHAR(4000) = ''
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
           @n_StartTCnt             INT            = @@TRANCOUNT
         , @n_Continue              INT            = 1
         , @b_Success               INT            = 1
         , @n_Err                   INT            = 0
         , @c_ErrMsg                NVARCHAR(255)  = ''
                                    
         , @c_SQL                   NVARCHAR(MAX)  = ''
         , @c_SQLParms              NVARCHAR(500)  = ''
         , @b_Debug                 INT            = 0
         , @c_ReceiptKey            NVARCHAR(10)   = ''

         , @CUR                     CURSOR
         , @n_BatchNo               INT   = 0


   IF RIGHT(ISNULL(TRIM(@c_OtherConfig),''),2) = '##'
   BEGIN
      SET @b_Debug = 1
      SET @c_OtherConfig = SUBSTRING(@c_OtherConfig, 1, LEN(@c_OtherConfig)-2)
   END

   IF @b_Debug = 1
   BEGIN
      PRINT '@c_OtherConfig: ' + @c_OtherConfig
   END


   BEGIN TRAN

   IF @n_Continue = 1
   BEGIN
      SET @CUR = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT ReceiptKey
      FROM dbo.RECEIPT R (NOLOCK)
      WHERE StorerKey = @c_StorerKey
      AND [Status] = '0'
      --AND EffectiveDate >= DATEADD(DAY, 3, CONVERT(DATE, GETDATE()))
      --AND EffectiveDate < DATEADD(DAY, 4, CONVERT(DATE, GETDATE()))
      AND NOT EXISTS ( SELECT 1 FROM dbo.TransmitLog3 TL3 WITH (NOLOCK)
         WHERE TL3.TableName = 'RCHPEFDTLG'
         AND TL3.Key1 = R.ReceiptKey
         AND TL3.Key3 = R.StorerKey )
      AND (
        CASE 
            -- Monday (1) or Tuesday (2): EffectiveDate must be 3 days ahead
            WHEN DATEPART(WEEKDAY, R.EffectiveDate) IN (1, 2) 
                 THEN CASE 
                          WHEN R.EffectiveDate >= DATEADD(DAY, 3, CAST(GETDATE() AS DATE))
                           AND R.EffectiveDate <  DATEADD(DAY, 4, CAST(GETDATE() AS DATE)) 
                          THEN 1
                          ELSE 0
                      END
            -- Wednesday (3) to Saturday (6): EffectiveDate must be 1 day ahead
            WHEN DATEPART(WEEKDAY, R.EffectiveDate) IN (3, 4, 5, 6) 
                 THEN CASE 
                          WHEN R.EffectiveDate >= DATEADD(DAY, 1, CAST(GETDATE() AS DATE))
                           AND R.EffectiveDate <  DATEADD(DAY, 2, CAST(GETDATE() AS DATE)) 
                          THEN 1
                          ELSE 0
                      END
            -- Sunday (7): EffectiveDate must be 2 days ahead
            WHEN DATEPART(WEEKDAY, R.EffectiveDate) = 7
                 THEN CASE 
                          WHEN R.EffectiveDate >= DATEADD(DAY, 2, CAST(GETDATE() AS DATE))
                           AND R.EffectiveDate <  DATEADD(DAY, 3, CAST(GETDATE() AS DATE)) 
                          THEN 1
                          ELSE 0
                      END
        END = 1
      )

      OPEN @CUR
      FETCH NEXT FROM @CUR INTO @c_ReceiptKey
      WHILE @@FETCH_STATUS <> -1 AND @n_Continue = 1
      BEGIN
         EXEC dbo.ispGenTransmitLog3 
            @c_TableName = 'RCHPEFDTLG'
          , @c_Key1 = @c_ReceiptKey
          , @c_Key2 = ''
          , @c_Key3 = @c_StorerKey
          , @c_TransmitBatch = ''
          , @b_Success = @b_Success    OUTPUT    
          , @n_err = @n_Err            OUTPUT    
          , @c_errmsg = @c_ErrMsg      OUTPUT    
                
         IF @b_Success = 0  
         BEGIN
            SET @n_continue = 3
         END

         FETCH NEXT FROM @CUR INTO @c_ReceiptKey
      END
      CLOSE @CUR
      DEALLOCATE @CUR
   END

QUIT_SP:
   IF @n_continue = 3
   BEGIN
      SET @b_Success = 0
      IF @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_StartTCnt
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
      RAISERROR (@c_ErrMsg, 16, 1) WITH SETERROR
   END
   ELSE
   BEGIN
      SET @b_Success = 1
      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
         COMMIT TRAN
      END
   END
END
