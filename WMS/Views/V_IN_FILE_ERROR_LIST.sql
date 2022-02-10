SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
USE [INWMS]
GO

--/****** Object:  View [dbo].[V_IN_FILE_ERROR_LIST]    Script Date: 6/11/2018 10:13:27 AM ******/
--SET ANSI_NULLS ON
--GO

--SET QUOTED_IDENTIFIER ON
--GO
----drop view V_IN_FILE_ERROR_LIST
----grant view V_IN_FILE_ERROR_LIST 
---- select top 10000 * from [V_IN_FILE_ERROR_LIST]
--CREATE VIEW [dbo].[V_IN_FILE_ERROR_LIST]
--AS*/

CREATE VIEW [dbo].[V_IN_FILE_ERROR_LIST]
AS

 select --top 1000
       --distinct --top 10 
	   ITFCFG.descr ,
       InLine.File_key , InLine.DataStream , 
	   --InLine.FileName , 
	   case when CHARINDEX('_',InLine.Filename) > 0
            then right( replace(InLine.Filename,'.txt','.xml') , len(InLine.Filename) - CHARINDEX('_',InLine.Filename))
            else InLine.filename
       end [FileName] , 
	   Case 
	        when charIndex('NSQL68032' , InLine.ErrMsg ) > 0 -- NSQL68030 - IBS failure , IBD missing.
			     AND charIndex('Non-existent of IBD' , InLine.ErrMsg ) > 0
			     Then 'IBS Importing failure: IBS ' + Rtrim(Isnull(Pur.UserDefine09,'')) + ' Missing IBD ' + Rtrim(IsNull(Pur.UserDefine05,'')) 
			/*
			when charIndex('NSQL68042' , InLine.ErrMsg ) > 0 -- NSQL68040 - IBD failure , SKU missing.
			     AND charIndex('limitation' , InLine.ErrMsg ) > 0 
			     Then 'IBD Importing failure  , IBD ' + Rtrim(IsNull(Pur.UserDefine05,'')) + ' Missing SKU ' + Rtrim(IsNull(Pur.Sku,''))
			*/
			/*
			when charIndex('NSQL68019' , InLine.ErrMsg ) > 0 -- NSQL68019 - IBS failure , PO Closed.
	             Then 'IBS Importing rejected , IBS ' + Rtrim(Pur.UserDefine09) + ' IBD ' + Rtrim(Pur.UserDefine05) + ' has been Received & Closed'
	        when charIndex('NSQL68020' , InLine.ErrMsg ) > 0 -- NSQL68020 - IBS failure , Received.
			     Then 'IBS Importing rejected , IBS ' + Rtrim(Pur.UserDefine09) + ' for IBD ' + Rtrim(Pur.UserDefine05) + ' has been process in WMS'
			when charIndex('NSQL68028' , InLine.ErrMsg ) > 0 -- NSQL68028 - IBD failure , PO Closed
			     Then 'IBD Importing rejected , IBD ' + Rtrim(Pur.UserDefine05) + ' has been Received & Closed'
			
			when charIndex('NSQL68031' , InLine.ErrMsg ) > 0 -- NSQL68031 - IBS failure , IBS existed.
			  or charIndex('NSQL68020' , InLine.ErrMsg ) > 0 -- NSQL68020 - IBS failure , Received.
			     Then 'IBS Importing rejected , IBS ' + Rtrim(Pur.UserDefine09) + ' already existed in IBD ' + Rtrim(Pur.UserDefine05) 
				 --Then ''
			*/
			--when CHARINDEX('NSQL68032' , InLine.ErrMsg ) > 0
			--     Then 'IBS Importing rejected , IBS ' + Rtrim(Pur.UserDefine09) + ' cannot append to IBD ' + Rtrim(Pur.UserDefine05) + ' (maximum for 2 IBS)'
		    when InLine.FileName like 'WMSORD_I215_%' and CharIndex('Failed. SKU:' , InLine.ErrMsg ) > 0
			     Then 'Customer Order Importing failure: Order ' + Rtrim(isnull(So.ExternOrderKey,'')) + ' Missing SKU ' + Rtrim(Isnull(So.Sku,''))
			else ErrMsg
	   End [ErrMsgs] ,
	   --InLine.ErrMsg [ErrMsg_Org] , 
	   --InLine.LineTextUnicode ,
	   InLine.addDate
	   --format(InLine.addDate,'dd/MM/yyyy') [Date] 
  from INDTSITF..itfconfig(nolock) ITFCFG
  join INDTSITF..in_line(nolock) InLine
    on ITFCFG.descr like '%H_M%' 
   and ITFCFG.DataStream = InLine.DataStream
  left join INDTSITF..V_0000_GENERIC_PUR_DET_UNICODE(nolock) Pur
    on InLine.File_Key = Pur.File_Key
   and InLine.DataStream = Pur.DataStream
   and InLine.SeqNo = Pur.SeqNo
  left join INDTSITF..V_0000_GENERIC_ORD_DET_UNICODE(nolock) SO
    on InLine.File_Key = So.File_Key
   and InLine.SeqNo = So.SeqNo
   and InLine.DataStream = So.DataStream
 where IsNull(InLine.errmsg,'') <> '' 
   and InLine.Status = '5'
   and InLine.errmsg not like '<WARNING>%'
   AND SUBSTRING( InLine.LineTextUnicode , 4 , 1 ) = 'D'
   --and InLine.errmsg not like 'NSQL68022:Import Ext. POKey:  Failed. Invalid ActionFlag for Delete. PO had been received. %'
   /*
   and left(InLine.errmsg,9) not in ('NSQL68031', -- I7 Update IBD , but IBD already exist in PODetail
                                     'NSQL68020', -- I7 update IBD , but IBD Exist in RECEITDETAIL.
									 'NSQL68019'  -- I7 update IBD , but PO closed.
									) */
   --and InLine.filename like '%.csv'
   --and left(INLine.ErrMsg , 9 ) in ('NSQL68032')
   --and InLine.errmsg like 'NSQL68032%'
   and InLine.addDate between 
        dateadd( day , -1 , cast( convert(char(10) , getdate() ,121) + ' ' + '00:00' as DATETIME ) ) and
        dateadd( day , -1 , cast( convert(char(10) , getdate() ,121) + ' ' + '23:59' as DATETIME ) )
   /*
   select top 10000 filename , dataStream , ErrMsg from INdtsitf..in_line(nolock) where errmsg <> '' and dataStream not in ('1541') and errmsg like 'NSQL68032%'
   select top 100 * from INDTSITF..in_line(nolock) where file_key  = 6646975
   select top 100 * from INDTSITF..V_0000_GENERIC_PUR_DET_UNICODE(nolock)
   */
  --sp_grep '68032'
  --sp_helptext 'NSQL68032: Import UserDefine01 : 1005099804 Failed. Non-existent of IBD (UserDefine01) : 1005099804 for IBS (UserDefine09): 1000241273Seq#: 34678918. (isp2835P_RG_HM_PO_Import)'
  --sp_helptext 'isp2835P_RG_HM_PO_Import'

  /*
select --distinct
       --top 100 	   
	   IN_LINE.file_key , IN_LINE.SeqNo , PO.PoKey , PUR.UserDefine05 , PUR.UserDefine09
       /*IN_LINE.file_key , IN_LINE.SeqNo , IN_LINE.FileName , 
       PUR.UserDefine05 , PUR.UserDefine09 , 
	   PO.PoKey , PO.UserDefine01 , PO.UserDefine02 , PO.UserDefine03 , 
	   IN_LINE.errMsg , IN_LINE.Adddate*/
  from INdtsitf..in_line(nolock) IN_LINE
  JOIN INDTSITF..V_0000_GENERIC_PUR_DET_UNICODE(nolock) PUR
    ON IN_LINE.file_key = PUR.file_key
   AND IN_LINE.SeqNo = PUR.SeqNo
  JOIN INwms..PO(nolock) PO
    --ON PO.StorerKey = @strStorerKey
	ON PO.StorerKey = 'HM'
   AND PO.UserDefine01 = PUR.UserDefine05
   AND PO.UserDefine02 = ''
   AND PO.Status = '0'
 where IN_LINE.status = '5' 
   and --ErrMsg like 'NSQL68030:%'
       charIndex('NSQL68032' , IN_LINE.ErrMsg ) > 0 -- NSQL68032 - IBS failure , IBD missing.
   AND charIndex('Non-existent of IBD' , IN_LINE.ErrMsg ) > 0
   AND SUBSTRING( IN_LINE.LineTextUnicode , 4 , 1 ) = 'D'


*/
GO
GRANT DELETE ON  [dbo].[V_IN_FILE_ERROR_LIST] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_IN_FILE_ERROR_LIST] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_IN_FILE_ERROR_LIST] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_IN_FILE_ERROR_LIST] TO [NSQL]
GO
