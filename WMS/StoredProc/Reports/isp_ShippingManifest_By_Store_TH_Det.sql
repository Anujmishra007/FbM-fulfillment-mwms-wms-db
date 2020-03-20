if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[isp_ShippingManifest_By_Store_TH_Det]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[isp_ShippingManifest_By_Store_TH_Det]
GO

/************************************************************************/
/* Stored Proc : isp_ShippingManifest_By_Store_TH_Det  		            */
/* Creation Date:                                                       */
/* Copyright: IDS                                                       */
/* Written by:                                                          */
/*                                                                      */
/* Purpose: Shipping Manifest By Store (Watson Thailand) 					*/
/*                                                                      */
/* Usage:                                                               */
/*                                                                      */
/* Local Variables:                                                     */
/*                                                                      */
/* Called By: 	datawindow                          				         */
/*                                                                      */
/* PVCS Version: 1.1                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author        Purposes                                  */
/* 2008-Jul-02  Shong			Included Qty Allocated                    */
/* 2008-Auf-10  Shong         Change Storerkey to THWTC                 */
/************************************************************************/
CREATE PROC isp_ShippingManifest_By_Store_TH_Det 
@c_LoadKey1  NVARCHAR(10) = '' ,
@c_LoadKey2  NVARCHAR(10) = '' ,
@c_LoadKey3  NVARCHAR(10) = '' ,
@c_LoadKey4  NVARCHAR(10) = '' ,
@c_LoadKey5  NVARCHAR(10) = '' ,
@c_LoadKey6  NVARCHAR(10) = '' ,
@c_LoadKey7  NVARCHAR(10) = '' ,
@c_LoadKey8  NVARCHAR(10) = '' ,
@c_LoadKey9  NVARCHAR(10) = '' ,
@c_LoadKey10 NVARCHAR(10) = '' ,
@c_Store     NVARCHAR(15) = '' 
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_WARNINGS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF	
   
   DECLARE @c_SQL NVARCHAR(max)

   SELECT @c_SQL = 
      " SELECT " +
      " DISTINCT  " +
      " ORDERS.ConsigneeKey,  " +
      " ORDERS.C_Company,  " +
      " ORDERS.C_Address1,  " +
      " ORDERS.C_Address2,  " +
      " ORDERS.C_Address3,  " +
      " ORDERS.ExternOrderKey,  " +
      " CASE ORDERS.Type WHEN 'ALLOCATION' THEN '(NA)'  " +
      " 			   WHEN 'XDOCK' THEN '(XD)'  " +
      " 				ELSE ''  " +
      " END as Type, " +
      " ORDERS.LoadKey,  " +
      " SKU.Sku,  " +
      " CASE ORDERDETAIL.Userdefine03 WHEN 'ALLOCATION' THEN '(BA)'    " +
      " 						   WHEN 'STOREORDER' THEN '(StO)'    " +
      " 							ELSE ISNULL(ORDERDETAIL.Userdefine03,'')    " +
      " END as Source,   " +
      " SKU.DESCR,  " +
      " SUM ( ORDERDETAIL.OriginalQty ) as QtyOrdered,  " +
      " SUM ( ORDERDETAIL.QtyAllocated + ORDERDETAIL.QtyPicked + ORDERDETAIL.ShippedQty ) as QtyShipped,  " +
      " ORIGIN.Company as Origination,    " +
      " SKU.Price,   " +
      " CONVERT(NVARCHAR(18),SKU.BUSR5) as DivisionCd,   " +
      -- Start : Add by June 10.Nov.2004 (SOS27707)
--    " (CASE WHEN MAX(PODETAIL.QtyOrdered) - MAX(PODETAIL.QtyReceived) > 0 THEN 'SS'  " +
--    "       WHEN MAX(PODETAIL.QtyOrdered) = 0 THEN '0qty' ELSE '  ' END) " +
      " (CASE WHEN SUM ( ORDERDETAIL.OriginalQty ) - SUM ( ORDERDETAIL.QtyAllocated + ORDERDETAIL.QtyPicked + ORDERDETAIL.ShippedQty ) = 0 THEN ' '  " +
	   " 		  WHEN MAX(PODETAIL.QtyOrdered) - MAX(PODETAIL.QtyReceived) > 0 THEN 'SS'  " +
      "       WHEN MAX(PODETAIL.QtyOrdered) = 0 THEN '0qty' ELSE '  ' END) " +
      -- End : Add by June 10.Nov.2004 (SOS27707)
      " FROM ORDERS (NOLOCK), SKU (NOLOCK), ORDERDETAIL (NOLOCK) " +
      " LEFT OUTER JOIN PODETAIL (NOLOCK) ON (PODETAIL.ExternPOKey=ORDERDETAIL.ExternPOKey AND  " +
      "                              PODETAIL.StorerKey=ORDERDETAIL.StorerKey AND  " +
      "                              PODETAIL.Sku=ORDERDETAIL.Sku)  " +
      " LEFT OUTER JOIN STORER ORIGIN (NOLOCK) ON (ORIGIN.StorerKey = 'IDS') " +
      " WHERE (ORDERDETAIL.OrderKey = ORDERS.OrderKey AND  " +
      "        ORDERDETAIL.Sku = SKU.Sku AND  " +
      "        ORDERDETAIL.StorerKey=SKU.StorerKey) " +
      " AND   (ORDERS.StorerKey = 'THWTC') " 

   IF dbo.fnc_RTrim(@c_LoadKey1) IS NOT NULL AND dbo.fnc_RTrim(@c_LoadKey1) <> '' 
   BEGIN
      IF (dbo.fnc_RTrim(@c_LoadKey2) IS NULL OR dbo.fnc_RTrim(@c_LoadKey2) = '' ) AND
         (dbo.fnc_RTrim(@c_LoadKey3) IS NULL OR dbo.fnc_RTrim(@c_LoadKey3) = '' ) AND
         (dbo.fnc_RTrim(@c_LoadKey4) IS NULL OR dbo.fnc_RTrim(@c_LoadKey4) = '' ) AND
         (dbo.fnc_RTrim(@c_LoadKey5) IS NULL OR dbo.fnc_RTrim(@c_LoadKey5) = '' ) AND
         (dbo.fnc_RTrim(@c_LoadKey6) IS NULL OR dbo.fnc_RTrim(@c_LoadKey6) = '' ) AND
         (dbo.fnc_RTrim(@c_LoadKey7) IS NULL OR dbo.fnc_RTrim(@c_LoadKey7) = '' ) AND
         (dbo.fnc_RTrim(@c_LoadKey8) IS NULL OR dbo.fnc_RTrim(@c_LoadKey8) = '' ) AND
         (dbo.fnc_RTrim(@c_LoadKey9) IS NULL OR dbo.fnc_RTrim(@c_LoadKey9) = '' ) AND
         (dbo.fnc_RTrim(@c_LoadKey10) IS NULL OR dbo.fnc_RTrim(@c_LoadKey10) = '' ) 
      BEGIN
         SELECT @c_SQL = dbo.fnc_RTrim(@c_SQL) + " AND ORDERS.LoadKey = N'" + dbo.fnc_RTrim(@c_LoadKey1) + "' "
      END 
      ELSE
      BEGIN
         SELECT @c_SQL = dbo.fnc_RTrim(@c_SQL) + " AND ORDERS.LoadKey IN (N'" + dbo.fnc_RTrim(@c_LoadKey1) + "'"

         IF (dbo.fnc_RTrim(@c_LoadKey2) IS NOT NULL AND dbo.fnc_RTrim(@c_LoadKey2) <> '' ) 
         BEGIN
            SELECT @c_SQL = dbo.fnc_RTrim(@c_SQL) + ", N'" + dbo.fnc_RTrim(@c_LoadKey2) + "'"
         END 

         IF (dbo.fnc_RTrim(@c_LoadKey3) IS NOT NULL AND dbo.fnc_RTrim(@c_LoadKey3) <> '' ) 
         BEGIN
            SELECT @c_SQL = dbo.fnc_RTrim(@c_SQL) + ", N'" + dbo.fnc_RTrim(@c_LoadKey3) + "'"
         END 
         IF (dbo.fnc_RTrim(@c_LoadKey4) IS NOT NULL AND dbo.fnc_RTrim(@c_LoadKey4) <> '' ) 
         BEGIN
            SELECT @c_SQL = dbo.fnc_RTrim(@c_SQL) + ", N'" + dbo.fnc_RTrim(@c_LoadKey4) + "'"
         END 
         IF (dbo.fnc_RTrim(@c_LoadKey5) IS NOT NULL AND dbo.fnc_RTrim(@c_LoadKey5) <> '' ) 
         BEGIN
            SELECT @c_SQL = dbo.fnc_RTrim(@c_SQL) + ", N'" + dbo.fnc_RTrim(@c_LoadKey5) + "'"
         END 
         IF (dbo.fnc_RTrim(@c_LoadKey6) IS NOT NULL AND dbo.fnc_RTrim(@c_LoadKey6) <> '' ) 
         BEGIN
            SELECT @c_SQL = dbo.fnc_RTrim(@c_SQL) + ", N'" + dbo.fnc_RTrim(@c_LoadKey6) + "'"
         END 
         IF (dbo.fnc_RTrim(@c_LoadKey7) IS NOT NULL AND dbo.fnc_RTrim(@c_LoadKey7) <> '' ) 
         BEGIN
            SELECT @c_SQL = dbo.fnc_RTrim(@c_SQL) + ", N'" + dbo.fnc_RTrim(@c_LoadKey7) + "'"
         END 
         IF (dbo.fnc_RTrim(@c_LoadKey8) IS NOT NULL AND dbo.fnc_RTrim(@c_LoadKey8) <> '' ) 
         BEGIN
            SELECT @c_SQL = dbo.fnc_RTrim(@c_SQL) + ", N'" + dbo.fnc_RTrim(@c_LoadKey8) + "'"
         END 
         IF (dbo.fnc_RTrim(@c_LoadKey9) IS NOT NULL AND dbo.fnc_RTrim(@c_LoadKey9) <> '' ) 
         BEGIN
            SELECT @c_SQL = dbo.fnc_RTrim(@c_SQL) + ", N'" + dbo.fnc_RTrim(@c_LoadKey9) + "'"
         END 
         IF (dbo.fnc_RTrim(@c_LoadKey10) IS NOT NULL AND dbo.fnc_RTrim(@c_LoadKey10) <> '' ) 
         BEGIN
            SELECT @c_SQL = dbo.fnc_RTrim(@c_SQL) + ", N'" + dbo.fnc_RTrim(@c_LoadKey10) + "'"
         END 

         SELECT @c_SQL = dbo.fnc_RTrim(@c_SQL) + ") "

      END

      IF (dbo.fnc_RTrim(@c_Store) IS NOT NULL AND dbo.fnc_RTrim(@c_Store) <> '' )
      BEGIN
         SELECT @c_SQL = dbo.fnc_RTrim(@c_SQL) + " AND ORDERS.Consigneekey = N'" + dbo.fnc_RTrim(@c_Store) + "'"
      END 
   END 
   ELSE
   BEGIN
      IF (dbo.fnc_RTrim(@c_Store) IS NOT NULL AND dbo.fnc_RTrim(@c_Store) <> '' )
      BEGIN
         SELECT @c_SQL = dbo.fnc_RTrim(@c_SQL) + " AND ORDERS.Consigneekey = N'" + dbo.fnc_RTrim(@c_Store) + "'"
      END 
   END

   SELECT @c_SQL = dbo.fnc_RTrim(@c_SQL) + " GROUP BY ORDERS.ConsigneeKey, ORDERS.C_Company, ORDERS.C_Address1, " + 
      "ORDERS.C_Address2, ORDERS.C_Address3, ORDERS.C_Address4, SKU.BUSR5, SKU.Sku, SKU.DESCR,  " + 
      "SKU.Price, ORDERDETAIL.UserDefine03, ORDERS.ExternOrderKey, " + 
      "CASE ORDERS.Type WHEN 'ALLOCATION' THEN '(NA)' WHEN 'XDOCK' THEN '(XD)' ELSE '' END, ORDERS.LoadKey,  " + 
      "CASE WHEN ORDERDETAIL.UserDefine03 = 'ALLOCATION' THEN 'BA' WHEN ORDERDETAIL.UserDefine03 = 'STOREORDER'  " + 
      "THEN 'StO' ELSE '  ' END, ORIGIN.Company   "  

   -- print @c_SQL 
   EXEC( @c_SQL) 
END 

GO

GRANT EXECUTE On isp_ShippingManifest_By_Store_TH_Det to nSQL
GO
