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
#include "hbclass.ch"


class TMySQLDataSource

      data dataBase READONLY
      data address READONLY
      data userName READONLY
      data password READONLY
      data iconStatus init 'serverWAIT'
      data connected init False
      data connectedStatus init "Desconectado"
      data server AS OBJECT READONLY

      method new(initialParameters) CONSTRUCTOR
      method connect()
      method disconnect()
      method isSet()
      method queryValue(cmdSQL)
      method tryToConnect()
end class

method new(initialParameters) class TMySQLDataSource
      ::address := hb_HGetDef(initialParameters, 'address', "")
      ::userName := hb_HGetDef(initialParameters, 'userName', "")
      ::dataBase := hb_HGetDef(initialParameters, 'dataBase', ::userName)
      ::password := hb_HGetDef(initialParameters, 'password', "")
return SELF

method connect() class TMySQLDataSource
      local msgError, retValue

      if !::tryToConnect()

         // Tenta de novo
         if !::tryToConnect()
            if (::server == NIL)
               PlayAsterisk()
               msgError := "Não foi possível conectar ao servidor MySQL '" + ::address + "'"
               ::disconnect()
               msgNotify({'notifyTooltip' => "Servidor indisponível", 'notifyICON' =>"serverOFF",;
                            'showMsg' => {'message' => msgError,;
                                          'title' => "Servidor indisponível!"}})
               saveLog("Servidor indisponível" + CRLF + msgError)
               MsgStop(msgError, 'Servidor indisponível, tente mais tarde!')
               return False
            elseif ::server:NetErr()
               PlayAsterisk()
               msgError := {'Não foi possível conectar ao servidor MySQL "' + ::address + '"', CRLF,;
                            "     Possíveis problemas:", CRLF,;
                            "        - Sem conexão com a Internet. Verifique sua internet", CRLF,;
                            "        - Login não permitido", CRLF,;
                            "        - Senha do Banco de Dados inválida", CRLF,;
                            "     Erro: ", ::server:Error()}
               ::disconnect()
               msgNotify({'notifyTooltip' => "Sem conexão",;
                            'showMsg' => {'message' => msgError,;
                                            'title' => "Servidor indisponível!"}})
               saveLog(msgError)
               retValue := MessageBoxTimeout(msgError, 'Falha de Conexão!', MB_ICONERROR + MB_RETRYCANCEL, 600000)
               if (retValue == IDTIMEDOUT) .or. (retValue == IDRETRY)
                  if !::tryToConnect()
                     MsgStop(msgError, 'Falha de Conexão!')
                     return False
                  endif
               else // IDCANCEL
                  turnOFF(True)
               endif
            endif
         endif

      endif

      ::server:selectDB(::dataBase)
      ::connected := !::server:NetErr()

      if !::connected
         PlayAsterisk()

         msgError := {'Não foi possível conectar ao Banco de Dados MySQL "' + ::dataBase + '"', CRLF+CRLF,;
			'Servidor: ', ::address}

         ::disconnect()
         msgNotify({'notifyTooltip' => "Database" + CRLF + "sem conexão",;
                      'notifyICON' => "serverFAILED",;
                      'showMsg' => {'message' => msgError, 'title' => "Banco de Dados indisponível!"}})
         saveLog(msgError)
      else
         ::iconStatus := "serverON"
         ::connectedStatus := "Conectado"
         msgNotify()
         SetProperty('Main', 'NotifyIcon', 'serverON')
         //MsgInfo(mysql_get_host_info(  ::server:nSocket), 'Informações do Host') -- Traz o IP ou localhost
         //MsgInfo(mysql_get_server_info(::server:nSocket), 'Informações do Server') -- Traz a versão do MySQL
      endif

return ::connected

method disconnect() class TMySQLDataSource
      ::connected := False
      ::connectedStatus := "Desconectado"
      ::iconStatus := "serverOFF"

      if !(::server == NIL)
         ::server:Destroy()
         ::server := NIL
      endif
      msgNotify()
      SetProperty('Main', 'NotifyIcon', 'serverOFF')
return NIL

method isSet() class TMySQLDataSource
return !Empty(::dataBase) .and. !Empty(::address) .and. !Empty(::userName) .and. !Empty(::password)

method QueryValue(cmdSQL) class TMySQLDataSource
      LOCAL oSQLValue:= TSQLQuery():NEW(cmdSQL)
      LOCAL xValue:= iif(oSQLValue:isExecuted(), oSQLValue:FieldGet(1), NIL)

      if ValType(xValue) == "C"
         xValue:= String_MySQL_to_hb(xValue)
      endif

return xValue

method tryToConnect() class TMySQLDataSource
   SetProperty('Main', 'NotifyIcon', 'serverOFF')
   ::disconnect()
   if ::isSet()
      msgNotify({'notifyTooltip' => "Conectando ao servidor..."})
      ::server := TMySQLServer():new(::address, ::userName, ::password)
   else
      saveLog('Parametros do banco de dados nao definidos!')
   endif
return !(::server == NIL) .and. !::server:NetErr()