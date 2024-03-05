SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Stored Proc: isp_RPT_ASN_TALLYSHT_003                                */
/* Platform: V2                                                         */
/* Creation Date: 29-Feb-2024                                           */
/* Copyright: Maersk                                                    */
/* Written by: WLChooi                                                  */
/*                                                                      */
/* Purpose: WMS-24973 - Migrate tallysheet r_receipt_tallysheet24 to    */
/*          Logireport                                                  */
/*                                                                      */
/* Called By: RPT_ASN_TALLYSHT_003                                      */
/*                                                                      */
/* Github Version: 1.0                                                  */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */
/* 29-Feb-2024 WLChooi  1.0   DevOps Combine Script                     */
/************************************************************************/

CREATE OR ALTER PROC [dbo].[isp_RPT_ASN_TALLYSHT_003]
(
   @c_Receiptkey NVARCHAR(10)
 , @c_Username   NVARCHAR(250) = ''
)
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_Continue INT = 1

   SELECT DISTINCT
          RECEIPT.ReceiptKey
        , ISNULL(RECEIPTDETAIL.POKey, '') AS POKey
        , ISNULL(@c_Username, '') AS Username
   FROM RECEIPT WITH (NOLOCK)
   JOIN RECEIPTDETAIL WITH (NOLOCK) ON (RECEIPT.ReceiptKey = RECEIPTDETAIL.ReceiptKey)
   WHERE RECEIPT.ReceiptKey = @c_Receiptkey
END
GO
GRANT EXECUTE ON [dbo].[isp_RPT_ASN_TALLYSHT_003] TO [NSQL]
GO
GRANT EXECUTE ON [dbo].[isp_RPT_ASN_TALLYSHT_003] TO [LogiReportRoleWM]
GO