/*
   Projeto: CTeMonitor
   Executavel multiplataforma que faz o intercâmbio do TMS.CLOUD WEB com o ACBrMonitorPlus
   para criar uma interface de comunicação com a Sefaz através de comandos para o ACBrMonitorPlus.

   Direitos Autorais Reservados (c) 2020 Nilton Gonçalves Medeiros

   Colaboradores nesse arquivo:

   Você pode obter a última versão desse arquivo no GitHub
   Componentes localizado em https://github.com/nilton-medeiros/cte-monitor

    Esta biblioteca é software livre; você pode redistribuí-la e/ou modificá-la
   sob os termos da Licença Pública Geral Menor do GNU conforme publicada pela
   Free Software Foundation; tanto a versão 2.1 da Licença, ou (a seu critério)
   qualquer versão posterior.

    Esta biblioteca é distribuída na expectativa de que seja útil, porém, SEM
   NENHUMA GARANTIA; nem mesmo a garantia implícita de COMERCIABILIDADE OU
   ADEQUAÇÃO A UMA FINALIDADE ESPECÍFICA. Consulte a Licença Pública Geral Menor
   do GNU para mais detalhes. (Arquivo LICENÇA.TXT ou LICENSE.TXT)

    Você deve ter recebido uma cópia da Licença Pública Geral Menor do GNU junto
   com esta biblioteca; se não, escreva para a Free Software Foundation, Inc.,
   no endereço 59 Temple Street, Suite 330, Boston, MA 02111-1307 USA.
   Você também pode obter uma copia da licença em:
   http://www.opensource.org/licenses/gpl-license.php

   Nilton Gonçalves Medeiros - nilton@sistrom.com.br - www.sistrom.com.br
   Caieiras - SP
*/


#include <hmg.ch>


procedure setup()
	private g AS OBJECT // Grid
	private c AS OBJECT // ComboBox

	if isWindowActive(setup)
		doMethod('setup', 'setFOCUS')
	else
		LOAD WINDOW setup
		ON KEY ESCAPE OF setup ACTION setup.RELEASE
		setup.CENTER
		setup.ACTIVATE
	endif
return

procedure setup_form_onInit()
	local e AS OBJECT
	local u AS HASH
	local notifyTooltip := hb_utf8StrTran(appData:lastMessage, hb_eol(), " | ")
	local tmp

	SetProperty("Main", "TimerCTe", "Enabled", False)

	g := TDBGrid():new('setup', 'Grid_1')
	c := TComboBox():new('setup', 'Combo_Users')

	with object appData

		for each e in :companies
			g:AddItem({e:getField('id'),;
						  e:getField('xNome'),;
						  iif(e:getField('tpAmb')=='1','Produção', 'Homologação')})
		next

		for each u in :users
			c:AddItem(u['login'], u['password'])
		next

		c:setValue(1)

		SetProperty('setup', 'Text_seconds', 'Value', :frequency)
		SetProperty('setup', 'Text_das', 'Value', :startTime)
		SetProperty('setup', 'Text_as', 'Value', :endTime)
		SetProperty('setup', 'Text_root_path', 'Value', :dfePath)
		SetProperty("setup", "StatusBar", "Item", 1, "Database: " + :MySQLDataSource:dataBase + " | " + notifyTooltip)
		SetProperty("setup", "StatusBar", "Item", 2, :MySQLDataSource:connectedStatus)
		SetProperty("setup", "StatusBar", "Icon", 2, :MySQLDataSource:iconStatus)

	endwith

return

procedure showPassword_action()
		SetProperty('setup', 'Label_showPassword', 'Value', GetProperty('setup', 'Text_Password', 'Value'))
		SetProperty('setup', 'Label_showPassword', 'Visible', True)
		Inkey(2)
		SetProperty('setup', 'Label_showPassword', 'Visible', False)
return

procedure setup_text_seconds_onLostFocus()
	if (GetProperty('setup', 'Text_seconds', 'Value') < 5)
		SetProperty('setup', 'Text_seconds', 'Value', 5)
	endif
	TextBox_onlostfocus("setup", "Text_seconds")
return

procedure setup_text_das_onLostFocus()
	if (GetProperty('setup', 'Text_das', 'Value') < "00:00") .or. (GetProperty('setup', 'Text_das', 'Value') > "23:59")
		SetProperty('setup', 'Text_das', 'Value', '  :  ')
	endif
	TextBox_onlostfocus("setup", "Text_das")
return

procedure setup_text_as_onLostFocus()
	if (GetProperty('setup', 'Text_as', 'Value') < "00:00") .or. (GetProperty('setup', 'Text_as', 'Value') > "23:59")
		SetProperty('setup', 'Text_as', 'Value', '  :  ')
	endif
	TextBox_onlostfocus("setup", "Text_as")
return

procedure setup_button_save_action()
	local rootPath := GetProperty('setup', 'text_root_path', 'Value')
	if empty(rootPath)
		MsgExclamation('Definir a pasta raiz dos XMLs & PDFs')
	elseif !hb_DirExists(rootPath) .and. !hb_DirBuild(rootPath)
		MsgExclamation('Pasta raiz inválida, não pode ser criada')
	else
		if GetProperty('setup', 'Text_seconds', 'Value') < 10
			SetProperty('setup', 'Text_seconds', 'Value', 10)
		endif
		RegistryWrite(appData:registryPath + "InstallPath\sharedPath", rootPath)
		appData:dfePath := rootPath
		appData:ACBr:setSharedPath(rootPath)
		if (GetProperty('setup', 'Text_password', 'Value') == c:getCargo())
			RegistryWrite(appData:registryPath + "Monitoring\startTime", GetProperty('setup', 'Text_das', 'Value'))
			RegistryWrite(appData:registryPath + "Monitoring\endTime", GetProperty('setup', 'Text_as', 'Value'))
			RegistryWrite(appData:registryPath + "Monitoring\frequency", GetProperty('setup', 'Text_seconds', 'Value'))
			saveLog('Usuario ' + c:getDisplay() + ' alterou campos do setup')
			doMethod('setup', 'RELEASE')
		else
			MsgExclamation('Senha Inválida, favor conferir!', 'Senha')
		endif
	endif
return

procedure setup_button_cancel_action()
		doMethod('setup', 'RELEASE')
return

procedure setup_button_turnOFF_action()
	if MsgYesNo("Deseja interromper o monitoramento de CTes?", 'CTeMonitor: Desligar')
		turnOFF(True)
	endif
return

procedure setup_form_onRelease()
	SetProperty("Main", "TimerCTe", "Enabled", True)
return
