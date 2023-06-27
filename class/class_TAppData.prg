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


// Atualizado: 2022-05-30 10:30
class TAppData

   data MySQLDataSource
   data companies readonly
   data UTC readonly
   data users readonly
   data registryRoot readonly
   data registryPath readonly
   data systemPath readonly
   data executable readonly
   data executableName readonly
   data displayName readonly
   data supportUrl readonly
   data version readonly
   data timer
   data startTime readonly
   data endTime readonly
   data frequency readonly
   data lastMessage
   data ACBr
   data ftp_url
   data ftp_server
   data ftp_id
   data ftp_password
   data dfePath
   data tpAmb
   data tpEmis

   method new(version) constructor
   method registerSystem()
   method isRunning()
   method registerDatabase()
   method setDatabase()
   method usersClean()
   method usersAdds(hash)
   method usersStatus()
   method companiesAdd(c) SETGET
   method companiesStatus() SETGET
   method companiesClean() SETGET
   method getCompanies(id)
   method setUTC(emp_id)

end class

method new(version) class TAppData
   DEFAULT version := "1.0.0"
   ::version := version
   ::companies := {}
   ::UTC := '-03:00'
   ::users := {}
   ::systemPath := hb_cwd()
   ::registryRoot := "HKEY_CURRENT_USER\Software\Sistrom\"
   ::executable := hb_FNameNameExt(hb_ProgName())
   ::executableName := hb_FNameNameExt(hb_FNameName(hb_ProgName()))
   ::registryPath := ::registryRoot + ::executableName + "\"
   ::displayName := "CTeMonitor " + ::version + " (32-bit)"
   ::supportUrl := "https://www.sistrom.com.br/"
   // Informações de ftp adicionada em registerDB pela primeira vez e depois lidas de RegistryRead
   ::ftp_url := ''
   ::ftp_server := ''
   ::ftp_id := ''
   ::ftp_password := ''
   ::lastMessage := ''
   ::tpAmb := '1'    // Produção
   ::tpEmis := '1'   // Normal
return self

method registerSystem() class TAppData
   local h

   if !hb_DirExists('tmp')
      hb_DirBuild( 'tmp' ) // Esta função, se precisar, cria pasta e subpastas em um comando só hb_DirBuild('dir1\dir2\dir3')
   endif
   if !hb_DirExists('log')
      hb_DirBuild('log')
   endif

   if (RegistryRead(::registryRoot + "DisplayName") == NIL)
      RegistryWrite(::registryRoot + "DisplayName", "Sistrom Sistemas web")
   endif
   if (RegistryRead(::registryRoot + "SupportUrl") == NIL)
      RegistryWrite(::registryRoot + "SupportUrl", ::supportUrl)
   endif
   if (RegistryRead(::registryPath + "Executable") == NIL)
      RegistryWrite(::registryPath + "Executable", ::executable)
   endif
   if (RegistryRead(::registryPath + "DisplayName") == NIL) .or. !(RegistryRead(::registryPath + "DisplayName") == ::displayName)
      RegistryWrite(::registryPath + "DisplayName", ::displayName)
   endif
   if (RegistryRead(::registryPath + "SysArchitecture") == NIL)
      RegistryWrite(::registryPath + "SysArchitecture", "32bit")
   endif
   if (RegistryRead(::registryPath + "Version") == NIL) .or. !(RegistryRead(::registryPath + "Version") == ::version)
      RegistryWrite(::registryPath + "Version", ::version)
      RegistryWrite(::registryPath + "SysVersion", hb_ULeft(::version, hb_RAt('.', ::version)-1))
   endif
   if (RegistryRead(::registryPath + "SysVersion") == NIL)
      RegistryWrite(::registryPath + "SysVersion", hb_ULeft(::version, hb_RAt('.', ::version)-1))
   endif
   if (RegistryRead(::registryPath + "InstallPath\Path") == NIL)
      RegistryWrite(::registryPath + "InstallPath\Path", hb_cwd())
   endif
   if (RegistryRead(::registryPath + "InstallPath\sharedPath") == NIL)
      RegistryWrite(::registryPath + "InstallPath\sharedPath", "C:\ACBrMonitorPLUS\")
   endif

   ::dfePath := RegistryRead(::registryPath + "InstallPath\sharedPath")
   ::ACBr := TACBr():new(::dfePath)

   if (RegistryRead(::registryPath + "Host\ServerName") == NIL)
      RegistryWrite(::registryPath + "Host\ServerName", "")
   endif
   if (RegistryRead(::registryPath + "Host\UserName") == NIL)
      RegistryWrite(::registryPath + "Host\UserName", "")
   endif
   if (RegistryRead(::registryPath + "Host\Password") == NIL)
      RegistryWrite(::registryPath + "Host\Password", "")
   endif
   if (RegistryRead(::registryPath + "Monitoring\startTime") == NIL)
      RegistryWrite(::registryPath + "Monitoring\startTime", "23:00")
   endif
   if (RegistryRead(::registryPath + "Monitoring\endTime") == NIL)
      RegistryWrite(::registryPath + "Monitoring\endTime", "08:00")
   endif
   if (RegistryRead(::registryPath + "Monitoring\frequency") == NIL)
      RegistryWrite(::registryPath + "Monitoring\frequency", 10)
   endif
   if (RegistryRead(::registryPath + "Monitoring\Running") == NIL)
      RegistryWrite(::registryPath + "Monitoring\Running", 0)
   endif
   if (RegistryRead(::registryPath + "Monitoring\DontRun") == NIL)
      RegistryWrite(::registryPath + "Monitoring\DontRun", 0)
   endif
   if (RegistryRead(::registryPath + "Monitoring\Stop_Execution") == NIL)
      RegistryWrite(::registryPath + "Monitoring\Stop_Execution", 0)
   endif

   if ::isRunning()
      saveLog('O sistema não foi desligado corretamente da última vez')
   else
      RegistryWrite(::registryPath + "Monitoring\Running", 1)
   endif

   AEval(Directory('log\*.*'), {|aFile| iif(aFile[3] <= (Date()-70), hb_FileDelete("log\"+aFile[1]), NIL)})
   AEval(Directory('tmp\*.*'), {|aFile| iif(aFile[3] <= (Date()-10), hb_FileDelete("tmp\"+aFile[1]), NIL)})
   AEval(Directory('ftp-*.log'), {|aFile| iif(aFile[3] <= (Date()-30), hb_FileDelete(aFile[1]), NIL)})

   if hb_DirExists(::ACBr:returnPath)
      AEval(Directory(::ACBr:returnPath + '*.*'), {|aFile| iif(aFile[3] <= (Date()-05), hb_FileDelete(::ACBr:returnPath + aFile[1]), NIL)})
   endif
   if hb_DirExists(::ACBr:outputPath)
      AEval(Directory(::ACBr:outputPath + '*.*'), {|aFile| iif(aFile[3] <= (Date()-05), hb_FileDelete(::ACBr:returnPath + aFile[1]), NIL)})
   endif
   if hb_DirExists(::ACBr:xmlPath)
      AEval(Directory(::ACBr:xmlPath + '*.*'), {|aFile| iif(aFile[3] <= (Date()-05), hb_FileDelete(::ACBr:returnPath + aFile[1]), NIL)})
   endif
   if hb_DirExists(::ACBr:outputPath)
      AEval(Directory(::ACBr:xmlPath + '*.*'), {|aFile| iif(aFile[3] <= (Date()-365), hb_FileDelete(::ACBr:outputPath + aFile[1]), NIL)})
   endif
   if hb_FileExists('config.json')
      h := jsonDecode(hb_MemoRead('config.json'))
      if hb_HGetRef(h, 'tpAmb') .and. hb_HGetRef(h, 'tpEmis')
         ::tpAmb := h['tpAmb']
         ::tpEmis := h['tpEmis']
      else
         hb_FileDelete('config.json')
         h := fCreate( "config.json", FC_NORMAL )
         fWrite(h, hb_jsonEncode( {"tpAmb" => '1', "tpEmis" => '1'}, .T.))
         fClose(h)
      endif
   else
      h := fCreate( "config.json", FC_NORMAL )
      fWrite(h, hb_jsonEncode( {"tpAmb" => '1', "tpEmis" => '1'}, .T.))
      fClose(h)
   endif

   saveLog(hb_eol() + hb_eol() + ::displayName + ' - Sistema iniciado (monitorando...)' + hb_eol())

return nil

method isRunning() class TAppData
return isTrue(RegistryRead(::registryPath + "Monitoring\Running"))

method registerDatabase() class TAppData

   ::startTime := RegistryRead(::registryPath + "Monitoring\startTime")
   ::endTime := RegistryRead(::registryPath + "Monitoring\endTime")
   ::frequency := RegistryRead(::registryPath + "Monitoring\frequency")

   if Empty(RegistryRead(::registryPath + "Host\ServerName")) .or. Empty(RegistryRead(::registryPath + "Host\ftp_url"))
      LOAD WINDOW registerDB
      ON KEY ESCAPE OF registerDB ACTION registerDB_Escape()
      registerDB.CENTER
      registerDB.ACTIVATE
   else
      ::MySQLDataSource := TMySQLDataSource():new({;
            'address' => CharXor(RegistryRead(::registryPath + "Host\ServerName"), 'SisWeb2020'),;
            'dataBase' => CharXor(RegistryRead(::registryPath + "Host\UserName"), 'SisWeb2020'),;
            'userName' => CharXor(RegistryRead(::registryPath + "Host\UserName"), 'SisWeb2020'),;
            'password' => CharXor(RegistryRead(::registryPath + "Host\Password"), 'SisWeb2020')})
      ::ftp_url := CharXor(RegistryRead(::registryPath + "Host\ftp_url"), 'SisWeb2020')
      ::ftp_server := CharXor(RegistryRead(::registryPath + "Host\ftp_server"), 'SisWeb2020')
      ::ftp_id := CharXor(RegistryRead(::registryPath + "Host\ftp_id"), 'SisWeb2020')
      ::ftp_password := CharXor(RegistryRead(::registryPath + "Host\ftp_password"), 'SisWeb2020')
   endif
   ::timer := seconds()

return nil

method setDatabase() class TAppData
   RegistryWrite(::registryPath + "Host\ServerName", CharXor(::MySQLDataSource:address, 'SisWeb2020'))
   RegistryWrite(::registryPath + "Host\UserName", CharXor(::MySQLDataSource:userName, 'SisWeb2020'))
   RegistryWrite(::registryPath + "Host\Password", CharXor(::MySQLDataSource:password, 'SisWeb2020'))
   RegistryWrite(::registryPath + "Host\ftp_url", CharXor(::ftp_url, 'SisWeb2020'))
   RegistryWrite(::registryPath + "Host\ftp_server", CharXor(::ftp_server, 'SisWeb2020'))
   RegistryWrite(::registryPath + "Host\ftp_id", CharXor(::ftp_id, 'SisWeb2020'))
   RegistryWrite(::registryPath + "Host\ftp_password", CharXor(::ftp_password, 'SisWeb2020'))
return nil

method usersAdds(hash) class TAppData
   AAdd(::users, hash)
return nil

method usersClean() class TAppData
   ::users := {}
return nil

method usersStatus() class TAppData
return hmg_len(::users)

method companiesAdd(c) class TAppData
   AAdd(::companies, TModifyToHb():new(c))
return hmg_len(::companies)

method companiesStatus() class TAppData
return hmg_len(::companies)

method companiesClean() class TAppData
   ::companies := {}
return nil

method getCompanies(id) class TAppData
   local pos := hb_AScan(::companies, {|oVal| oVal:getField('id') == id})
   if (pos == 0)
      return Nil
   endif
return ::companies[pos]

method setUTC(emp_id) class TAppData
   local emitente := ::getCompanies(emp_id)
   ::UTC := emitente:getField('utc')
return Nil
