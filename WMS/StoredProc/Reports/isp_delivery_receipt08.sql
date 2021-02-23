IF EXISTS (SELECT Name FROM dbo.sysobjects WHERE Name = 'isp_delivery_receipt08' AND Type = 'P')
   DROP PROC isp_delivery_receipt08
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO 

/************************************************************************/  
/* Store Procedure:  isp_delivery_receipt08                             */  
/* Creation Date:  22-Dec-2020                                          */  
/* Copyright: LFL                                                       */  
/* Written by:  WLChooi                                                 */  
/*                                                                      */  
/* Purpose: WMS-15921 - AdidasPH B2C Delivery Receipt                   */  
/*          Copy from isp_delivery_receipt06 and modify                 */ 
/*                                                                      */  
/* Input Parameters:  @cMBOLkey  - (MBOLkey)                            */  
/*                                                                      */  
/* Output Parameters:  None                                             */  
/*                                                                      */  
/* Return Status:  None                                                 */  
/*                                                                      */  
/* Usage:                                                               */  
/*                                                                      */  
/* Local Variables:                                                     */  
/*                                                                      */  
/* Called By:r_dw_delivery_receipt08                                    */  
/*                                                                      */  
/* GitLab Version: 1.0                                                  */  
/*                                                                      */  
/* Version: 5.4                                                         */  
/*                                                                      */  
/* Data Modifications:                                                  */  
/*                                                                      */  
/* Updates:                                                             */  
/* Date        Author  Ver.  Purposes                                   */ 
/************************************************************************/  
CREATE PROC isp_delivery_receipt08 (@cMBOLkey NVARCHAR(10) )  
AS  
BEGIN  
   SET NOCOUNT ON     
   SET ANSI_NULLS OFF  
   SET QUOTED_IDENTIFIER OFF     
   SET CONCAT_NULL_YIELDS_NULL OFF 
   
   DECLARE   @cOrderKey     NVARCHAR(10)  
            ,@cStorerkey    NVARCHAR(15)  
            ,@c_CounterKey  NVARCHAR(10)  
            ,@cLot          NVARCHAR(18)  
            ,@cUserdefine10 NVARCHAR(10)  
            ,@PrevUserdefine10 NVARCHAR(10)  
            ,@cSKU          NVARCHAR(20)  
            ,@PrevSKU       NVARCHAR(20)  
            ,@cSeqNum         int  
            ,@PrevOrderKey  NVARCHAR(10)  
  
   DECLARE   @c_PrintedFlag   NVARCHAR(1)  
            ,@n_err           int  
            ,@n_continue      int  
            ,@b_success       int  
            ,@c_errmsg        NVARCHAR(255)  
            ,@n_starttcnt     int  
            ,@b_debug         int  
            ,@n_count         int  
            ,@cExecStatements NVARCHAR(max) 
            ,@n_ttlcases      INT = 1 
  
   CREATE TABLE [#Temp_Flag] (  
      MBOLKey           [NVARCHAR] (10) NULL,  
      PrintFlag         [NVARCHAR] (1)    NULL)  
 
   CREATE TABLE [#Temptb08] (  
      Orderkey          [NVARCHAR] (10) NULL,  
      UserDefine10      [NVARCHAR] (10) NULL,  
      ExternOrderKey    [NVARCHAR] (30) NULL,  
      PrintFlag         [NVARCHAR] (1)    NULL,  
      Consigneekey      [NVARCHAR] (15) NULL,  
      C_Company         [NVARCHAR] (45) NULL,  
      C_Address1        [NVARCHAR] (45) NULL,  
      C_Address2        [NVARCHAR] (45) NULL,  
      C_Address3        [NVARCHAR] (45) NULL,  
      C_Address4        [NVARCHAR] (45) NULL,  
      DESCR             [NVARCHAR] (255) NULL,  
      OrderDate         [datetime]  NULL,  
      DeliveryDate      [datetime]  NULL,  
      DepartureDate     [datetime]  NULL,  
      CarrierAgent      [NVARCHAR] (30) NULL,  
      VesselQualifier   [NVARCHAR] (10) NULL,  
      DriverName        [NVARCHAR] (30) NULL,  
      Vessel            [NVARCHAR] (30) NULL,  
      OtherReference    [NVARCHAR] (30) NULL,  
      SKU               [NVARCHAR] (20) NULL,  
      ID                [NVARCHAR] (60) NULL,  
      Logo              [NVARCHAR] (60) NULL,   
      CompanyName       [NVARCHAR] (45) NULL,
      CntCases          [INT]      NULL,
      ttlcases          [INT]      NULL,
      MBOLKey           [NVARCHAR] (10) NULL)  

     CREATE TABLE [#Temp_CHKCASES] (  
     	Orderkey          [NVARCHAR] (10) NULL,
      PID               [NVARCHAR] (18) NULL,
      SKU               [NVARCHAR] (20) NULL,
      Qty               [INT]   NULL)  
  
   SELECT @n_starttcnt=@@TRANCOUNT, @n_continue = 1, @b_debug = 0, @n_err = 0, @c_PrintedFlag = 'N'  
  
   SELECT @n_count = count(*) FROM ORDERS (NOLOCK)  
   WHERE ORDERS.MBOLKey = @cMBOLkey  
  
   IF @n_count <= 0  
   BEGIN  
      SELECT @n_continue = 4  
      IF @b_debug = 1  
         PRINT 'No Data Found'  
   END  
   ELSE  
   IF @b_debug = 1  
      PRINT 'Start Processing...  MBOLKey=' + @cMBOLkey  
  
   -- Assign DR Number (1 MBOLKey = 1 DR Number)
   IF @n_continue = 1 or @n_continue = 2  
   BEGIN  
      IF EXISTS (SELECT 1 FROM ORDERS (NOLOCK) WHERE MBOLKey = @cMBOLkey AND UserDefine10 = '')
      BEGIN   
      	SELECT @cStorerkey = MAX(ORDERS.StorerKey)
      	FROM ORDERS (NOLOCK) 
      	WHERE ORDERS.MBOLKey = @cMBOLkey
      	
         SELECT @c_PrintedFlag = 'N'  
         SET @c_CounterKey = ''  
   
         SELECT @c_CounterKey = Code  
         FROM CodeLkUp (NOLOCK)  
         WHERE ListName = 'DR_NCOUNT'  
         AND SHORT = @cStorerkey  
   
         IF @c_CounterKey = ''  
         BEGIN  
            SELECT @n_continue = 3  
            SELECT @n_err = 63600      -- should assign new error code  
            SELECT @c_errmsg="NSQL"+CONVERT(NVARCHAR(5),@n_err)+": No Setup for CodeLkUp.ListName = DR_NCOUNT. (isp_delivery_receipt08)"  
         END  
   
         IF @b_debug = 1  
         BEGIN  
            PRINT 'Check this: SELECT Code FROM CodeLkUp (NOLOCK) WHERE ListName = ''DR_NCOUNT'' AND SHORT =N''' + dbo.fnc_RTrim(@cStorerkey) + ''''  
         END  
   
         IF @n_continue = 1 or @n_continue = 2  
         BEGIN  
            SELECT @b_success = 0  
   
            EXECUTE nspg_GetKey  @c_CounterKey, 10,  
                  @cUserDefine10 OUTPUT,  
                  @b_success     OUTPUT,  
                  @n_err         OUTPUT,  
                  @c_errmsg      OUTPUT  
   
            IF @b_debug = 1  
               PRINT 'MBOLKey = ' + @cMBOLkey + ' GET UserDefine10 (DR)= ' + @cUserDefine10 + master.dbo.fnc_GetCharASCII(13) + master.dbo.fnc_GetCharASCII(13)  
   
            IF @b_success <> 1  
            BEGIN  
               SELECT @n_continue = 3  
               SELECT @n_err = 63500      -- should assign new error code  
               SELECT @c_errmsg="NSQL"+CONVERT(NVARCHAR(5),@n_err)+": Fail to Generate Userdeine10 . (isp_delivery_receipt08)"  
            END  
         END  
   
         IF @n_continue = 1 or @n_continue = 2  
         BEGIN  
            UPDATE ORDERS 
            SET UserDefine10 = @cUserDefine10
            WHERE MBOLKey = @cMBOLkey  
   
            SELECT @n_err = @@ERROR  
   
            IF @n_err <> 0  
            BEGIN  
               SELECT @n_continue = 3  
               SELECT @n_err = 63501      -- should assign new error code  
               SELECT @c_errmsg="NSQL"+CONVERT(NVARCHAR(5),@n_err)+": UPDATE ORDERS Failed. (isp_delivery_receipt08)"  
            END  
         END -- @n_continue = 1 or @n_continue = 2  
   
         INSERT INTO #Temp_Flag(PrintFlag, MBOLKey)  
         VALUES(@c_PrintedFlag, @cMBOLkey)  
      END
   END -- @n_count > 0  
   
   SET @n_ttlcases = 1
   
   INSERT INTO #Temp_CHKCASES (Orderkey, PID, SKU, Qty)
   SELECT PD.Orderkey, PD.ID, PD.SKU, SUM(PD.Qty)
   FROM PICKDETAIL PD WITH (NOLOCK)
   JOIN ORDERS OH WITH (NOLOCK) ON OH.Orderkey = PD.Orderkey
   WHERE OH.MBOLKey = @cMBOLkey
   GROUP BY PD.ID, PD.SKU, PD.OrderKey
   
   SELECT @n_ttlcases = SUM(Qty)
   FROM #Temp_CHKCASES
   
   -- Retrieve SELECT LIST  
   If @n_continue = 1 or @n_continue = 2  
   BEGIN  
      INSERT INTO #Temptb08  
      SELECT  
         ORDERS.orderkey,  
         ORDERS.UserDefine10,  
         '',   --ORDERS.ExternOrderKey,  
         ISNULL(#Temp_Flag.PrintFlag, 'Y'),     -- ISNULL mean existing UserDefine10 <> '' ==> Printed before  
         ORDERS.Consigneekey,  
         ISNULL(ORDERS.C_Company,''),  
         ISNULL(ORDERS.C_Address1,''),  
         ISNULL(ORDERS.C_Address2,''),  
         ISNULL(ORDERS.C_Address3,''),  
         ISNULL(ORDERS.C_Address4,''),  
         SKU.DESCR,  
         ORDERS.OrderDate,  
         ORDERS.DeliveryDate,  
         MBOL.DepartureDate,  
         MBOL.CarrierAgent,  
         MBOL.VesselQualifier,  
         MBOL.DriverName,  
         MBOL.Vessel,  
         MBOL.OtherReference,  
         Pickdetail.SKU,  
         Pickdetail.ID ID,  
         Storer.Logo,  
         Storer.Company,
         #Temp_CHKCASES.Qty,
         @n_ttlcases,
         @cMBOLkey
      FROM ORDERS (NOLOCK)  
      JOIN ORDERDETAIL (NOLOCK) ON ORDERS.Orderkey = OrderDetail.Orderkey  
      JOIN MBOLDETAIL (NOLOCK) ON MBOLDETAIL.Orderkey = ORDERS.Orderkey  
      JOIN Storer (NOLOCK) ON ORDERS.Storerkey = Storer.Storerkey  
      JOIN SKU (NOLOCK) ON SKU.SKU = OrderDetail.SKU AND SKU.StorerKey = Storer.StorerKey
      JOIN MBOL (NOLOCK) ON MBOL.MBOLKey = MBOLDETAIL.MBOLKey  
      JOIN Pickdetail (NOLOCK) ON (PickDetail.OrderKey = OrderDetail.OrderKey  
                              AND PICKDETAIL.orderlinenumber = ORDERDETAIL.orderlinenumber AND ORDERDETAIL.Sku = PICKDETAIL.SKU)  
      JOIN PACK (NOLOCK) ON SKU.Packkey = PACK.PackKey  
      LEFT JOIN CODELKUP (NOLOCK) ON Orders.Storerkey = CODELKUP.Short AND CODELKUP.Listname = 'DR_NCOUNT'
      LEFT OUTER JOIN #Temp_Flag ON #Temp_Flag.MBOLKey = ORDERS.MBOLKey  
      LEFT OUTER JOIN #Temp_CHKCASES ON #Temp_CHKCASES.PID = PICKDETAIL.ID 
                                    AND #Temp_CHKCASES.SKU = Pickdetail.SKU
                                    AND #Temp_CHKCASES.Orderkey = PICKDETAIL.OrderKey
      WHERE ORDERS.MBOLKey = @cMBOLKey  
      GROUP BY ORDERS.orderkey,  
               ORDERS.UserDefine10,  
               --ORDERS.ExternOrderKey,  
               ISNULL(#Temp_Flag.PrintFlag, 'Y'),     -- ISNULL mean existing UserDefine10 <> '' ==> Printed before  
               ORDERS.Consigneekey,  
               ISNULL(ORDERS.C_Company,''),  
               ISNULL(ORDERS.C_Address1,''),  
               ISNULL(ORDERS.C_Address2,''),  
               ISNULL(ORDERS.C_Address3,''),  
               ISNULL(ORDERS.C_Address4,''),  
               SKU.DESCR,
               ORDERS.OrderDate,  
               ORDERS.DeliveryDate,  
               MBOL.DepartureDate,  
               MBOL.CarrierAgent,  
               MBOL.VesselQualifier,  
               MBOL.DriverName,  
               MBOL.Vessel,  
               MBOL.OtherReference,  
               Pickdetail.SKU,   
               Pickdetail.ID,  
               Storer.Logo,  
               Storer.Company,
               #Temp_CHKCASES.Qty
   END  
  
   -- SORT ORDER  
   If @n_continue = 1 or @n_continue = 2  
   BEGIN  
      SELECT * , IDENTITY(INT, 1, 1) AS SeqNum  
      INTO #Temptb1  
      FROM #Temptb08  
      ORDER BY ID, Sku--, Lott01 
   
      IF @@ROWCOUNT = 0  
      BEGIN  
         SELECT @n_continue = 3  
         SELECT @n_err = 63500      -- should assign new error code  
         SELECT @c_errmsg="NSQL"+CONVERT(NVARCHAR(5),@n_err)+": No Data Found. (isp_delivery_receipt08)"  
      END  
   
   --   -- Show the OrderQty only on the first line per sku in same order (same DR number)  
   --   If @n_continue = 1 or @n_continue = 2  
   --   BEGIN  
   --      SELECT @cUserdefine10 = '', @PrevUserdefine10 = '', @cSKU= '', @PrevSKU = '', @cSeqNum = 0  
   --      DECLARE CurSKU CURSOR LOCAL FAST_FORWARD READ_ONLY FOR  
   
   --      SELECT Userdefine10, SKU, SeqNum  
   --      FROM #Temptb1 (NOLOCK)  
   --      Order by SeqNum  
   
   --      OPEN CurSKU  
   --      FETCH NEXT FROM CurSKU INTO @cUserdefine10, @cSKU, @cSeqNum  
   
   --      WHILE @@FETCH_STATUS <> -1 and (@n_continue = 1 OR @n_continue = 2) -- CurOrder Loop  
   --      BEGIN  
   --         If @PrevUserdefine10 <> @cUserdefine10  
   --         BEGIN  
   --            SELECT @PrevUserdefine10 = @cUserdefine10  
   --            SELECT @PrevSKU = @cSKU  
   --         END  
   --         ELSE  
   --         BEGIN  
   --            IF @PrevSKU <> @cSKU  
   --               SELECT @PrevSKU = @cSKU  
   --            --ELSE  
   --            --   UPDATE #Temptb1 SET OrderQty = NULL  
   --            --   WHERE SeqNum = @cSeqNum  
   --         END  
   
   --         FETCH NEXT FROM CurSKU INTO @cOrderKey, @cSKU, @cSeqNum  
   --      END  
   --      CLOSE CurSKU  
   --      DEALLOCATE CurSKU  
   --   END -- Show the OrderQty only on the first line per sku in same order (same DR number)  
   END -- If @n_continue = 1 or @n_continue = 2 FOR Retrieve SELECT LIST  
  
   If @n_continue = 1 or @n_continue = 2  
      SELECT * FROM #Temptb1  
      ORDER BY SeqNum  
  
   IF @n_continue=3  -- Error Occured - Process And Return  
   BEGIN  
      execute nsp_logerror @n_err, @c_errmsg, "isp_delivery_receipt08"  
      RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012  
      RETURN  
   END  
   ELSE  
   BEGIN  
      SELECT @b_success = 1  
      WHILE @@TRANCOUNT > @n_starttcnt  
      BEGIN  
         COMMIT TRAN  
      END  
      RETURN  
   END  
  
   IF OBJECT_ID('tempdb..#Temp_Flag') IS NOT NULL  
      DROP TABLE #Temp_Flag  

   IF OBJECT_ID('tempdb..#Temptb08') IS NOT NULL  
      DROP TABLE #Temptb08  

   IF OBJECT_ID('tempdb..#Temp_CHKCASES') IS NOT NULL  
      DROP TABLE #Temp_CHKCASES  

   IF OBJECT_ID('tempdb..#Temptb1') IS NOT NULL  
      DROP TABLE #Temptb1  
  
END /* main procedure */  
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
GRANT EXECUTE ON isp_delivery_receipt08 to nSQL
GO

