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
// GED - Gerenciador Eletrônico de Documentos - via FTP


class TgedFTP
   data hostFile init '' PROTECTED
   data remotePath init '' PROTECTED
   data remoteFile init '' PROTECTED
   data urlFile init '' PROTECTED
   data ftp_url init .env.FTP_URL PROTECTED
   data ftp_server init .env.FTP_SERVER PROTECTED
   data ftp_userId init .env.FTP_USER_ID PROTECTED
   data ftp_password init .env.FTP_PASSWORD PROTECTED
   data isUpload init False READONLY
   data deletedStatus init False PROTECTED

   method new(host_file, remote_path, remote_file) constructor
   method upload()
   method delete()
   method getURL() INLINE ::urlFile

end class

method new(host_file, remote_path, remote_file) class TgedFTP
   default remote_file := token(host_file, '\') // Igual a SubStr(host_file, Rat('\', host_file)+1)
   ::hostFile := host_file
   ::remotePath := remote_path
   ::remoteFile := remote_file
   ::urlFile := .env.URL_FILE + ::remotePath + '/' + ::remoteFile
return self

method upload() class TgedFTP
   local url, ftp, error := 'UPLOAD - Erro de FTP: '

   saveLog({'Iniciando upload de arquivo: ', ::hostFile})

   ::isUpload := False

   if hb_FileExists(::hostFile)
      url := TUrl():new(::ftp_url)
      ftp := TIPClientFTP():new(url)
      ftp:nConnTimeout := 20000
      ftp:bUsePasv := True
      ftp:oURL:cServer := ::ftp_server
      ftp:oURL:cUserID := ::ftp_userId
      ftp:oURL:cPassword := ::ftp_password
      if ftp:open(::ftp_url)
         url:cPath := 'public_html/' + ::remotePath
         ftp:cwd(url:cPath)
         if ftp:uploadFile(::hostFile, ::remoteFile)
            ::isUpload := True
            saveLog('Upload de arquivo concluído com sucesso')
         else
            saveLog({'Falha no upload de arquivo: ', hb_eol(), 'host file: ', ::hostFile, hb_eol(), 'remote file: ', ::remoteFile})
         endif
         ftp:close()
      else
         if (ftp:socketCon == Nil)
            error += 'Conexão não iniciada'
         elseif (hb_inetErrorCode(ftp:socketCon) == 0)
            error += 'Resposta do servidor: ' + ftp:cReply
         else
            error += hb_inetErrorDesc(ftp:socketCon)
         endif
         saveLog({error, hb_eol(), 'host file: ', ::hostFile, hb_eol(), 'remote file: ', ::remoteFile})
      endif
   else
      saveLog({'Erro ao fazer upload! Arquivo inexistente: ', ::hostFile})
   endif

return ::isUpload

method delete() class TgedFTP
   local url := TUrl():new(::ftp_url)
   local ftp := TIPClientFTP():new(url)
   local error := 'DELETE - Erro de FTP: '

   ::deletedStatus := False

   ftp:nConnTimeout := 20000
   ftp:bUsePasv := True
   ftp:oURL:cServer := ::ftp_server
   ftp:oURL:cUserID := ::ftp_userId
   ftp:oURL:cPassword := ::ftp_password

   if ftp:open(::ftp_url)
      url:cPath := 'public_html/' + ::remotePath
      ftp:cwd(url:cPath)
      ::deletedStatus := ftp:dele(::remoteFile)
      ftp:close()
   else
      if (ftp:socketCon == Nil)
         error += 'Conexão não iniciada'
      elseif (hb_inetErrorCode(ftp:socketCon) == 0)
         error += 'Resposta do servidor: ' + ftp:cReply
      else
         error += hb_inetErrorDesc(ftp:socketCon)
      endif
      saveLog({error, hb_eol(), 'remote file: ', ::remoteFile})
   endif

return ::deletedStatus
