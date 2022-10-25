#include <hmg.ch>
#include <fileio.ch>

// Atualziação: 2022-05-30 as 20:30 - tag emp_simples_nacional AS CRT
procedure loadCompanies()
		local sql := TSQLString():new()
		local e, i

		with object appData

			msgNotify({'notifyTooltip' => "Carregando empresas..."})

			sql:setValue := "SELECT emp_id AS id,"
			sql:add := "CONCAT(emp_razao_social, '  (', emp_sigla_cia, IF(ISNULL(cid_sigla),'', CONCAT('-',cid_sigla)), ')') AS xNome, "
			sql:add := "emp_nome_fantasia AS xFant, "
			sql:add := "emp_cnpj AS CNPJ, "
			sql:add := "emp_inscricao_estadual AS IE, "
			sql:add := "emp_logradouro AS xLgr, "
			sql:add := "emp_numero AS nro, "
			sql:add := "emp_complemento AS xCpl, "
			sql:add := "emp_bairro AS xBairro, "
			sql:add := "cid_codigo_uf AS cUF, "
			sql:add := "cid_municipio AS xMunEnv, "
			sql:add := "cid_codigo_municipio AS cMunEnv, "
			sql:add := "cid_uf AS UF, "
			sql:add := "emp_cep AS CEP, "
			sql:add := "emp_fone1 AS fone, "
			sql:add := "emp_modal AS modal_name, "
			sql:add := "emp_versao_layout_xml AS versao_xml, "
			sql:add := "emp_ambiente_sefaz AS tpAmb, "
			sql:add := "emp_modal_codigo AS modal, "
			sql:add := "emp_RNTRC AS RNTRC, "
			sql:add := "utc, "
			sql:add := "remote_file_path, "
			sql:add := "emp_email_comercial AS email, "
			sql:add := "emp_seguradora AS seguradora, "
			sql:add := "emp_apolice AS apolice, "
			sql:add := "emp_simples_nacional AS CRT, "
			sql:add := "IF(emp_dacte_layout='RETRATO', '1', '2') AS tpImp "
			sql:add := "FROM view_empresas "
			sql:add := "WHERE emp_ativa = 1 AND emp_tipo_emitente = 'CTE' AND emp_ambiente_sefaz IN (1,2) "
			sql:add := "ORDER BY emp_id"
			e := TSQLQuery():new(sql:value)

			:companiesClean()

			if e:isExecuted()
				for i := 1 To e:LastRec()
					:companiesAdd(e:getRow(i))
				next
			endif

			e:Destroy()

			if (:companiesStatus() == 0)
				saveLog({"Sem empresas ativas cadastradas no TMS.CLOUD", hb_eol(), sql:value})
				msgNotify({'notifyTooltip' => "Sem empresas cadastradas no TMS.CLOUD",;
							  'showMsg' => {'message' => "Sem empresas cadastradas no TMS.CLOUD",;
							  'title' => "TMS.CLOUD SEM EMPRESAS"}})
				turnOFF()
			endif

			msgNotify()

		end

return

procedure loadAdminUsers()
	local sql := TSQLString():new()
	local u

	with object appData

		msgNotify({'notifyTooltip' => "Carregando usuários admin..."})

		sql:setValue := "SELECT user_id AS id, "
		sql:add := "user_login AS login, "
		sql:add := "user_senha AS password "
		sql:add := "FROM view_usuarios "
		sql:add := "WHERE user_ativo = TRUE AND perm_grupo = 'Administradores' "
		sql:add := "ORDER BY user_id"

		u := TSQLQuery():new(sql:value)
		:usersClean()

		if u:isExecuted()
			do while !u:EOF()
				:usersAdds({'id' => u:getField('id'), 'login' => u:getField('login'), 'password' => u:getField('password')})
				u:Skip()
			enddo
		endif

		u:Destroy()

		if (:usersStatus() == 0)
			saveLog({"Sem usuários ativos administradores cadastrados no TMS.CLOUD", hb_eol(), sql:value})
			msgNotify({'notifyTooltip' => "Sem administradores cadastrados no TMS.CLOUD",;
						  'showMsg' => {'message' => "Sem usuários ativos e administradores cadastrados no TMS.CLOUD",;
						  'title' => "TMS.CLOUD SEM USUÁRIOS"}})
			turnOFF()
		endif

		msgNotify()

	end

return

procedure msgNotify(msgNtfy)
   local notifyTooltip, showMsg

   with object memvar->appData:MySQLDataSource

      if !hb_isHash(msgNtfy)
         if :connected
            :connectedStatus := 'Conectado'
         else
            :connectedStatus := 'Desconectado'
			endif
			if (ValType(msgNtfy) == 'C') .and. !Empty(msgNtfy)
				msgNtfy := {'notifyTooltip' => :connectedStatus, 'showMsg' => msgNtfy}
			else
				msgNtfy := {'notifyTooltip' => :connectedStatus, 'showMsg' => ''}
			endif
      endif

      notifyTooltip := hb_HGetDef(msgNtfy, 'notifyTooltip', :connectedStatus)
      showMsg := hb_HGetDef(msgNtfy, 'showMsg', '')

      if isWIndowActive(setup)
         SetProperty("setup", "StatusBar", "Item", 1, "Database: " + :dataBase + " | " + notifyTooltip)
         SetProperty("setup", "StatusBar", "Item", 2, :connectedStatus)
         SetProperty("setup", "StatusBar", "Icon", 2, :iconStatus)
      endif

      memvar->appData:lastMessage := notifyTooltip
      SetProperty('Main', 'notifyTooltip', memvar->appData:displayName + hb_eol() + notifyTooltip)

      if !Empty(showMsg)
         if :connected
            MsgExclamation(showMsg['message'], showMsg['title'])
         else
            MsgStop(showMsg['message'], showMsg['title'])
         endif
      endif
   end

return

Function aux_isAlpha(num)
	local c, p := 0

	for each c in num
		if c == "."
			p++
		else
			if !(c $ "0123456789")
				return True
			endif
		endif
	next

return (p > 1)