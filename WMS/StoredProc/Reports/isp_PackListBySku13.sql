IF EXISTS (SELECT Name FROM dbo.sysobjects WHERE Name = 'isp_PackListBySku13' AND Type = 'P')
   DROP PROC isp_PackListBySku13
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO 
/************************************************************************/
/* Stored Proc: isp_PackListBySku13                                     */
/* Creation Date: 10-DEC-2018                                           */
/* Copyright: LF Logistics                                              */
/* Written by: WLCHOOI                                                  */
/*                                                                      */
/* Purpose: WMS-7199 SG - Triple - ECOM Shipping Invoice                */
/*        :                                                             */
/* Called By: r_dw_packing_list_by_Sku13                                */
/*          :                                                           */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */
/* 21-Feb-2019 WLCHOOI  1.0   WMS-7199 - Change the logic of calculating*/
/*                                       QTY and ExtendedPrice          */
/************************************************************************/
CREATE PROC isp_PackListBySku13
			 -- @c_Storerkey         NVARCHAR(20),
			  @c_PickSlipNo        NVARCHAR(10)--,
			--  @c_StartCartonNo     NVARCHAR(10) = '1',
			--  @c_EndCartonNo       NVARCHAR(10) = '1'
AS
BEGIN
	SET NOCOUNT ON
	SET ANSI_NULLS OFF
	SET QUOTED_IDENTIFIER OFF
	SET CONCAT_NULL_YIELDS_NULL OFF

	--SET @n_StartTCnt = @@TRANCOUNT
	--SET @n_Continue = 1

	--WHILE @@TRANCOUNT > 0
	--BEGIN
	--	COMMIT TRAN
	--END

	--IF ISNULL(@c_StartCartonno,'') = ''
	--BEGIN
	--  SET @c_StartCartonno = '1'
	--END


	--IF ISNULL(@c_EndCartonno,'') = ''
	--BEGIN
	--  SET @c_EndCartonno = '99999'
	--END
   DECLARE @c_descr      NVARCHAR(90),
           @c_sku        NVARCHAR(90),
           @c_extprice   FLOAT,
           @c_b_contact1 NVARCHAR(90),
           @c_b_address1 NVARCHAR(90),
           @c_b_address2 NVARCHAR(90),
           @c_b_address3 NVARCHAR(90),
           @c_b_address4 NVARCHAR(90),
           @c_c_contact1 NVARCHAR(90),
           @c_c_address1 NVARCHAR(90),
           @c_c_address2 NVARCHAR(90),
           @c_c_address3 NVARCHAR(90),
           @c_c_address4 NVARCHAR(90),
           @c_c_city     NVARCHAR(90),
           @c_userdef05  NVARCHAR(30),
           @c_qty        INT


   SET @c_descr = ''
   SET @c_sku = ''
   SET @c_extprice = 0.00

	CREATE TABLE #PLISTBYSKU13(
	B_Contact1			NVARCHAR(60)
	,B_Address1			NVARCHAR(90)
	,B_Address2			NVARCHAR(90)
	,B_Address3			NVARCHAR(90)
	,B_Address4			NVARCHAR(90)
	,C_Contact1			NVARCHAR(60)
	,C_Address1			NVARCHAR(90)
	,C_Address2			NVARCHAR(90)
	,C_Address3			NVARCHAR(90)
	,C_Address4			NVARCHAR(90)
	,C_City				NVARCHAR(90)
	,Descr				NVARCHAR(90)
	,Qty				   INT
	,ExtPrice			FLOAT
	,UserDefine05		NVARCHAR(30)
	,PickSlipNo			NVARCHAR(10)
   ,SKU              NVARCHAR(50))

   --WL01 START
   CREATE TABLE #PLISTBYSKU13_Final(
	B_Contact1			NVARCHAR(60)
	,B_Address1			NVARCHAR(90)
	,B_Address2			NVARCHAR(90)
	,B_Address3			NVARCHAR(90)
	,B_Address4			NVARCHAR(90)
	,C_Contact1			NVARCHAR(60)
	,C_Address1			NVARCHAR(90)
	,C_Address2			NVARCHAR(90)
	,C_Address3			NVARCHAR(90)
	,C_Address4			NVARCHAR(90)
	,C_City				NVARCHAR(90)
	,Descr				NVARCHAR(90)
	,Qty				   INT
	,ExtPrice			FLOAT
	,UserDefine05		NVARCHAR(30))
   

	INSERT INTO #PLISTBYSKU13(B_Contact1,B_Address1,B_Address2,B_Address3,B_Address4,C_Contact1,C_Address1,C_Address2,C_Address3,C_Address4
								,C_City, Descr, Qty,ExtPrice,UserDefine05,PickSlipNo,SKU)
	SELECT ISNULL(O.B_contact1,'')
			,ISNULL(O.B_Address1,'')
			,ISNULL(O.B_Address2,'')
			,ISNULL(O.B_Address3,'')
			,ISNULL(O.B_Address4,'')
			,ISNULL(O.C_contact1,'')
			,ISNULL(O.C_Address1,'')
			,ISNULL(O.C_Address2,'')
			,ISNULL(O.C_Address3,'')
			,ISNULL(O.C_Address4,'')
			,ISNULL(O.C_City,'')
			,LTRIM(RTRIM(S.DESCR))
			,SUM(PID.QTY)
			,OD.ExtendedPrice--*PID.QTY
			,OD.USERDEFINE05
			,PH.PickSlipNo
         ,S.SKU
	FROM ORDERS     O  WITH (NOLOCK)
	JOIN ORDERDETAIL OD WITH (NOLOCK) ON OD.OrderKey=O.OrderKey
	JOIN PACKHEADER PH WITH (NOLOCK) ON (O.Orderkey = PH.Orderkey AND O.Storerkey = PH.Storerkey)
	JOIN PACKDETAIL PD WITH (NOLOCK) ON (PD.PickSlipNo = PH.PickSlipNo and PD.SKU = OD.SKU)
	JOIN SKU         S WITH (NOLOCK) ON (S.Storerkey = PD.Storerkey)
												AND(S.Sku = PD.Sku)
    JOIN PICKDETAIL PID WITH (NOLOCK) ON (OD.Orderkey    = PID.Orderkey      
                                     AND PID.OrderLineNumber = OD.OrderLineNumber)  
	WHERE  PH.PickSlipNo = @c_PickSlipNo AND O.OrderGroup = 'ECOM'
	--AND PD.CartonNo >= CAST(@c_StartCartonno as INT) 
	--AND PD.CartonNo <= CAST(@c_EndCartonno as INT) 
	GROUP BY  ISNULL(O.B_contact1,'')
			,ISNULL(O.B_Address1,'')
			,ISNULL(O.B_Address2,'')
			,ISNULL(O.B_Address3,'')
			,ISNULL(O.B_Address4,'')
			,ISNULL(O.C_contact1,'')
			,ISNULL(O.C_Address1,'')
			,ISNULL(O.C_Address2,'')
			,ISNULL(O.C_Address3,'')
			,ISNULL(O.C_Address4,'')
			,ISNULL(O.C_City,'')
			,LTRIM(RTRIM(S.DESCR))
			--,PID.QTY
			,OD.ExtendedPrice
			,OD.USERDEFINE05
			,PH.PickSlipNo
         ,S.SKU

--select * from #PLISTBYSKU13
   DECLARE CUR_QTY CURSOR LOCAL FAST_FORWARD READ_ONLY FOR  
   SELECT DISTINCT B_Contact1
	,B_Address1
	,B_Address2
	,B_Address3
	,B_Address4
	,C_Contact1
	,C_Address1
	,C_Address2
	,C_Address3
	,C_Address4
	,C_City
	,Descr
	,Qty
	,ExtPrice
	,UserDefine05 
	FROM #PLISTBYSKU13

   OPEN CUR_QTY

   FETCH NEXT FROM CUR_QTY INTO @c_B_Contact1,@c_B_Address1,@c_B_Address2,@c_B_Address3,@c_B_Address4,@c_C_Contact1,@c_C_Address1,
                                 @c_C_Address2,@c_C_Address3,@c_C_Address4,@c_C_City, @c_Descr,@c_qty,@c_extprice,@c_userdef05
   WHILE @@FETCH_STATUS <> -1
   BEGIN
   SELECT DISTINCT @c_descr    = DESCR,
                   @c_qty      = SUM(QTY),
                   @c_extprice = SUM(EXTPRICE)
   FROM #PLISTBYSKU13 WHERE DESCR = @c_descr
   GROUP BY DESCR
   --SELECT @c_descr,@C_QTY,@C_EXTPRICE
   INSERT INTO #PLISTBYSKU13_Final(B_Contact1,B_Address1,B_Address2,B_Address3,B_Address4,C_Contact1,C_Address1,C_Address2,C_Address3,C_Address4
								           ,C_City, Descr, Qty,ExtPrice,UserDefine05)
   VALUES(@c_B_Contact1,@c_B_Address1,@c_B_Address2,@c_B_Address3,@c_B_Address4,@c_C_Contact1,@c_C_Address1,
                                 @c_C_Address2,@c_C_Address3,@c_C_Address4,@c_C_City, @c_Descr,@c_qty,@c_extprice,@c_userdef05)

   FETCH NEXT FROM CUR_QTY INTO @c_B_Contact1,@c_B_Address1,@c_B_Address2,@c_B_Address3,@c_B_Address4,@c_C_Contact1,@c_C_Address1,
                                 @c_C_Address2,@c_C_Address3,@c_C_Address4,@c_C_City, @c_Descr,@c_qty,@c_extprice,@c_userdef05
   END
   CLOSE CUR_QTY
   DEALLOCATE CUR_QTY
   --WL01 END

	SELECT B_Contact1
	,B_Address1
	,B_Address2
	,B_Address3
	,B_Address4
	,C_Contact1
	,C_Address1
	,C_Address2
	,C_Address3
	,C_Address4
	,C_City
	,Descr
	,SUM(Qty)
	,ExtPrice
	,UserDefine05 
	from #PLISTBYSKU13_Final
	GROUP BY B_Contact1
	,B_Address1
	,B_Address2
	,B_Address3
	,B_Address4
	,C_Contact1
	,C_Address1
	,C_Address2
	,C_Address3
	,C_Address4
	,C_City
	,Descr
   ,ExtPrice
	,UserDefine05


END -- procedure

GO
GRANT EXECUTE ON isp_PackListBySku13 TO NSQL
GO   

