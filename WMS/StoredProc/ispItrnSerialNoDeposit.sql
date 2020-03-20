IF EXISTS (SELECT * FROM dbo.sysobjects WHERE ID = OBJECT_ID(N'[dbo].[ispITrnSerialNoDeposit]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
   DROP PROCEDURE [dbo].[ispITrnSerialNoDeposit]
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/******************************************************************************/
/* Store procedure: ispITrnSerialNoDeposit                                    */
/* Copyright      : LF Logistics                                              */
/*                                                                            */
/* Purpose: Insert into ITrnSerialNo                                          */
/*                                                                            */
/* Date       Rev  Author      Purposes                                       */
/* 2017-05-15 1.0  Ung         WMS-1817 Add serial no                         */
/******************************************************************************/

CREATE PROCEDURE dbo.ispITrnSerialNoDeposit (
     @c_TranType     NVARCHAR(10)
   , @c_StorerKey    NVARCHAR(15)
   , @c_SKU          NVARCHAR(20)
   , @c_SerialNo     NVARCHAR(30)
   , @n_QTY          INT
   , @c_SourceKey    NVARCHAR(20)
   , @c_SourceType   NVARCHAR(30)
   , @b_Success      INT            OUTPUT  
   , @n_Err          INT            OUTPUT  
   , @c_ErrMsg       NVARCHAR(250)  OUTPUT
) AS
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @c_ITrnKey NVARCHAR( 10)
   
   SET @b_Success = 0 -- False

   -- Get ITrn info
   SELECT @c_ITrnKey = ITrnKey
   FROM ITrn WITH (NOLOCK)
   WHERE TranType = 'DP'
      AND StorerKey = @c_StorerKey
      AND SKU = @c_SKU
      AND SourceKey = @c_SourceKey
      
   IF @@ROWCOUNT <> 1
   BEGIN
      SELECT @n_err = 109251
      SELECT @c_errmsg = 'NSQL' + CAST( @n_err AS NVARCHAR(6)) + ' ITrn deposit record not found (ispITrnSerialNoDeposit)'
      GOTO Quit
   END
   
   INSERT INTO ITrnSerialNo (ITrnKey, TranType, StorerKey, SKU, SerialNo, QTY, SourceKey, SourceType)
   VALUES (@c_ITrnKey, @c_TranType, @c_StorerKey, @c_SKU, @c_SerialNo, @n_QTY, @c_SourceKey, @c_SourceType)
   IF @@ERROR <> 0
   BEGIN
      SELECT @n_err = 109252
      SELECT @c_errmsg = 'NSQL' + CAST( @n_err AS NVARCHAR(6)) + ' Insert ITrnSerialNo fail (ispITrnSerialNoDeposit)'
      GOTO Quit
   END
   
   SET @b_Success = 1 -- True
   
Quit:

GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
GRANT EXEC ON RDT.rdt_Receive TO NSQL
GO
