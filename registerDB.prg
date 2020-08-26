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


procedure registerDB_buttonSaveAction()
			Local aIP := GetProperty('RegisterDB', 'IpAddress_host', 'Value')

			if !(aIP[1] == 0) .and. !Empty(GetProperty('RegisterDB', 'Text_DataBase', 'Value')) .and. !Empty(GetProperty('RegisterDB', 'Text_User', 'Value')) .and. !Empty(GetProperty('RegisterDB', 'Text_Password', 'Value'))

				appData:MySQLDataSource := TMySQLDataSource():new({;
																				'address' => IPArrayToString(aIP),;
																				'userName' => AllTrim(GetProperty('RegisterDB', 'Text_User', 'Value')),;
																				'password' => AllTrim(GetProperty('RegisterDB', 'Text_Password', 'Value'))})
				appData:setDatabase()

				if appData:MySQLDataSource:connect()
					doMethod('registerDB', 'RELEASE')
				else
					MsgExclamation({'Acesso negado para usuário ', appData:MySQLDataSource:userName,'.', CRLF+CRLF, 'Verifique as informações digitadas ou chame o suporte.' }, 'Informações incorretas!')
				end

			else
				MsgExclamation('Preencher todos os campos', 'Dados insuficientes!')
			end

Return

Function IPArrayToString(aIP)
			Local cIP := LTrim(STR(aIP[1]))
			cIP += '.' + LTrim(STR(aIP[2]))
			cIP += '.' + LTrim(STR(aIP[3]))
			cIP += '.' + LTrim(STR(aIP[4]))
Return (cIP)

procedure registerDB_Escape()
	doMethod('registerDB', 'RELEASE')
	turnOFF(True)
return