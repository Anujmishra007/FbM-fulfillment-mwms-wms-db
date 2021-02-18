IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'isp_EXG_CNWMSNKE_CONVERSE_PackList') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
BEGIN 
   DROP PROCEDURE isp_EXG_CNWMSNKE_CONVERSE_PackList  
END
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO 

/*************************************************************************/  
/* Stored Procedure: isp_EXG_CNWMSNKE_CONVERSE_PackList                  */  
/* Creation Date: 08 Jul 2020                                            */  
/* Copyright: LFL                                                        */  
/* Written by: GHChan                                                    */  
/*                                                                       */  
/* Purpose: Excel Generator CONVERSE PackList Sheet Report               */  
/*                                                                       */  
/* Called By:                                                            */  
/*                                                                       */  
/* PVCS Version: -                                                       */  
/*                                                                       */  
/* Updates:                                                              */  
/* Date          Author   Ver  Purposes                                  */  
/* 08-Jul-2020   GHChan   1.0  Initial Development                       */  
/*************************************************************************/  
  
CREATE PROCEDURE [dbo].[isp_EXG_CNWMSNKE_CONVERSE_PackList]  
(  @n_FileKey     INT           = 0  
,  @n_EXG_Hdr_ID  INT     = 0  
,  @c_FileName    NVARCHAR(200) = ''  
,  @c_SheetName   NVARCHAR(100) = ''  
,  @c_Delimiter   NVARCHAR(2)   = ''  
,  @c_ParamVal1   NVARCHAR(200) = ''  
,  @c_ParamVal2   NVARCHAR(200) = ''  
,  @c_ParamVal3   NVARCHAR(200) = ''  
,  @c_ParamVal4   NVARCHAR(200) = ''  
,  @c_ParamVal5   NVARCHAR(200) = ''  
,  @c_ParamVal6   NVARCHAR(200) = ''  
,  @c_ParamVal7   NVARCHAR(200) = ''  
,  @c_ParamVal8   NVARCHAR(200) = ''  
,  @c_ParamVal9   NVARCHAR(200) = ''  
,  @c_ParamVal10  NVARCHAR(200) = ''  
,  @b_Debug       INT           = 1  
,  @b_Success     INT           = 1    OUTPUT  
,  @n_Err         INT           = 0    OUTPUT  
,  @c_ErrMsg      NVARCHAR(250) = ''   OUTPUT   
)  
AS  
BEGIN  
   SET NOCOUNT ON   
   SET ANSI_NULLS OFF  
   SET QUOTED_IDENTIFIER OFF   
   SET CONCAT_NULL_YIELDS_NULL OFF    
  
   /*********************************************/  
   /* Variables Declaration (Start)             */  
   /*********************************************/  
  
   DECLARE @n_Continue      INT = 1  
         , @n_StartTcnt     INT = @@TRANCOUNT  
  
   /*********************************************/  
   /* Variables Declaration (End)               */  
   /*********************************************/  
  
   IF @b_Debug = 1  
   BEGIN  
      PRINT '[dbo].[isp_EXG_CNWMSNKE_CONVERSE_PackList]: Start...'  
      PRINT '[dbo].[isp_EXG_CNWMSNKE_CONVERSE_PackList]: '  
          + ',@n_FileKey='      + ISNULL(RTRIM(@n_FileKey), '')  
      + ',@n_EXG_Hdr_ID='   + ISNULL(RTRIM(@n_EXG_Hdr_ID), '')  
          + ',@c_FileName='     + ISNULL(RTRIM(@c_FileName), '')  
          + ',@c_SheetName='    + ISNULL(RTRIM(@c_SheetName), '')  
          + ',@c_Delimiter='    + ISNULL(RTRIM(@c_Delimiter), '')  
          + ',@c_ParamVal1='    + ISNULL(RTRIM(@c_ParamVal1), '')  
          + ',@c_ParamVal2='    + ISNULL(RTRIM(@c_ParamVal2), '')  
          + ',@c_ParamVal3='    + ISNULL(RTRIM(@c_ParamVal3), '')  
          + ',@c_ParamVal4='    + ISNULL(RTRIM(@c_ParamVal4), '')  
          + ',@c_ParamVal5='    + ISNULL(RTRIM(@c_ParamVal5), '')  
          + ',@c_ParamVal6='    + ISNULL(RTRIM(@c_ParamVal6), '')  
          + ',@c_ParamVal7='    + ISNULL(RTRIM(@c_ParamVal7), '')  
          + ',@c_ParamVal8='    + ISNULL(RTRIM(@c_ParamVal8), '')  
          + ',@c_ParamVal9='    + ISNULL(RTRIM(@c_ParamVal9), '')  
          + ',@c_ParamVal10='   + ISNULL(RTRIM(@c_ParamVal10), '')  
   END  
  
   -- Check whether got records   
   IF @n_EXG_Hdr_ID = 1  
   BEGIN  
      IF NOT EXISTS (  
      Select   t1.Mbolkey as [发货单号(Shipment Number)]  
            ,  t1.ExternOrderkey as [PT号(PickShip Number)]  
            ,  t1.BuyerPO as [订单号(SO Number)]  
            ,  Convert(char(10),t1.Editdate,121) as [发货日期(Shipped Date)]  
            ,  Convert(char(10),DateAdd(Day,cast(t6.Short as int),t1.Editdate),121) as [预计到货日期(ETA)]  
            ,  t1.Billtokey as [客户编号(Sold to Code)]  
            ,  t1.Consigneekey as [收货单位(Ship to code)]  
            ,  case when isnull(t7.Company,'')<>''   
                  then t7.Company   
                  else t1.C_Company   
               end as [客户名称(CustomerName)]  
            ,  case when isnull(ltrim(rtrim(t7.Address1)),'')+isnull(ltrim(rtrim(t7.Address2)),'')<>''   
                  then ltrim(rtrim(isnull(t7.Address1,'')))+ltrim(rtrim   (isnull(t7.Address2,'')))+ltrim(rtrim(isnull(t7.Address3,'')))   
                  else ltrim(rtrim(isnull(t1.C_Address1,'')))+ltrim(rtrim(isnull    (t1.C_Address2,'')))+ltrim(rtrim(isnull(t1.C_Address3,'')))   
               end as [送货地址(Ship to Address)]  
            ,  t3.CartonNo as [箱号(CartonNo)]  
          ,  t4.Style as [款号(Style)]  
            ,  case when t1.stop='20'   
                  then ''   
                  else t4.Color   
               end as [颜色(Color)]    
            --case when left(ltrim(rtrim(t4.size)),1)='0'   
            --then cast(cast(cast(t4.Size as int) as float)/10 as varchar(5))   
            --else t4.Size   
            --end as [尺码(Size)], t1.stop as [产品大类(SKUClass)],   
            -- ,  case   
            --       when t4.size = '00'   
            --          then t4.size   
            -- when left(ltrim(rtrim(t4.size)),1)='0' and t4.size <> '00'   
            --          then cast(cast(cast(t4.Size as int) as float)/10 as varchar(5))    
            -- when (t4.measurement ='' or t4.measurement = 'U')   
            --          then t4.Size   
            --    else t4.measurement   
           --end as [尺码(Size)]  
            ,  case   
                  when t4.BUSR8='10' AND ISNULL(t4.measurement,'') <> '' then t4.measurement  
                when t4.BUSR8='10' AND ISNULL(t4.measurement,'') = ''  then t4.size   
            when left(ltrim(rtrim(t4.size)),1)='0' and t4.size <> '00' then cast(cast(cast(t4.Size as int) as float)/10 as varchar(5))    
            when (t4.measurement ='' or t4.measurement = 'U') then t4.Size   
            else t4.measurement   
           end as [尺码(Size)]  
          ,  t8.Userdefine09 as Material_Number  
            ,  t1.stop as [产品大类(SKUClass)]  
            ,  case   
                  when isnull(t3.UPC,'')<>'' and len(t3.UPC)<=17 and t3.UPC<>t3.SKU   
                     then t3.UPC    
                  when isnull(t4.ProductModel,'')='G' and len(t3.UPC)=20   
                     then ltrim(rtrim(t4.RetailSKU))+ ltrim(rtrim(isnull(t5.Userdefined03,'')))    
                  when isnull(t4.ProductModel,'')<>'G' and len(t3.UPC)=20 and isnull(t4.RetailSKU,'')<>''   
                     then t4.RetailSKU   
                  when isnull(t4.ProductModel,'')<>'G' and t3.UPC=t3.SKU and isnull(t4.RetailSKU,'')<>''   
                     then t4.RetailSKU   
                  when isnull(t4.ProductModel,'')<>'G' and len(t3.UPC)=20 and isnull(t4.MANUFACTURERSKU,'')<>''   
                     then t4.MANUFACTURERSKU   
                  when isnull(t4.ProductModel,'')<>'G' and t3.UPC=t3.SKU and isnull(t4.MANUFACTURERSKU,'')<>''   
                     then t4.MANUFACTURERSKU   
                     else ltrim(rtrim(t4.AltSKU))+left(ltrim(rtrim(t4.BUSR3)),2)+ (case right(ltrim(rtrim(t4.BUSR3)),1) when 'S' then '01' when 'R' then '02' when 'F' then '03' when 'H' then '04' end)    
               end as [产品条码(Product barcode)]  
            ,  case   
               --when t4.ProductModel='G' and len(t3.UPC)<=17 then right(ltrim(rtrim(t3.UPC)),4)    
               --when t4.ProductModel='G' and len(t3.UPC)=20 then ltrim(rtrim(t5.Userdefined03))   
                  when isnull(t8.Userdefine06,'')<>'' and left(ltrim(rtrim(t8.Userdefine06)),1) not in('S','R','F','H')  
                     then left(ltrim(rtrim(t8.Userdefine06)),2)+ (case right(ltrim(rtrim(t8.Userdefine06)),1) when 'S' then '01' when 'R' then '02' when 'F' then '03' when 'H' then '04' end)    
                  when isnull(t8.Userdefine06,'')<>'' and left(ltrim(rtrim(t8.Userdefine06)),2) in('SP','SU','FA','HO')   
                     then right(ltrim(rtrim(t8.Userdefine06)),2)+ (case left(ltrim(rtrim(t8.Userdefine06)),2) when 'SP' then '01' when 'SU' then '02' when 'FA' then '03' when 'HO' then '04' end)    
                     else left(ltrim(rtrim(t4.BUSR3)),2)+ (case right(ltrim(rtrim(t4.BUSR3)),1) when 'S' then '01' when 'R' then '02' when 'F' then '03' when 'H' then '04' end)   
               end as [季节(Season Code)]  
            ,  SUM ( t3.Qty ) as [发货数量(ShippedQty)]  
            ,  t3.LabelNo as [外箱条码(UCC)]  
            ,  case   
                  when len(t1.consigneekey)=7   
                     then ltrim(rtrim(t1.Billtokey))+ltrim(rtrim(t1.Consigneekey))   
                     else t1.Consigneekey   
                  end as Consigneekey  
            ,  '*'+ t3.LabelNo +'*'  AS [条码] -- add by ella 1/19  
   From CNWMSNKE..Orders as t1(nolock)   
   inner join CNWMSNKE..PackHeader as t2(nolock) on t1.Orderkey=t2.Orderkey and t2.status='9'   
   inner join CNWMSNKE..PackDetail as t3(nolock) on t2.Pickslipno=t3.Pickslipno   
      inner join (select Distinct storerkey,Orderkey,SKU, userdefine06,Userdefine09   
               from CNWMSNKE..Orderdetail(nolock)   
                  where Storerkey=@c_ParamVal1) as t8 on t2.Orderkey=t8.Orderkey and t3.SKU=t8.SKU    
   inner join CNWMSNKE..SKU as t4(nolock) on t3.Storerkey=t4.Storerkey and t3.SKU=t4.SKU   
   left  join CNWMSNKE..UCC as t5(nolock) on t3.Storerkey=t5.Storerkey and t3.SKU=t5.SKU and t3.UPC=t5.UCCNo   
   left  join CNWMSNKE..Storer as t7(nolock) on ltrim(rtrim(t1.Billtokey))+ltrim(rtrim(t1.Consigneekey))=t7.Storerkey   
   --left  join CNWMSNKE..Codelkup as t6(nolock) on t6.ListName='CityLdTime' and cast(t6.Notes as varchar(20))='Converse' and (case when len(t1.Consigneekey)=10 and t1.Consigneekey=t6.code then 1 when len(t1.Consigneekey)=7 and ltrim(rtrim(t1.Billtokey))+ltrim(rtrim(t1.Consigneekey))=t6.Code then 1 else 0 end)=1   
   left  join CNWMSNKE..Codelkup as t6(nolock) on t6.ListName='CityLdTime' and cast(t6.Notes as varchar(20))=@c_ParamVal1 and t1.Consigneekey = t6.code   
      Where t1.Mbolkey = @c_ParamVal2 and t1.Consigneekey = @c_ParamVal3 and t1.Status in('5','9')    
      Group by t1.Mbolkey  
            ,  t1.ExternOrderkey   
            ,  t1.BuyerPO  
            ,  Convert(char(10),t1.Editdate,121)   
            ,  t1.Billtokey   
            ,  t1.Consigneekey  
            ,  case   
                  when isnull(t7.Company,'')<>''   
                     then t7.Company   
                     else t1.C_Company   
               end   
            ,  case   
                  when isnull(ltrim(rtrim(t7.Address1)),'')+isnull(ltrim(rtrim(t7.Address2)),'')<>''   
                     then ltrim(rtrim(isnull(t7.Address1,'')))+ltrim(rtrim(isnull(t7.Address2,'')))+ltrim(rtrim(isnull(t7.Address3,'')))   
                     else ltrim(rtrim(isnull(t1.C_Address1,'')))+ltrim(rtrim(isnull(t1.C_Address2,'')))+ltrim(rtrim(isnull(t1.C_Address3,'')))   
               end  
            ,  t3.CartonNo  
            ,  t4.Style  
            ,  case   
                  when t1.stop='20'   
                     then ''   
                     else t4.Color   
               end  
            ,  case   
                  when t4.BUSR8='10' AND ISNULL(t4.measurement,'') <> '' then t4.measurement  
                when t4.BUSR8='10' AND ISNULL(t4.measurement,'') = ''  then t4.size   
            when left(ltrim(rtrim(t4.size)),1)='0' and t4.size <> '00' then cast(cast(cast(t4.Size as int) as float)/10 as varchar(5))    
            when (t4.measurement ='' or t4.measurement = 'U') then t4.Size   
            else t4.measurement   
           end  
            ,  t4.Measurement  
            ,  case   
                  when isnull(t3.UPC,'')<>'' and len(t3.UPC)<=17 and t3.UPC<>t3.SKU   
          then t3.UPC    
                  when isnull(t4.ProductModel,'')='G' and len(t3.UPC)=20   
                     then ltrim(rtrim(t4.RetailSKU))+ ltrim(rtrim(isnull(t5.Userdefined03,'')))    
                  when isnull(t4.ProductModel,'')<>'G' and len(t3.UPC)=20 and isnull(t4.RetailSKU,'')<>''   
                     then t4.RetailSKU   
                  when isnull(t4.ProductModel,'')<>'G' and t3.UPC=t3.SKU and isnull(t4.RetailSKU,'')<>''   
                     then t4.RetailSKU   
                  when isnull(t4.ProductModel,'')<>'G' and len(t3.UPC)=20 and isnull(t4.MANUFACTURERSKU,'')<>''   
                     then t4.MANUFACTURERSKU   
                  when isnull(t4.ProductModel,'')<>'G' and t3.UPC=t3.SKU and isnull(t4.MANUFACTURERSKU,'')<>''   
                     then t4.MANUFACTURERSKU   
                     else ltrim(rtrim(t4.AltSKU))+left(ltrim(rtrim(t4.BUSR3)),2)+ (case right(ltrim(rtrim(t4.BUSR3)),1) when 'S' then '01' when 'R' then '02' when 'F' then '03' when 'H' then '04' end)    
               end  
            ,  case --when t4.ProductModel='G' and len(t3.UPC)<=17 then right(ltrim(rtrim(t3.UPC)),4)    
               --when t4.ProductModel='G' and len(t3.UPC)=20 then ltrim(rtrim(t5.Userdefined03))   
                  when isnull(t8.Userdefine06,'')<>'' and left(ltrim(rtrim(t8.Userdefine06)),1) not in('S','R','F','H')  
                     then left(ltrim(rtrim(t8.Userdefine06)),2)+ (case right(ltrim(rtrim(t8.Userdefine06)),1) when 'S' then '01' when 'R' then '02' when 'F' then '03' when 'H' then '04' end)    
                  when isnull(t8.Userdefine06,'')<>'' and left(ltrim(rtrim(t8.Userdefine06)),2) in('SP','SU','FA','HO')   
                     then right(ltrim(rtrim(t8.Userdefine06)),2)+ (case left(ltrim(rtrim(t8.Userdefine06)),2) when 'SP' then '01' when 'SU' then '02' when 'FA' then '03' when 'HO' then '04' end)    
                     else left(ltrim(rtrim(t4.BUSR3)),2)+ (case right(ltrim(rtrim(t4.BUSR3)),1) when 'S' then '01' when 'R' then '02' when 'F' then '03' when 'H' then '04' end)  
               end   
            ,  t3.LabelNo   
            ,  case   
                  when len(t1.consigneekey)=7   
                     then ltrim(rtrim(t1.Billtokey))+ltrim(rtrim(t1.Consigneekey))   
                     else t1.Consigneekey   
               end  
            ,  Convert(char(10),DateAdd(Day,cast(t6.Short as int),t1.Editdate),121)  
            ,  t1.stop  
            ,  t8.userdefine09   
      --Order by t1.ExternOrderkey  
      --      ,  t3.CartonNo  
      --      ,  t4.Style  
      --      ,  case   
      --            when t1.stop='20'   
      --               then ''   
      --               else t4.Color   
      --         end  
      --      ,  case   
      --         when t4.BUSR8='10' then t4.measurement    
      --     when left(ltrim(rtrim(t4.size)),1)='0' and t4.size <> '00' then cast(cast(cast(t4.Size as int) as float)/10 as varchar(5))    
      --     when (t4.measurement ='' or t4.measurement = 'U') then t4.Size else t4.measurement end    
      )  
      BEGIN  
         SET @n_Err = 200001  
      SET @c_ErrMsg ='No records have been found! (isp_EXG_CNWMSNKE_CONVERSE_PackList)'  
         SET @n_Continue = 3  
         GOTO QUIT  
      END  
   END  
   ELSE IF  @n_EXG_Hdr_ID = 3  
   BEGIN  
      IF NOT EXISTS (  
      Select   t1. Mbolkey as [发货单号(Shipment Number)]  
             , t1.ExternOrderkey as [PT号(PickShip Number)]  
             , Convert(char(10),t1.Editdate,121) as [发货日期(Shipped Date)]  
             , Convert(char(10),DateAdd(Day,cast(t6.Short as int),t1.Editdate),121) as [预计到货日期(ETA)]  
             , t1.Consigneekey as [收货单位(Ship to code)]  
             , case   
                  when isnull(t7.Company,'')<>''   
                     then t7.Company   
                  else t1.C_Company   
               end as [客户名称(CustomerName)]  
             , case   
                  when isnull(ltrim(rtrim(t7.Address1)),'')+isnull(ltrim(rtrim(t7.Address2)),'')<>''   
     then ltrim(rtrim(isnull(t7.Address1,'')))+ltrim(rtrim(isnull(t7.Address2,'')))+ltrim(rtrim(isnull(t7.Address3,'')))   
                  else ltrim(rtrim(isnull(t1.C_Address1,'')))+ltrim(rtrim(isnull(t1.C_Address2,'')))+ltrim(rtrim(isnull(t1.C_Address3,'')))   
               end as [送货地址(Ship to Address)]  
             , t3.CartonNo as [箱号(CartonNo)]  
             , t4.Style as [款号(Style)]  
             , case   
                  when t1.stop='20'   
                     then ''   
                  else t4.Color   
               end as [颜色(Color)]  
             , case   
                  when t4.BUSR8='10' AND ISNULL(t4.measurement,'') <>''   
                     then t4.measurement  
              when t4.BUSR8='10' AND ISNULL(t4.measurement,'') =''   
                     then t4.size  
              when left(ltrim(rtrim(t4.size)),1)='0' and t4.size <> '00'   
                     then cast(cast(cast(t4.Size as int) as float)/10 as varchar(5))    
              when (t4.measurement ='' or t4.measurement = 'U')   
                     then t4.Size   
                  else t4.measurement   
               end as [尺码(Size)]  
             , t4.SUSR5 AS Material_Number  
             , t1.stop as [产品大类(SKUClass)]  
             , t4.MANUFACTURERSKU AS [产品条码(Product barcode)]  
             , SUM ( t3.Qty ) as [发货数量(ShippedQty)]  
             , t3.LabelNo as [外箱条码(UCC)]  
             , case   
                  when len(t1.consigneekey)=7   
                     then ltrim(rtrim(t1.Billtokey))+ltrim(rtrim(t1.Consigneekey))   
                  else t1.Consigneekey   
               end as Consigneekey  
             , '*'+ t3.LabelNo +'*'  AS [条码]       
      From  CNWMSNKE..Orders as t1(nolock)   
      inner join CNWMSNKE..PackHeader as t2(nolock) on t1.Orderkey=t2.Orderkey and t2.status='9'   
      inner join CNWMSNKE..PackDetail as t3(nolock) on t2.Pickslipno=t3.Pickslipno   
      inner join CNWMSNKE..SKU as t4(nolock) on t3.Storerkey=t4.Storerkey and t3.SKU=t4.SKU   
      left  join CNWMSNKE..UCC as t5(nolock) on t3.Storerkey=t5.Storerkey and t3.SKU=t5.SKU and t3.UPC=t5.UCCNo   
      left  join CNWMSNKE..Storer as t7(nolock) on ltrim(rtrim(t1.Billtokey))+ltrim(rtrim(t1.Consigneekey))=t7.Storerkey   
      left  join CNWMSNKE..Codelkup as t6(nolock) on t6.ListName='CityLdTime' and cast(t6.Notes as varchar(20))='Converse' and t1.Consigneekey = t6.code   
      Where t1.Mbolkey=@c_ParamVal2 and t1.Consigneekey = @c_ParamVal3 and t1.Status in('5','9')    
      Group by t1. Mbolkey  
             , t1.ExternOrderkey   
             , Convert(char(10),t1.Editdate,121)   
             , t1.Consigneekey  
             , case   
                  when isnull(t7.Company,'')<>''   
                     then t7.Company   
                  else t1.C_Company   
               end   
             , case   
                  when isnull(ltrim(rtrim(t7.Address1)),'')+isnull(ltrim(rtrim(t7.Address2)),'')<>''   
                     then ltrim(rtrim(isnull(t7.Address1,'')))+ltrim(rtrim(isnull(t7.Address2,'')))+ltrim(rtrim(isnull(t7.Address3,'')))   
                  else ltrim(rtrim(isnull(t1.C_Address1,'')))+ltrim(rtrim(isnull(t1.C_Address2,'')))+ltrim(rtrim(isnull(t1.C_Address3,'')))   
               end  
             , t3.CartonNo  
             , t4.Style  
             , case   
                  when t1.stop='20'   
                     then ''   
                  else t4.Color   
               end  
             , t4.BUSR8  
             , t4.Size   
             , t4.Measurement  
             , t4.MANUFACTURERSKU  
             , t3.LabelNo   
             , case   
                  when len(t1.consigneekey)=7   
                     then ltrim(rtrim(t1.Billtokey))+ltrim(rtrim(t1.Consigneekey))   
                  else t1.Consigneekey   
               end  
             , Convert(char(10),DateAdd(Day,cast(t6.Short as int),t1.Editdate),121)  
             , t1.stop  
             , t4.SUSR5   
      --Order by t1.ExternOrderkey  
      --       , t3.CartonNo  
      --       , t4.Style  
      --       , case   
      --            when t1.stop='20'   
      --               then ''   
      --            else t4.Color   
      --         end  
      --       , t4.Size   
      )  
      BEGIN  
         SET @n_Err = 200001  
         SET @c_ErrMsg ='No records have been found! (isp_EXG_CNWMS_CONVERSE_PackList)'  
         SET @n_Continue = 3  
         GOTO QUIT  
      END  
   END  
  
   BEGIN TRAN  
   BEGIN TRY  
  
      -- Records exists start to insert column header and rows values into EXG_FileDet  
  
      IF @n_EXG_Hdr_ID = 1  
      BEGIN  
         INSERT INTO [CNWMSNKE].[dbo].[EXG_FileDet](  
              file_key  
            , EXG_Hdr_ID  
            , [FileName]  
            , SheetName  
            , [Status]  
            , LineText1)  
         SELECT  @n_FileKey  
            , @n_EXG_Hdr_ID   
            , @c_FileName  
            , @c_SheetName  
            , 'W'  
            , CONCAT(  
                  '"', [发货单号(Shipment Number)], '"', @c_Delimiter,   
                  '"', [PT号(PickShip Number)], '"', @c_Delimiter,   
                  '"', [订单号(SO Number)], '"', @c_Delimiter,   
                  '"', [发货日期(Shipped Date)], '"', @c_Delimiter,   
                  '"', [预计到货日期(ETA)], '"', @c_Delimiter,   
                  '"', [客户编号(Sold to Code)], '"', @c_Delimiter,   
                  '"', [收货单位(Ship to code)], '"', @c_Delimiter,   
                  '"', [客户名称(CustomerName)], '"', @c_Delimiter,   
                  '"', [送货地址(Ship to Address)], '"', @c_Delimiter,   
                  '"', [箱号(CartonNo)], '"', @c_Delimiter,   
                  '"', [款号(Style)], '"', @c_Delimiter,   
                  '"', [颜色(Color)], '"', @c_Delimiter,   
                  '"', [尺码(Size)], '"', @c_Delimiter,   
                  '"', [Material_Number], '"', @c_Delimiter,   
                  '"', [产品大类(SKUClass)], '"', @c_Delimiter,   
                  '"', [产品条码(Product barcode)], '"', @c_Delimiter,   
                  '"', [季节(Season Code)], '"', @c_Delimiter,   
                  '"', [发货数量(ShippedQty)], '"', @c_Delimiter,   
                  '"', [外箱条码(UCC)], '"', @c_Delimiter,   
                  '"', [Consigneekey], '"', @c_Delimiter,   
                  '"', [条码], '"') AS LineText1  
         FROM (  
            SELECT  
               N'发货单号(Shipment Number)' AS [发货单号(Shipment Number)]  
            ,  N'PT号(PickShip Number)' AS [PT号(PickShip Number)]  
            ,  N'订单号(SO Number)' AS [订单号(SO Number)]  
            ,  N'发货日期(Shipped Date)' AS [发货日期(Shipped Date)]  
            ,  N'预计到货日期(ETA)' AS [预计到货日期(ETA)]  
            ,  N'客户编号(Sold to Code)' AS [客户编号(Sold to Code)]  
            ,  N'收货单位(Ship to code)' AS [收货单位(Ship to code)]  
            ,  N'客户名称(CustomerName)' AS [客户名称(CustomerName)]  
            ,  N'送货地址(Ship to Address)' AS [送货地址(Ship to Address)]  
            ,  N'箱号(CartonNo)' AS [箱号(CartonNo)]  
            ,  N'款号(Style)' AS [款号(Style)]  
            ,  N'颜色(Color)' AS [颜色(Color)]  
            ,  N'尺码(Size)' AS [尺码(Size)]  
            ,  N'Material_Number' AS [Material_Number]  
            ,  N'产品大类(SKUClass)' AS [产品大类(SKUClass)]  
            ,  N'产品条码(Product barcode)' AS [产品条码(Product barcode)]  
            ,  N'季节(Season Code)' AS [季节(Season Code)]  
            ,  N'发货数量(ShippedQty)' AS [发货数量(ShippedQty)]  
            ,  N'外箱条码(UCC)' AS [外箱条码(UCC)]  
            ,  N'Consigneekey' AS [Consigneekey]  
            ,  N'条码' AS [条码]) AS TEMP1  
  
      INSERT INTO [CNWMSNKE].[dbo].[EXG_FileDet](  
              file_key  
            , EXG_Hdr_ID  
            , [FileName]  
            , SheetName  
            , [Status]  
            , LineText1)  
         SELECT  @n_FileKey  
            , @n_EXG_Hdr_ID   
            , @c_FileName  
            , @c_SheetName  
            , 'W'  
            , CONCAT(  
                  '"',[发货单号(Shipment Number)], '"', @c_Delimiter,   
                  '"', [PT号(PickShip Number)], '"', @c_Delimiter,   
                  '"', [订单号(SO Number)], '"', @c_Delimiter,   
      '"', [发货日期(Shipped Date)], '"', @c_Delimiter,   
                  '"', [预计到货日期(ETA)], '"', @c_Delimiter,   
                  '"', [客户编号(Sold to Code)], '"', @c_Delimiter,   
                  '"', [收货单位(Ship to code)], '"', @c_Delimiter,   
                  '"', [客户名称(CustomerName)], '"', @c_Delimiter,   
                  '"', [送货地址(Ship to Address)], '"', @c_Delimiter,   
                  '"', [箱号(CartonNo)], '"', @c_Delimiter,   
                  '"', [款号(Style)], '"', @c_Delimiter,   
                  '"', [颜色(Color)]  , '"', @c_Delimiter,   
                  '"', [尺码(Size)]  , '"', @c_Delimiter,   
                  '"', [Material_Number]  , '"', @c_Delimiter,   
                  '"', [产品大类(SKUClass)]  , '"', @c_Delimiter,   
                  '"', [产品条码(Product barcode)]  , '"', @c_Delimiter,   
                  '"', [季节(Season Code)]  , '"', @c_Delimiter,   
                  '"', [发货数量(ShippedQty)]  , '"', @c_Delimiter,   
                  '"', [外箱条码(UCC)]  , '"', @c_Delimiter,   
                  '"', [Consigneekey]  , '"', @c_Delimiter,   
                  '"', [条码]   , '"') AS LineText1  
         FROM (   
         Select   t1.Mbolkey as [发货单号(Shipment Number)]  
               ,  t1.ExternOrderkey as [PT号(PickShip Number)]  
               ,  t1.BuyerPO as [订单号(SO Number)]  
               ,  Convert(char(10),t1.Editdate,121) as [发货日期(Shipped Date)]  
               ,  Convert(char(10),DateAdd(Day,cast(t6.Short as int),t1.Editdate),121) as [预计到货日期(ETA)]  
               ,  t1.Billtokey as [客户编号(Sold to Code)]  
               ,  t1.Consigneekey as [收货单位(Ship to code)]  
               ,  case when isnull(t7.Company,'')<>''   
                     then t7.Company   
                     else t1.C_Company   
                  end as [客户名称(CustomerName)]  
               ,  case when isnull(ltrim(rtrim(t7.Address1)),'')+isnull(ltrim(rtrim(t7.Address2)),'')<>''   
                     then ltrim(rtrim(isnull(t7.Address1,'')))+ltrim(rtrim   (isnull(t7.Address2,'')))+ltrim(rtrim(isnull(t7.Address3,'')))   
                     else ltrim(rtrim(isnull(t1.C_Address1,'')))+ltrim(rtrim(isnull    (t1.C_Address2,'')))+ltrim(rtrim(isnull(t1.C_Address3,'')))   
                  end as [送货地址(Ship to Address)]  
               ,  t3.CartonNo as [箱号(CartonNo)]  
             ,  t4.Style as [款号(Style)]  
               ,  case when t1.stop='20'   
                     then ''   
                     else t4.Color   
                  end as [颜色(Color)]    
               --case when left(ltrim(rtrim(t4.size)),1)='0'   
               --then cast(cast(cast(t4.Size as int) as float)/10 as varchar(5))   
               --else t4.Size   
               --end as [尺码(Size)], t1.stop as [产品大类(SKUClass)],   
              -- ,  case   
              --       when t4.size = '00'   
              --          then t4.size   
              -- when left(ltrim(rtrim(t4.size)),1)='0' and t4.size <> '00'   
              --          then cast(cast(cast(t4.Size as int) as float)/10 as varchar(5))    
              -- when (t4.measurement ='' or t4.measurement = 'U')   
              --          then t4.Size   
              --    else t4.measurement   
              --end as [尺码(Size)]  
               ,  case   
                     when t4.BUSR8='10' AND ISNULL(t4.measurement,'') <> '' then t4.measurement  
                   when t4.BUSR8='10' AND ISNULL(t4.measurement,'') = ''  then t4.size   
               when left(ltrim(rtrim(t4.size)),1)='0' and t4.size <> '00' then cast(cast(cast(t4.Size as int) as float)/10 as varchar(5))    
               when (t4.measurement ='' or t4.measurement = 'U') then t4.Size   
               else t4.measurement   
              end as [尺码(Size)]  
             ,  t8.Userdefine09 as Material_Number  
               ,  t1.stop as [产品大类(SKUClass)]  
               ,  case   
                     when isnull(t3.UPC,'')<>'' and len(t3.UPC)<=17 and t3.UPC<>t3.SKU   
                        then t3.UPC    
                     when isnull(t4.ProductModel,'')='G' and len(t3.UPC)=20   
                        then ltrim(rtrim(t4.RetailSKU))+ ltrim(rtrim(isnull(t5.Userdefined03,'')))    
                     when isnull(t4.ProductModel,'')<>'G' and len(t3.UPC)=20 and isnull(t4.RetailSKU,'')<>''   
                        then t4.RetailSKU   
                     when isnull(t4.ProductModel,'')<>'G' and t3.UPC=t3.SKU and isnull(t4.RetailSKU,'')<>''   
                        then t4.RetailSKU   
                     when isnull(t4.ProductModel,'')<>'G' and len(t3.UPC)=20 and isnull(t4.MANUFACTURERSKU,'')<>''   
                        then t4.MANUFACTURERSKU   
                     when isnull(t4.ProductModel,'')<>'G' and t3.UPC=t3.SKU and isnull(t4.MANUFACTURERSKU,'')<>''   
                        then t4.MANUFACTURERSKU   
                        else ltrim(rtrim(t4.AltSKU))+left(ltrim(rtrim(t4.BUSR3)),2)+ (case right(ltrim(rtrim(t4.BUSR3)),1) when 'S' then '01' when 'R' then '02' when 'F' then '03' when 'H' then '04' end)    
                  end as [产品条码(Product barcode)]  
               ,  case   
                  --when t4.ProductModel='G' and len(t3.UPC)<=17 then right(ltrim(rtrim(t3.UPC)),4)    
                  --when t4.ProductModel='G' and len(t3.UPC)=20 then ltrim(rtrim(t5.Userdefined03))   
                     when isnull(t8.Userdefine06,'')<>'' and left(ltrim(rtrim(t8.Userdefine06)),1) not in('S','R','F','H')  
                        then left(ltrim(rtrim(t8.Userdefine06)),2)+ (case right(ltrim(rtrim(t8.Userdefine06)),1) when 'S' then '01' when 'R' then '02' when 'F' then '03' when 'H' then '04' end)    
                     when isnull(t8.Userdefine06,'')<>'' and left(ltrim(rtrim(t8.Userdefine06)),2) in('SP','SU','FA','HO')   
                        then right(ltrim(rtrim(t8.Userdefine06)),2)+ (case left(ltrim(rtrim(t8.Userdefine06)),2) when 'SP' then '01' when 'SU' then '02' when 'FA' then '03' when 'HO' then '04' end)    
                        else left(ltrim(rtrim(t4.BUSR3)),2)+ (case right(ltrim(rtrim(t4.BUSR3)),1) when 'S' then '01' when 'R' then '02' when 'F' then '03' when 'H' then '04' end)   
                  end as [季节(Season Code)]  
               ,  SUM ( t3.Qty ) as [发货数量(ShippedQty)]  
               ,  t3.LabelNo as [外箱条码(UCC)]  
               ,  case   
                     when len(t1.consigneekey)=7   
                        then ltrim(rtrim(t1.Billtokey))+ltrim(rtrim(t1.Consigneekey))   
                        else t1.Consigneekey   
                     end as Consigneekey  
               ,  '*'+ t3.LabelNo +'*'  AS [条码] -- add by ella 1/19  
      From CNWMSNKE..Orders as t1(nolock)   
      inner join CNWMSNKE..PackHeader as t2(nolock) on t1.Orderkey=t2.Orderkey and t2.status='9'   
      inner join CNWMSNKE..PackDetail as t3(nolock) on t2.Pickslipno=t3.Pickslipno   
         inner join (select Distinct storerkey,Orderkey,SKU, userdefine06,Userdefine09   
                  from CNWMSNKE..Orderdetail(nolock)   
                     where Storerkey=@c_ParamVal1) as t8 on t2.Orderkey=t8.Orderkey and t3.SKU=t8.SKU    
      inner join CNWMSNKE..SKU as t4(nolock) on t3.Storerkey=t4.Storerkey and t3.SKU=t4.SKU   
      left  join CNWMSNKE..UCC as t5(nolock) on t3.Storerkey=t5.Storerkey and t3.SKU=t5.SKU and t3.UPC=t5.UCCNo   
      left  join CNWMSNKE..Storer as t7(nolock) on ltrim(rtrim(t1.Billtokey))+ltrim(rtrim(t1.Consigneekey))=t7.Storerkey   
      --left  join CNWMSNKE..Codelkup as t6(nolock) on t6.ListName='CityLdTime' and cast(t6.Notes as varchar(20))='Converse' and (case when len(t1.Consigneekey)=10 and t1.Consigneekey=t6.code then 1 when len(t1.Consigneekey)=7 and ltrim(rtrim(t1.Billtokey))+ltrim(rtrim(t1.Consigneekey))=t6.Code then 1 else 0 end)=1   
      left  join CNWMSNKE..Codelkup as t6(nolock) on t6.ListName='CityLdTime' and cast(t6.Notes as varchar(20))=@c_ParamVal1 and t1.Consigneekey = t6.code   
         Where t1.Mbolkey = @c_ParamVal2 and t1.Consigneekey = @c_ParamVal3 and t1.Status in('5','9')    
         Group by t1.Mbolkey  
               ,  t1.ExternOrderkey   
               ,  t1.BuyerPO  
               ,  Convert(char(10),t1.Editdate,121)   
               ,  t1.Billtokey   
               ,  t1.Consigneekey  
               ,  case   
                     when isnull(t7.Company,'')<>''   
                        then t7.Company   
                        else t1.C_Company   
                  end   
               ,  case   
                     when isnull(ltrim(rtrim(t7.Address1)),'')+isnull(ltrim(rtrim(t7.Address2)),'')<>''   
                        then ltrim(rtrim(isnull(t7.Address1,'')))+ltrim(rtrim(isnull(t7.Address2,'')))+ltrim(rtrim(isnull(t7.Address3,'')))   
                        else ltrim(rtrim(isnull(t1.C_Address1,'')))+ltrim(rtrim(isnull(t1.C_Address2,'')))+ltrim(rtrim(isnull(t1.C_Address3,'')))   
                  end  
               ,  t3.CartonNo  
               ,  t4.Style  
               ,  case   
                     when t1.stop='20'   
                        then ''   
                        else t4.Color   
                  end  
               ,  case   
                     when t4.BUSR8='10' AND ISNULL(t4.measurement,'') <> '' then t4.measurement  
                   when t4.BUSR8='10' AND ISNULL(t4.measurement,'') = ''  then t4.size   
               when left(ltrim(rtrim(t4.size)),1)='0' and t4.size <> '00' then cast(cast(cast(t4.Size as int) as float)/10 as varchar(5))    
               when (t4.measurement ='' or t4.measurement = 'U') then t4.Size   
               else t4.measurement   
              end   
               ,  t4.Measurement  
               ,  case   
                     when isnull(t3.UPC,'')<>'' and len(t3.UPC)<=17 and t3.UPC<>t3.SKU   
                        then t3.UPC    
                     when isnull(t4.ProductModel,'')='G' and len(t3.UPC)=20   
                        then ltrim(rtrim(t4.RetailSKU))+ ltrim(rtrim(isnull(t5.Userdefined03,'')))    
                     when isnull(t4.ProductModel,'')<>'G' and len(t3.UPC)=20 and isnull(t4.RetailSKU,'')<>''   
                        then t4.RetailSKU   
                     when isnull(t4.ProductModel,'')<>'G' and t3.UPC=t3.SKU and isnull(t4.RetailSKU,'')<>''   
                        then t4.RetailSKU   
                     when isnull(t4.ProductModel,'')<>'G' and len(t3.UPC)=20 and isnull(t4.MANUFACTURERSKU,'')<>''   
                        then t4.MANUFACTURERSKU   
                     when isnull(t4.ProductModel,'')<>'G' and t3.UPC=t3.SKU and isnull(t4.MANUFACTURERSKU,'')<>''   
                        then t4.MANUFACTURERSKU   
                        else ltrim(rtrim(t4.AltSKU))+left(ltrim(rtrim(t4.BUSR3)),2)+ (case right(ltrim(rtrim(t4.BUSR3)),1) when 'S' then '01' when 'R' then '02' when 'F' then '03' when 'H' then '04' end)    
                  end  
               ,  case --when t4.ProductModel='G' and len(t3.UPC)<=17 then right(ltrim(rtrim(t3.UPC)),4)    
                  --when t4.ProductModel='G' and len(t3.UPC)=20 then ltrim(rtrim(t5.Userdefined03))   
                     when isnull(t8.Userdefine06,'')<>'' and left(ltrim(rtrim(t8.Userdefine06)),1) not in('S','R','F','H')  
                        then left(ltrim(rtrim(t8.Userdefine06)),2)+ (case right(ltrim(rtrim(t8.Userdefine06)),1) when 'S' then '01' when 'R' then '02' when 'F' then '03' when 'H' then '04' end)    
                     when isnull(t8.Userdefine06,'')<>'' and left(ltrim(rtrim(t8.Userdefine06)),2) in('SP','SU','FA','HO')   
                        then right(ltrim(rtrim(t8.Userdefine06)),2)+ (case left(ltrim(rtrim(t8.Userdefine06)),2) when 'SP' then '01' when 'SU' then '02' when 'FA' then '03' when 'HO' then '04' end)    
                        else left(ltrim(rtrim(t4.BUSR3)),2)+ (case right(ltrim(rtrim(t4.BUSR3)),1) when 'S' then '01' when 'R' then '02' when 'F' then '03' when 'H' then '04' end)  
                  end   
               ,  t3.LabelNo   
               ,  case   
                     when len(t1.consigneekey)=7   
                        then ltrim(rtrim(t1.Billtokey))+ltrim(rtrim(t1.Consigneekey))   
                       else t1.Consigneekey   
                  end  
               ,  Convert(char(10),DateAdd(Day,cast(t6.Short as int),t1.Editdate),121)  
               ,  t1.stop  
               ,  t8.userdefine09   
         Order by t1.ExternOrderkey  
               ,  t3.CartonNo  
               ,  t4.Style  
               ,  case   
                     when t1.stop='20'   
                        then ''   
                        else t4.Color   
                  end  
               ,  case   
                     when t4.BUSR8='10' AND ISNULL(t4.measurement,'') <> '' then t4.measurement  
                   when t4.BUSR8='10' AND ISNULL(t4.measurement,'') = ''  then t4.size   
               when left(ltrim(rtrim(t4.size)),1)='0' and t4.size <> '00' then cast(cast(cast(t4.Size as int) as float)/10 as varchar(5))    
               when (t4.measurement ='' or t4.measurement = 'U') then t4.Size   
               else t4.measurement   
              end    
               OFFSET 0 ROWS) AS TEMP2  
      END  
      ELSE IF @n_EXG_Hdr_ID = 3  
      BEGIN  
         INSERT INTO [CNWMSNKE].[dbo].[EXG_FileDet](  
              file_key  
            , EXG_Hdr_ID  
            , [FileName]  
            , SheetName  
            , [Status]  
            , LineText1)  
         SELECT  @n_FileKey  
            , @n_EXG_Hdr_ID   
            , @c_FileName  
            , @c_SheetName  
            , 'W'  
            , CONCAT(  
                  '"', [发货单号(Shipment Number)], '"', @c_Delimiter,   
                  '"', [PT号(PickShip Number)], '"', @c_Delimiter,   
                  --'"', [订单号(SO Number)], '"', @c_Delimiter,   
                  '"', [发货日期(Shipped Date)], '"', @c_Delimiter,   
                  '"', [预计到货日期(ETA)], '"', @c_Delimiter,   
                  --'"', [客户编号(Sold to Code)], '"', @c_Delimiter,   
                  '"', [收货单位(Ship to code)], '"', @c_Delimiter,   
                  '"', [客户名称(CustomerName)], '"', @c_Delimiter,   
                  '"', [送货地址(Ship to Address)], '"', @c_Delimiter,   
                  '"', [箱号(CartonNo)], '"', @c_Delimiter,   
                  '"', [款号(Style)], '"', @c_Delimiter,   
                  '"', [颜色(Color)], '"', @c_Delimiter,   
                  '"', [尺码(Size)], '"', @c_Delimiter,   
                  '"', [Material_Number], '"', @c_Delimiter,   
                  '"', [产品大类(SKUClass)], '"', @c_Delimiter,   
                  '"', [产品条码(Product barcode)], '"', @c_Delimiter,   
                  --'"', [季节(Season Code)], '"', @c_Delimiter,   
                  '"', [发货数量(ShippedQty)], '"', @c_Delimiter,   
                  '"', [外箱条码(UCC)], '"', @c_Delimiter,   
                  '"', [Consigneekey], '"', @c_Delimiter,   
                  '"', [条码], '"') AS LineText1  
         FROM (  
            SELECT  
               N'发货单号(Shipment Number)' AS [发货单号(Shipment Number)]  
            ,  N'PT号(PickShip Number)' AS [PT号(PickShip Number)]  
            --,  N'订单号(SO Number)' AS [订单号(SO Number)]  
            ,  N'发货日期(Shipped Date)' AS [发货日期(Shipped Date)]  
            ,  N'预计到货日期(ETA)' AS [预计到货日期(ETA)]  
            --,  N'客户编号(Sold to Code)' AS [客户编号(Sold to Code)]  
            ,  N'收货单位(Ship to code)' AS [收货单位(Ship to code)]  
            ,  N'客户名称(CustomerName)' AS [客户名称(CustomerName)]  
            ,  N'送货地址(Ship to Address)' AS [送货地址(Ship to Address)]  
            ,  N'箱号(CartonNo)' AS [箱号(CartonNo)]  
            ,  N'款号(Style)' AS [款号(Style)]  
            ,  N'颜色(Color)' AS [颜色(Color)]  
            ,  N'尺码(Size)' AS [尺码(Size)]  
            ,  N'Material_Number' AS [Material_Number]  
            ,  N'产品大类(SKUClass)' AS [产品大类(SKUClass)]  
            ,  N'产品条码(Product barcode)' AS [产品条码(Product barcode)]  
            --,  N'季节(Season Code)' AS [季节(Season Code)]  
            ,  N'发货数量(ShippedQty)' AS [发货数量(ShippedQty)]  
            ,  N'外箱条码(UCC)' AS [外箱条码(UCC)]  
            ,  N'Consigneekey' AS [Consigneekey]  
            ,  N'条码' AS [条码]) AS TEMP1  
  
         INSERT INTO [CNWMSNKE].[dbo].[EXG_FileDet](  
           file_key  
            , EXG_Hdr_ID  
            , [FileName]  
            , SheetName  
            , [Status]  
            , LineText1)  
         SELECT  @n_FileKey  
            , @n_EXG_Hdr_ID   
            , @c_FileName  
            , @c_SheetName  
            , 'W'  
            , CONCAT(  
                  '"',[发货单号(Shipment Number)], '"', @c_Delimiter,   
                  '"', [PT号(PickShip Number)], '"', @c_Delimiter,   
                  --'"', [订单号(SO Number)], '"', @c_Delimiter,   
                  '"', [发货日期(Shipped Date)], '"', @c_Delimiter,   
                  '"', [预计到货日期(ETA)], '"', @c_Delimiter,   
                  --'"', [客户编号(Sold to Code)], '"', @c_Delimiter,   
                  '"', [收货单位(Ship to code)], '"', @c_Delimiter,   
                  '"', [客户名称(CustomerName)], '"', @c_Delimiter,   
                  '"', [送货地址(Ship to Address)], '"', @c_Delimiter,   
                  '"', [箱号(CartonNo)], '"', @c_Delimiter,   
                  '"', [款号(Style)], '"', @c_Delimiter,   
                  '"', [颜色(Color)]  , '"', @c_Delimiter,   
                  '"', [尺码(Size)]  , '"', @c_Delimiter,   
                  '"', [Material_Number]  , '"', @c_Delimiter,   
                  '"', [产品大类(SKUClass)]  , '"', @c_Delimiter,   
                  '"', [产品条码(Product barcode)]  , '"', @c_Delimiter,   
                  --'"', [季节(Season Code)]  , '"', @c_Delimiter,   
                  '"', [发货数量(ShippedQty)]  , '"', @c_Delimiter,   
                  '"', [外箱条码(UCC)]  , '"', @c_Delimiter,   
                  '"', [Consigneekey]  , '"', @c_Delimiter,   
                  '"', [条码]   , '"') AS LineText1  
         FROM (   
            Select   t1. Mbolkey as [发货单号(Shipment Number)]  
                   , t1.ExternOrderkey as [PT号(PickShip Number)]  
                   , Convert(char(10),t1.Editdate,121) as [发货日期(Shipped Date)]  
                   , Convert(char(10),DateAdd(Day,cast(t6.Short as int),t1.Editdate),121) as [预计到货日期(ETA)]  
                   , t1.Consigneekey as [收货单位(Ship to code)]  
                   , case   
                        when isnull(t7.Company,'')<>''   
                           then t7.Company   
                        else t1.C_Company   
                     end as [客户名称(CustomerName)]  
                   , case   
                        when isnull(ltrim(rtrim(t7.Address1)),'')+isnull(ltrim(rtrim(t7.Address2)),'')<>''   
                           then ltrim(rtrim(isnull(t7.Address1,'')))+ltrim(rtrim(isnull(t7.Address2,'')))+ltrim(rtrim(isnull(t7.Address3,'')))   
                        else ltrim(rtrim(isnull(t1.C_Address1,'')))+ltrim(rtrim(isnull(t1.C_Address2,'')))+ltrim(rtrim(isnull(t1.C_Address3,'')))   
                     end as [送货地址(Ship to Address)]  
                   , t3.CartonNo as [箱号(CartonNo)]  
                   , t4.Style as [款号(Style)]  
                   , case   
                        when t1.stop='20'   
                           then ''   
                        else t4.Color   
                     end as [颜色(Color)]  
                   , case   
                        when t4.BUSR8='10' AND ISNULL(t4.measurement,'') <>''   
                           then t4.measurement  
                    when t4.BUSR8='10' AND ISNULL(t4.measurement,'') =''   
                           then t4.size  
                    when left(ltrim(rtrim(t4.size)),1)='0' and t4.size <> '00'   
                           then cast(cast(cast(t4.Size as int) as float)/10 as varchar(5))    
                    when (t4.measurement ='' or t4.measurement = 'U')   
                           then t4.Size   
                        else t4.measurement   
                     end as [尺码(Size)]  
                   , t4.SUSR5 AS Material_Number  
                   , t1.stop as [产品大类(SKUClass)]  
                   , t4.MANUFACTURERSKU AS [产品条码(Product barcode)]  
                   , SUM ( t3.Qty ) as [发货数量(ShippedQty)]  
                   , t3.LabelNo as [外箱条码(UCC)]  
                   , case   
 when len(t1.consigneekey)=7   
                           then ltrim(rtrim(t1.Billtokey))+ltrim(rtrim(t1.Consigneekey))   
                        else t1.Consigneekey   
                     end as Consigneekey  
                   , '*'+ t3.LabelNo +'*'  AS [条码]       
            From  CNWMSNKE..Orders as t1(nolock)   
            inner join CNWMSNKE..PackHeader as t2(nolock) on t1.Orderkey=t2.Orderkey and t2.status='9'   
            inner join CNWMSNKE..PackDetail as t3(nolock) on t2.Pickslipno=t3.Pickslipno   
            inner join CNWMSNKE..SKU as t4(nolock) on t3.Storerkey=t4.Storerkey and t3.SKU=t4.SKU   
            left  join CNWMSNKE..UCC as t5(nolock) on t3.Storerkey=t5.Storerkey and t3.SKU=t5.SKU and t3.UPC=t5.UCCNo   
            left  join CNWMSNKE..Storer as t7(nolock) on ltrim(rtrim(t1.Billtokey))+ltrim(rtrim(t1.Consigneekey))=t7.Storerkey   
            left  join CNWMSNKE..Codelkup as t6(nolock) on t6.ListName='CityLdTime' and cast(t6.Notes as varchar(20))='Converse' and t1.Consigneekey = t6.code   
            Where t1.Mbolkey=@c_ParamVal2 and t1.Consigneekey = @c_ParamVal3 and t1.Status in('5','9')    
            Group by t1. Mbolkey  
                   , t1.ExternOrderkey   
                   , Convert(char(10),t1.Editdate,121)   
                   , t1.Consigneekey  
                   , case   
                        when isnull(t7.Company,'')<>''   
                           then t7.Company   
                        else t1.C_Company   
                     end   
                   , case   
                        when isnull(ltrim(rtrim(t7.Address1)),'')+isnull(ltrim(rtrim(t7.Address2)),'')<>''   
                           then ltrim(rtrim(isnull(t7.Address1,'')))+ltrim(rtrim(isnull(t7.Address2,'')))+ltrim(rtrim(isnull(t7.Address3,'')))   
                        else ltrim(rtrim(isnull(t1.C_Address1,'')))+ltrim(rtrim(isnull(t1.C_Address2,'')))+ltrim(rtrim(isnull(t1.C_Address3,'')))   
                     end  
                   , t3.CartonNo  
                   , t4.Style  
                   , case   
                        when t1.stop='20'   
                           then ''   
                        else t4.Color   
                     end  
                   , t4.BUSR8  
                   , t4.Size   
                   , t4.Measurement  
                   , t4.MANUFACTURERSKU  
                   , t3.LabelNo   
                   , case   
                        when len(t1.consigneekey)=7   
                           then ltrim(rtrim(t1.Billtokey))+ltrim(rtrim(t1.Consigneekey))   
                        else t1.Consigneekey   
                     end  
                   , Convert(char(10),DateAdd(Day,cast(t6.Short as int),t1.Editdate),121)  
                   , t1.stop  
                   , t4.SUSR5   
            Order by t1.ExternOrderkey  
                   , t3.CartonNo  
                   , t4.Style  
                   , case   
                        when t1.stop='20'   
                           then ''   
                        else t4.Color   
                     end  
                   , t4.Size  
         OFFSET 0 ROWS) AS TEMP2  
      END  
   END TRY  
   BEGIN CATCH  
      SET @n_Err = ERROR_NUMBER();  
      SET @c_ErrMsg = ERROR_MESSAGE() + ' (isp_EXG_CNWMSNKE_CONVERSE_PackList)'  
      SET @n_Continue = 3  
   END CATCH  
  
   QUIT:  
   WHILE @@TRANCOUNT > 0  
      COMMIT TRAN  
  
   WHILE @@TRANCOUNT < @n_StartTCnt        
      BEGIN TRAN   
  
   IF @n_Continue=3  -- Error Occured - Process And Return        
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
  
      IF @b_Debug = 1  
      BEGIN  
         PRINT '[dbo].[isp_EXG_CNWMSNKE_CONVERSE_PackList]: @c_ErrMsg=' + RTRIM(@c_ErrMsg)  
         PRINT '[dbo].[isp_EXG_CNWMSNKE_CONVERSE_PackList]: @b_Success=' + RTRIM(CAST(@b_Success AS NVARCHAR(10)))  
      END  
  
      RETURN        
   END        
   ELSE        
   BEGIN  
      IF ISNULL(RTRIM(@c_ErrMsg), '') <> ''  
      BEGIN  
         SELECT @b_Success = 0  
      END  
      ELSE  
      BEGIN   
         SELECT @b_Success = 1   
      END          
  
      WHILE @@TRANCOUNT > @n_StartTCnt        
      BEGIN        
         COMMIT TRAN        
      END       
        
      IF @b_Debug = 1  
      BEGIN  
         PRINT '[dbo].[isp_EXG_CNWMSNKE_CONVERSE_PackList]: @c_ErrMsg=' + RTRIM(@c_ErrMsg)  
         PRINT '[dbo].[isp_EXG_CNWMSNKE_CONVERSE_PackList]: @b_Success=' + RTRIM(CAST(@b_Success AS NVARCHAR(10)))  
      END        
      RETURN        
   END          
   /***********************************************/        
   /* Std - Error Handling (End)                  */        
   /***********************************************/  
END --End Procedure  
  
  
  