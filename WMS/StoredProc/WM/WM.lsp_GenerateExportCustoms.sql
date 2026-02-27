SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Store Procedure: lsp_GenerateExportCustoms                           */
/* Creation Date: 25-02-2026                                            */
/* Copyright: MAERSK                                                    */
/* Written by: PREETHAM NV                                              */
/*                                                                      */
/* Purpose: UWP-49058 => HP CUSTOMS EXPORT DECLARATION                  */
/*                                                                      */
/* Called By: IN SCE O/B WAVE CONTROL                                   */
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 8.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver.  Purposes                                  */
/*25-02-2026   VNI056   1.0   UWP-49058 => CREATE PROC                  */
/************************************************************************/
CREATE OR ALTER PROC [WM].[lsp_GenerateExportCustoms]
      @c_WaveKey              NVARCHAR(10) = ''
   ,  @b_Success              INT = 1           OUTPUT
   ,  @n_err                  INT = 0           OUTPUT
   ,  @c_ErrMsg               NVARCHAR(255)     OUTPUT
   ,  @c_UserName             NVARCHAR(128)= ''

AS
BEGIN
    SET NOCOUNT ON
    SET ANSI_NULLS OFF
    SET QUOTED_IDENTIFIER OFF
    SET CONCAT_NULL_YIELDS_NULL OFF

    DECLARE  @n_StartTCnt      INT = @@TRANCOUNT
          ,  @n_Continue       INT = 1
          ,  @n_OrderCnt       INT = 0
		  ,  @c_Storerkey      NVARCHAR(15)
		  ,  @c_MBolkey        NVARCHAR(10)
		  ,  @n_WarningNo      INT = 0

    SET @b_Success = 1
    SET @n_Err     = 0

    BEGIN TRAN
    SET @n_Err = 0

    -- Start enhanced session management
	DECLARE @b_ExecuteAs   BIT = 0
	IF SUSER_SNAME() <> @c_UserName AND @c_UserName <> ''
    BEGIN

        EXEC [WM].[lsp_SetUser]
		       @c_UserName   = @c_UserName  OUTPUT
		    ,  @n_Err        = @n_Err       OUTPUT
            ,  @c_ErrMsg     = @c_ErrMsg    OUTPUT
            ,  @b_ExecuteAs  = @b_ExecuteAs OUTPUT

		IF @n_Err <> 0
        BEGIN
            GOTO EXIT_SP
        END
		IF @b_ExecuteAs = 1
		    EXECUTE AS LOGIN = @c_UserName

    END
    -- End enhanced session management


    BEGIN TRY
        SELECT @n_OrderCnt = COUNT(*)
        FROM ORDERS WITH (NOLOCK)
        JOIN WAVEDETAIL WITH (NOLOCK) ON WAVEDETAIL.OrderKey = ORDERS.OrderKey
        WHERE WAVEDETAIL.WaveKey = @c_WaveKey

        SELECT @c_Storerkey = ORDERS.Storerkey
        FROM ORDERS WITH (NOLOCK)
        JOIN WAVEDETAIL WITH (NOLOCK) ON WAVEDETAIL.OrderKey = ORDERS.OrderKey
        WHERE WAVEDETAIL.WaveKey = @c_WaveKey

      --VALIDATIONS FOR EXPORT DECLARATION (START)

        IF  @c_WaveKey = ''
        BEGIN
			SET @n_continue = 3
			SET @n_err = 555809
			SET @c_errmsg = 'NSQL'+ CONVERT(Char(6),@n_err)
							+'Empty WaveKey Found (lsp_GenerateExportCustoms)'
			GOTO EXIT_SP
        END

		IF @n_OrderCnt = 0
        BEGIN
			SET @n_continue = 3
			SET @n_err = 555810
            SET @c_errmsg = 'NSQL'+ CONVERT(Char(6),@n_err)
                           + ': No Orders Found (lsp_GenerateExportCustoms)'
			GOTO EXIT_SP
        END

		IF EXISTS(
			SELECT 1 FROM ORDERS WITH (NOLOCK)
			JOIN WAVEDETAIL WITH (NOLOCK) ON WAVEDETAIL.OrderKey = ORDERS.OrderKey
			WHERE (ORDERS.Status <> '5') AND WAVEDETAIL.WaveKey = @c_WaveKey
		)
        BEGIN
			SET @n_continue = 3
			SET @n_err = 555811
			SET @c_errmsg = 'NSQL'+ CONVERT(Char(6),@n_err)
							+'Some Orders are not yet Picked (lsp_GenerateExportCustoms)'
			GOTO EXIT_SP
        END

		IF EXISTS(
			SELECT 1 FROM ORDERS WITH (NOLOCK)
			JOIN WAVEDETAIL WITH (NOLOCK) ON WAVEDETAIL.OrderKey = ORDERS.OrderKey
			WHERE WAVEDETAIL.WaveKey = @c_WaveKey AND ISNULL(ORDERS.MBOLKey,'') = ''
		)
        BEGIN
			SET @n_continue = 3
			SET @n_err = 555812
			SET @c_errmsg = 'NSQL'+ CONVERT(Char(6),@n_err)
							+'Some Orders do not have a Ship Reference (lsp_GenerateExportCustoms)'
			GOTO EXIT_SP
        END

        SELECT @c_MBolkey = ORDERS.MBOLKey FROM ORDERS WITH (NOLOCK)
        JOIN WAVEDETAIL WITH (NOLOCK) ON WAVEDETAIL.OrderKey = ORDERS.OrderKey
        WHERE WAVEDETAIL.WaveKey = @c_WaveKey
        GROUP BY ORDERS.MBOLKey

        IF @@ROWCOUNT <> 1
        BEGIN
			SET @n_continue = 3
			SET @n_err = 555813
			SET @c_errmsg = 'NSQL'+ CONVERT(Char(6),@n_err)
			               +'Too Many Ship Reference Units exist (lsp_GenerateExportCustoms)'
			GOTO EXIT_SP
        END

		IF NOT EXISTS(
			SELECT 1 FROM ORDERS WITH (NOLOCK)
			JOIN WAVEDETAIL WITH (NOLOCK) ON WAVEDETAIL.OrderKey = ORDERS.OrderKey
			WHERE WAVEDETAIL.WaveKey = @c_WaveKey
			AND ORDERS.MBOLkey = @c_MBolkey
			AND ISNULL(ORDERS.C_Country,'') IN ('GBR','NOR','GB','NO')
		)
        BEGIN
			SET @n_continue = 3
			SET @n_err = 555814
			SET @c_errmsg = 'No re-export declaration as the Ship Reference '+@c_MBolkey+ ' is not destined for outside EU destinations.'
			GOTO EXIT_SP
        END

		IF EXISTS
		(
			SELECT 1 FROM TRANSMITLOG2 WITH (NOLOCK)
			WHERE Key1 = @c_MBolKey AND TableName = 'XDCBWEXPDL' AND Key3 = @c_Storerkey
		)
        BEGIN
			SET @n_continue = 3
			SET @n_err = 555815
			SET @c_errmsg = 'Ship Reference '+@c_MBolkey+ ' is already submitted for Customs'
			GOTO EXIT_SP
        END

		--VALIDATIONS FOR EXPORT DECLARATION (END)

		--MAIN PROCESSING (START)

        EXEC ispGenTransmitLog2 'XDCBWEXPDL', @c_MBolKey,
								'', @c_StorerKey, ''
                                , @b_success OUTPUT
                                , @n_Err     OUTPUT
                                , @c_ErrMsg  OUTPUT
        IF @b_success <> 1
        BEGIN
            SET @n_continue = 3
            SET @n_Err = 68001
            SET @c_ErrMsg = 'NSQL' + CONVERT(CHAR(5),ISNULL(@n_Err,0)) +
                            ': Insert into TRANSMITLOG2 Failed. (lsp_GenerateExportCustoms) ( SQLSvr MESSAGE = ' +
                            ISNULL(LTRIM(RTRIM(@c_ErrMsg)),'') + ' ) '
            GOTO EXIT_SP
        END

        UPDATE ORDERS
        SET ORDERS.SOStatus = '51'
        FROM ORDERS WITH (NOLOCK)
		JOIN WAVEDETAIL WITH (NOLOCK) ON WAVEDETAIL.OrderKey = ORDERS.OrderKey
        WHERE WAVEDETAIL.WaveKey = @c_WaveKey

--MAIN PROCESSING (END)
    END TRY

    BEGIN CATCH
        SET @n_Continue = 3
        SET @c_ErrMsg = ERROR_MESSAGE()
        GOTO EXIT_SP
    END CATCH

EXIT_SP:

	IF (XACT_STATE()) = -1
    BEGIN
		SET @n_Continue = 3
		ROLLBACK TRAN
    END

	IF @n_Continue=3
    BEGIN
		SET @b_Success = 0
		IF @n_StartTCnt = 0 AND @@TRANCOUNT > @n_StartTCnt
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

		SET @n_WarningNo = 0
		EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'lsp_GenerateExportCustoms'
    END
    ELSE
    BEGIN
		SET @b_Success = 1
		WHILE @@TRANCOUNT > @n_StartTCnt
        BEGIN
            COMMIT TRAN
        END
    END

	IF @@TRANCOUNT < @n_StartTCnt
    BEGIN
        BEGIN TRAN
    END

    IF @b_ExecuteAs = 1 REVERT
    EXEC [WM].[lsp_ResetUser]
END
GO
GRANT EXECUTE ON  [WM].[lsp_GenerateExportCustoms] TO [NSQL]
GO