CREATE trigger dbo.T_ON_UPDATE_ImportTransactions_Rules on dbo.ImportTransactions_Rules
after insert, update, delete
as
     begin
         set nocount on
         if not exists( select 1
                          from inserted )
            and not exists( select 1
                              from deleted )
             return
              else
             begin
                 insert into dbo.ImportTransactions_Rules_Log
                 ( RuleID
                 , OperationType
                 , MovType
                 , ChargeType
                 , BONote
                 , Direction
                 , LoroAccount
                 , CT_Const
                 , CL_Const
                 , IsSynchronized
                 , IsDual
                 , NeedClientInstr
                 , SettledOnly
                 , IsInternal
                 , DefaultComment
                 , STLRuleID
                 , Priority
                 , StartDate
                 , EndDate
                 , [User]
                 , RuleComment
                 , PDocType_Name
                 , isPlanDate
                 , AuditDateTime_log
                 , AuditActions
                 , AuditUser
                 )
                 select d.RuleID
                      , d.OperationType
                      , d.MovType
                      , d.ChargeType
                      , d.BONote
                      , d.Direction
                      , d.LoroAccount
                      , d.CT_Const
                      , d.CL_Const
                      , d.IsSynchronized
                      , d.IsDual
                      , d.NeedClientInstr
                      , d.SettledOnly
                      , d.IsInternal
                      , d.DefaultComment
                      , d.STLRuleID
                      , d.Priority
                      , d.StartDate
                      , d.EndDate
                      , d.[User]
                      , d.RuleComment
                      , d.PDocType_Name
                      , d.isPlanDate
                      , AuditDateTime_log = getdate()
                      , AuditActions = 'D'
                      , AuditUser = suser_name()
                   from DELETED d
                 union all
                 select i.RuleID
                      , i.OperationType
                      , i.MovType
                      , i.ChargeType
                      , i.BONote
                      , i.Direction
                      , i.LoroAccount
                      , i.CT_Const
                      , i.CL_Const
                      , i.IsSynchronized
                      , i.IsDual
                      , i.NeedClientInstr
                      , i.SettledOnly
                      , i.IsInternal
                      , i.DefaultComment
                      , i.STLRuleID
                      , i.Priority
                      , i.StartDate
                      , i.EndDate
                      , i.[User]
                      , i.RuleComment
                      , i.PDocType_Name
                      , i.isPlanDate
                      , AuditDateTime_log = getdate()
                      , AuditActions = 'I'
                      , AuditUser = suser_name()
                   from inserted I
         end
     end
