
/*************************************************************************************************************/
/* Stored Procedure: isp_RPT_Scanned_by_ASN_NLRT_001                                                         */
/* Creation Date: 12/02/2025                                                                                 */
/* Copyright: Maersk CE EUR                                                                                  */
/* Written by: AGA399                                                                                        */
/*                                                                                                           */
/* Purpose: Report for shows ASN captured serial No copy of isp_RPT_Scanned_by_ASN_001                       */
/*                                                                                                           */
/* Called By: RPT_Scanned_by_ASN_NLRT_001 -> Scanned by ASN                                                  */
/*                                                                                                           */
/* GitHub Version: 1.0                                                                                       */
/*                                                                                                           */
/* Version: 1.0                                                                                              */
/*                                                                                                           */
/* Data Modifications:                                                                                       */
/*                                                                                                           */
/* Updates:                                                                                                  */
/* Date         Author  Ver   Purposes                                                                       */
/* 06/02/2025   AGA399  1.0   Adapt report from RedBull MWMS V1 to NLRT customers in MWMS V2                 */
/* 12/02/2025   AGA399  1.1   Change RECEIPT Join as Rotterdam can have lines from multiple PO inside ASN    */
/* 03/04/2025   AGA399  1.2   Add new fields and delete some old version fields                              */
/*                                                                                                           */
/*************************************************************************************************************/

CREATE OR ALTER      PROC [BI].[isp_RPT_Scanned_by_ASN_NLRT_001]
		  @StorerKey varchar (30) 
		, @ReceiptKey varchar (30)	= NULL


AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF



select 
	--REC.externreceiptkey
	REC.externreceiptkey --AGA040325
,	REC.ReceiptKey
,	REC.UserDefine02 --Destination Number AGA040325
,	REC.UserDefine05 --Contianer Number AGA040325
--,	RSO.ReceiptLineNumber --AGA040325
,	REC.ToId --Movable Unit AGA040325
,	SRN.StorerKey
,	SRN.SKU
,	SRN.SerialNo
--,	RSO.QTYExpected --AGA040325
,	SRN.QTY
--,	RSO.AddWho --AGA040325
,	REC.DateReceived --AGA040325
--,	RSO.AddDate --AGA040325
--,	RSO.EditWho --AGA040325
--,	RSO.EditDate --AGA040325													
from serialno SRN with (nolock)
inner join receiptdetail REC with (nolock) on  SRN.StorerKey = REC.StorerKey and SRN.ID = REC.ToID
where SRN.storerkey = @StorerKey
and REC.ReceiptKey like case when ISNULL(@ReceiptKey, '') = '' then '%' else @ReceiptKey end 
order by 
	REC.ExternReceiptKey asc
,	SRN.SerialNo asc


END
