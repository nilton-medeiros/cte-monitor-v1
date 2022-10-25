/*
   Projeto: CTeMonitor
   Executavel multiplataforma que faz o intercâmbio do TMS.CLOUD WEB com a lib ACBrCTe32.dll e ACBrMDFe32.dll
   para criar uma interface de comunicação com a Sefaz através de comandos da classe ACBrCTe|ACBrMDFe usando as DLLs ACBrCTe32.dll e ACBrMDFe32.dll.

   Direitos Autorais Reservados (c) 2020 Nilton Gonçalves Medeiros

   Colaboradores nesse arquivo:

   Você pode obter a última versão desse arquivo no GitHub
   Componentes localizado em https://github.com/nilton-medeiros/cte-monitor-v2

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
#include "hbclass.ch"

// Atualizado: 2022-05-29 15:00
procedure registerDB_onInit()
   local ip := TIPaddress():new()
   if !Empty(RegistryRead(appData:registryPath + "Host\db_ServerName"))
      ip:setIP(CharXor(RegistryRead(appData:registryPath + "Host\db_ServerName"), 'SisWeb2020'))
      SetProperty('RegisterDB', 'IpAddress_host', 'Value', ip:arrayIP)
      SetProperty('RegisterDB', 'Text_DataBase', 'Value', CharXor(RegistryRead(appData:registryPath + "Host\db_UserName"), 'SisWeb2020'))
      SetProperty('RegisterDB', 'Text_User', 'Value', CharXor(RegistryRead(appData:registryPath + "Host\db_UserName"), 'SisWeb2020'))
      SetProperty('RegisterDB', 'Text_Password', 'Value', CharXor(RegistryRead(appData:registryPath + "Host\db_Password"), 'SisWeb2020'))
   endif
   if !Empty(RegistryRead(appData:registryPath + "Host\ftp_url"))
      SetProperty('RegisterDB', 'Text_ftp_url', 'Value', CharXor(RegistryRead(appData:registryPath + "Host\ftp_url"), 'SisWeb2020'))
      SetProperty('RegisterDB', 'Text_ftp_server', 'Value', CharXor(RegistryRead(appData:registryPath + "Host\ftp_server"), 'SisWeb2020'))
      SetProperty('RegisterDB', 'Text_ftp_id', 'Value', CharXor(RegistryRead(appData:registryPath + "Host\ftp_id"), 'SisWeb2020'))
      SetProperty('RegisterDB', 'Text_ftp_password', 'Value', CharXor(RegistryRead(appData:registryPath + "Host\ftp_password"), 'SisWeb2020'))
   endif
return

procedure registerDB_buttonSaveAction()
			Local ip := TIPaddress():new(GetProperty('RegisterDB', 'IpAddress_host', 'Value'))
         if !(ip:arrayIP[1] == 0) .and. !Empty(GetProperty('RegisterDB', 'Text_DataBase', 'Value')) .and. !Empty(GetProperty('RegisterDB', 'Text_User', 'Value')) .and. !Empty(GetProperty('RegisterDB', 'Text_Password', 'Value')) .and.;
            !Empty(GetProperty('RegisterDB', 'Text_ftp_url', 'Value')) .and. !Empty(GetProperty('RegisterDB', 'Text_ftp_server', 'Value')) .and. !Empty(GetProperty('RegisterDB', 'Text_ftp_id', 'Value')) .and. !Empty(GetProperty('RegisterDB', 'Text_ftp_password', 'Value'))

				appData:MySQLDataSource := TMySQLDataSource():new({;
																				'address' => ip:stringIP,;
																				'userName' => AllTrim(GetProperty('RegisterDB', 'Text_User', 'Value')),;
                                                            'password' => AllTrim(GetProperty('RegisterDB', 'Text_Password', 'Value'))})
            appData:ftp_url := AllTrim(GetProperty('RegisterDB', 'Text_ftp_url', 'Value'))
            appData:ftp_server := AllTrim(GetProperty('RegisterDB', 'Text_ftp_server', 'Value'))
            appData:ftp_id := AllTrim(GetProperty('RegisterDB', 'Text_ftp_id', 'Value'))
            appData:ftp_password := AllTrim(GetProperty('RegisterDB', 'Text_ftp_password', 'Value'))
				appData:setDatabase()

				if appData:MySQLDataSource:connect()
					doMethod('registerDB', 'RELEASE')
				else
					MsgExclamation({'Acesso negado para usuário ', appData:MySQLDataSource:userName,'.', CRLF+CRLF, 'Verifique as informações digitadas.' }, 'Suporte: Informações incorretas!')
				end

			else
				MsgExclamation('Preencher todos os campos', 'Dados insuficientes!')
			end
Return

procedure registerDB_Escape()
	doMethod('registerDB', 'RELEASE')
	turnOFF(True)
return


class TIPaddress
   data arrayIP readonly
   data stringIP readonly
   method new() constructor
   method setIP()
   method convert()
end class

method new(aIP) class TIPaddress
   default aIP := {0,0,0,0}
   ::arrayIP := aIP
   ::convert(::arrayIP)
return self

method setIP(ip) class TIPaddress
   default ip := {0,0,0,0}
   if (ValType(ip) == 'A')
      ::arrayIP := ip
      ::convert(::arrayIP)
   elseif (ValType(ip) == 'C')
      ::stringIP := ip
      ::convert(::stringIP)
   else
      ::arrayIP := {0,0,0,0}
      ::convert(::arrayIP)
   endif
return nil

method convert(ip) class TIPaddress
   local n, c
   if (ValType(ip) == 'A')
      ::stringIP := hb_ntos(ip[1])
      ::stringIP := ::stringIP + '.' + hb_ntos(ip[2])
      ::stringIP := ::stringIP + '.' + hb_ntos(ip[3])
      ::stringIP := ::stringIP + '.' + hb_ntos(ip[4])
   else
      ::arrayIP := hb_ATokens(ip, '.')
      for n := 1 to 4
         ::arrayIP[n] := Val(::arrayIP[n])
      next
   endif

return nil