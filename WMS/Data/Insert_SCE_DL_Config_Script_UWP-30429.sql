DECLARE @n_WebApiConfigID_inserted			INT           = 0

DECLARE @t_WebApiConfigID_INSERTED TABLE   (SEQ INT)

INSERT SCE_DLWebApiConfig (
      [OperationType]
      ,[Application]
      ,[Environment]
      ,[Country]
      ,[TgtServer]
      ,[TgtDatabase]
      ,[URL]
      ,[ColumnMapURL])
OUTPUT INSERTED.WebApiConfigID INTO @t_WebApiConfigID_INSERTED
VALUES
	  (
		'SCE_DL_LB_CLIENT_MASTER'
		,'BILLING'
		,'STG'
		,'GBR'
		,'billing1'
		,'SCEBILLING'
		,'/sceapi/EUR/SCEBILL/GenericRequest/SCE_DL_Generic_BILLING'
		,'/sceapi/EUR/SCEBILL/GenericRequest/SCE_DLColumnMap_Inq'
	  )
	  
SELECT @n_WebApiConfigID_inserted = SEQ FROM @t_WebApiConfigID_INSERTED

INSERT SCE_DLSubRuleDict_Hdr (
      [WebApiConfigID]
      ,[Flag]
      ,[Code]
      ,[Step]
      ,[SubRuleSP]
      ,[IsActive]
      ,[Descr])
OUTPUT INSERTED.WebApiConfigID INTO @t_WebApiConfigID_INSERTED
VALUES
	  (
		@n_WebApiConfigID_inserted
		,'1'
		,'CLIENT_RULES_100001'
		,'10'
		,'isp_SCE_DL_GENERIC_CLIENT_MASTER_100001_10'
		,'1'
		,'Perform data validation'
	  )

INSERT SCE_DLSubRuleDict_Hdr (
      [WebApiConfigID]
      ,[Flag]
      ,[Code]
      ,[Step]
      ,[SubRuleSP]
      ,[IsActive]
      ,[Descr])
OUTPUT INSERTED.WebApiConfigID INTO @t_WebApiConfigID_INSERTED
VALUES
	  (
		@n_WebApiConfigID_inserted
		,'2'
		,'CLIENT_RULES_200001'
		,'20'
		,'isp_SCE_DL_GENERIC_CLIENT_MASTER_200001_10'
		,'1'
		,'INSERT data to main table'
	  )

INSERT SCE_DLModule (
      [WebApiConfigID]
      ,[STG_TBLName]
      ,[POST_TBLName])
OUTPUT INSERTED.WebApiConfigID INTO @t_WebApiConfigID_INSERTED
VALUES
	  (
		@n_WebApiConfigID_inserted
		,'dbo.[LB_CLIENT_MASTER_STG_STG]'
		,'dbo.[LB_CLIENT_MASTER_STG]'
	  )

-- Remove Unique ID
DELETE FROM @t_WebApiConfigID_INSERTED;

INSERT SCE_DLWebApiConfig (
      [OperationType]
      ,[Application]
      ,[Environment]
      ,[Country]
      ,[TgtServer]
      ,[TgtDatabase]
      ,[URL]
      ,[ColumnMapURL])
OUTPUT INSERTED.WebApiConfigID INTO @t_WebApiConfigID_INSERTED
VALUES
	  (
		'SCE_DL_LB_CLIENT_MASTER'
		,'BILLING'
		,'CDT'
		,'CHL'
		,'billing1'
		,'SCEBILLING'
		,'/sceapi/EUR/SCEBILL/GenericRequest/SCE_DL_Generic_BILLING'
		,'/sceapi/EUR/SCEBILL/GenericRequest/SCE_DLColumnMap_Inq'
	  )

SELECT @n_WebApiConfigID_inserted = SEQ FROM @t_WebApiConfigID_INSERTED

INSERT SCE_DLSubRuleDict_Hdr (
      [WebApiConfigID]
      ,[Flag]
      ,[Code]
      ,[Step]
      ,[SubRuleSP]
      ,[IsActive]
      ,[Descr])
OUTPUT INSERTED.WebApiConfigID INTO @t_WebApiConfigID_INSERTED
VALUES
	  (
		@n_WebApiConfigID_inserted
		,'1'
		,'CLIENT_RULES_100001'
		,'10'
		,'isp_SCE_DL_GENERIC_CLIENT_MASTER_100001_10'
		,'1'
		,'Perform data validation'
	  )

INSERT SCE_DLSubRuleDict_Hdr (
      [WebApiConfigID]
      ,[Flag]
      ,[Code]
      ,[Step]
      ,[SubRuleSP]
      ,[IsActive]
      ,[Descr])
OUTPUT INSERTED.WebApiConfigID INTO @t_WebApiConfigID_INSERTED
VALUES
	  (
		@n_WebApiConfigID_inserted
		,'2'
		,'CLIENT_RULES_200001'
		,'20'
		,'isp_SCE_DL_GENERIC_CLIENT_MASTER_200001_10'
		,'1'
		,'INSERT data to main table'
	  )

INSERT SCE_DLModule (
      [WebApiConfigID]
      ,[STG_TBLName]
      ,[POST_TBLName])
OUTPUT INSERTED.WebApiConfigID INTO @t_WebApiConfigID_INSERTED
VALUES
	  (
		@n_WebApiConfigID_inserted
		,'dbo.[LB_CLIENT_MASTER_STG_STG]'
		,'dbo.[LB_CLIENT_MASTER_STG]'
	  )

-- Remove Unique ID
DELETE FROM @t_WebApiConfigID_INSERTED;

INSERT SCE_DLWebApiConfig (
      [OperationType]
      ,[Application]
      ,[Environment]
      ,[Country]
      ,[TgtServer]
      ,[TgtDatabase]
      ,[URL]
      ,[ColumnMapURL])
OUTPUT INSERTED.WebApiConfigID INTO @t_WebApiConfigID_INSERTED
VALUES
	  (
		'SCE_DL_LB_CLIENT_MASTER'
		,'BILLING'
		,'CDT'
		,'NLD'
		,'billing1'
		,'SCEBILLING'
		,'/sceapi/EUR/SCEBILL/GenericRequest/SCE_DL_Generic_BILLING'
		,'/sceapi/EUR/SCEBILL/GenericRequest/SCE_DLColumnMap_Inq'
	  )

SELECT @n_WebApiConfigID_inserted = SEQ FROM @t_WebApiConfigID_INSERTED

INSERT SCE_DLSubRuleDict_Hdr (
      [WebApiConfigID]
      ,[Flag]
      ,[Code]
      ,[Step]
      ,[SubRuleSP]
      ,[IsActive]
      ,[Descr])
OUTPUT INSERTED.WebApiConfigID INTO @t_WebApiConfigID_INSERTED
VALUES
	  (
		@n_WebApiConfigID_inserted
		,'1'
		,'CLIENT_RULES_100001'
		,'10'
		,'isp_SCE_DL_GENERIC_CLIENT_MASTER_100001_10'
		,'1'
		,'Perform data validation'
	  )

INSERT SCE_DLSubRuleDict_Hdr (
      [WebApiConfigID]
      ,[Flag]
      ,[Code]
      ,[Step]
      ,[SubRuleSP]
      ,[IsActive]
      ,[Descr])
OUTPUT INSERTED.WebApiConfigID INTO @t_WebApiConfigID_INSERTED
VALUES
	  (
		@n_WebApiConfigID_inserted
		,'2'
		,'CLIENT_RULES_200001'
		,'20'
		,'isp_SCE_DL_GENERIC_CLIENT_MASTER_200001_10'
		,'1'
		,'INSERT data to main table'
	  )

INSERT SCE_DLModule (
      [WebApiConfigID]
      ,[STG_TBLName]
      ,[POST_TBLName])
OUTPUT INSERTED.WebApiConfigID INTO @t_WebApiConfigID_INSERTED
VALUES
	  (
		@n_WebApiConfigID_inserted
		,'dbo.[LB_CLIENT_MASTER_STG_STG]'
		,'dbo.[LB_CLIENT_MASTER_STG]'
	  )

-- Remove Unique ID
DELETE FROM @t_WebApiConfigID_INSERTED;

INSERT SCE_DLWebApiConfig (
      [OperationType]
      ,[Application]
      ,[Environment]
      ,[Country]
      ,[TgtServer]
      ,[TgtDatabase]
      ,[URL]
      ,[ColumnMapURL])
OUTPUT INSERTED.WebApiConfigID INTO @t_WebApiConfigID_INSERTED
VALUES
	  (
		'SCE_DL_LB_CLIENT_MASTER'
		,'BILLING'
		,'CDT'
		,'GLO'
		,'billing1'
		,'SCEBILLING'
		,'/sceapi/EUR/SCEBILL/GenericRequest/SCE_DL_Generic_BILLING'
		,'/sceapi/EUR/SCEBILL/GenericRequest/SCE_DLColumnMap_Inq'
	  )

SELECT @n_WebApiConfigID_inserted = SEQ FROM @t_WebApiConfigID_INSERTED

INSERT SCE_DLSubRuleDict_Hdr (
      [WebApiConfigID]
      ,[Flag]
      ,[Code]
      ,[Step]
      ,[SubRuleSP]
      ,[IsActive]
      ,[Descr])
OUTPUT INSERTED.WebApiConfigID INTO @t_WebApiConfigID_INSERTED
VALUES
	  (
		@n_WebApiConfigID_inserted
		,'1'
		,'CLIENT_RULES_100001'
		,'10'
		,'isp_SCE_DL_GENERIC_CLIENT_MASTER_100001_10'
		,'1'
		,'Perform data validation'
	  )

INSERT SCE_DLSubRuleDict_Hdr (
      [WebApiConfigID]
      ,[Flag]
      ,[Code]
      ,[Step]
      ,[SubRuleSP]
      ,[IsActive]
      ,[Descr])
OUTPUT INSERTED.WebApiConfigID INTO @t_WebApiConfigID_INSERTED
VALUES
	  (
		@n_WebApiConfigID_inserted
		,'2'
		,'CLIENT_RULES_200001'
		,'20'
		,'isp_SCE_DL_GENERIC_CLIENT_MASTER_200001_10'
		,'1'
		,'INSERT data to main table'
	  )

INSERT SCE_DLModule (
      [WebApiConfigID]
      ,[STG_TBLName]
      ,[POST_TBLName])
OUTPUT INSERTED.WebApiConfigID INTO @t_WebApiConfigID_INSERTED
VALUES
	  (
		@n_WebApiConfigID_inserted
		,'dbo.[LB_CLIENT_MASTER_STG_STG]'
		,'dbo.[LB_CLIENT_MASTER_STG]'
	  )