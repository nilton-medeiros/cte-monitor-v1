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

// Atualizado: 2022-11-23 00:04
procedure monitorGetFiles()
      local qCte, rowCTe, e, n := 1
      local sql := TSQLString():new()

      sql:setValue("SELECT cte_id, ")
      sql:add("emp_id, ")
      sql:add("cte_numero, ")
      sql:add("cte_chave ")
      sql:add("FROM ctes ")

      if (hmg_len(appData:companies) == 1)
         e := appData:companies[1]
         sql:add("WHERE emp_id = " + e:getField('id'))
      else
         sql:add("WHERE emp_id IN (")
         for each e in appData:companies
            if (n > 1)
               sql:add(",")
            endif
            sql:add(e:getField('id'))
            n++
         next
         sql:add(")")
      endif

      sql:add(" AND cte_situacao = 'AUTORIZADO' ")
      sql:add(" AND NOT ISNULL(cte_chave) AND cte_chave != ''")
      sql:add(" AND cte_monitor_action = 'GETFILES' ")
      sql:add(" AND TIMESTAMPDIFF(MINUTE, cte_getfiles_date, " + dateTime_hb_to_mysql(Date(), Time()) + ") > 5 ")
      sql:add("ORDER BY emp_id, cte_numero")

      qCTe := TSQLQuery():new(sql:value)
      if qCTe:isExecuted()

         do while ! qCTe:EOF()

            rowCTe := TModifyToHb():new(qCTe:getRow())
            getFiles(rowCTe)
            qCTe:Skip()
            DO EVENTS

         enddo

      endif

      qCTe:Destroy()

return

procedure getFiles(cte)
      local xmlPath := Memvar->appData:ACBr:sharedPath + '\xml\'
      local pdfPath := Memvar->appData:ACBr:sharedPath + '\pdf\'
      local chave := cte:getField('cte_chave')
      local defPath := SubStr(chave, 7, 14) + '\20' + SubStr(chave, 3, 4) + '\CTe\'
      local xmlFile := xmlPath + defPath + chave + '-cte.xml'
      local pdfFile := pdfPath + defPath + chave + '-cte.pdf'
      local emitente := Memvar->appData:getCompanies(cte:getField('emp_id'))
      local remotePath := emitente:getField('remote_file_path') + '/ctes/files'
      local acao := 'EXECUTED'
      local e, i, msg := {}
      local up, q, s := TSQLString():new("UPDATE ctes SET ")

      if hb_FileExists(xmlFile)
         up := TgedFTP():new(xmlFile, remotePath)
         if up:upload()
            s:add("cte_xml = '" + up:getURL() + "', ")
            AAdd(msg, 'FTP: Upload do XML executado com sucesso')
            saveLog({'CTe ID: ', cte:getField('cte_id'), 'GETFILES - FTP: Upload do XML executado com sucesso'})
         else
            AAdd(msg, 'FTP: Falha ao fazer upload do XML, verifique a internet do servidor e avise o suporte!')
            saveLog({'CTe ID: ', cte:getField('cte_id'), 'GETFILES - FTP: Falha ao fazer upload do XML'})
         endif
      else
         acao := 'SUBMIT'
         AAdd(msg, 'Arquivo XML não foi encontrado, solicitando novamente, aguarde...')
         saveLog({'CTe ID: ', cte:getField('cte_id'), 'GETFILES - Arquivo XML não encontrado', 'File: ' + xmlFile})
      endif
      
      up := NIL

      if hb_FileExists(pdfFile)
         up := TgedFTP():new(pdfFile, remotePath)
         if up:upload()
            s:add("cte_pdf = '" + up:getURL() + "', ")
            AAdd(msg, 'FTP: Upload do PDF executado com sucesso')
            saveLog({'CTe ID: ', cte:getField('cte_id'), 'GETFILES - FTP: Upload do PDF executado com sucesso'})
         else
            AAdd(msg, 'FTP: Falha ao fazer upload do PDF, verifique a internet do servidor e avise o suporte!')
            saveLog({'CTe ID: ', cte:getField('cte_id'), 'GETFILES - FTP: Falha ao fazer upload do PDF'})
         endif
      else
         acao := 'SUBMIT'
         AAdd(msg, 'Arquivo PDF não foi encontrado, solicitando novamente, aguarde...')
         saveLog({'CTe ID: ', cte:getField('cte_id'), 'GETFILES - Arquivo PDF não encontrado', 'File: ' + pdfFile})
      endif

      s:add("cte_getfiles_date = " + dateTime_hb_to_mysql(Date(), Time()) + ", ")      
      s:add("cte_monitor_action = '" + acao + "' ")
      s:add("WHERE cte_id = " + cte:getField('cte_id'))

      q := TSQLQuery():new(s:value)
      
      saveLog(s:value)  // Passar essa linha para baixo de !q:isExecuted() depois de verificar o SQL no log.

      if ! q:isExecuted()
         q:Destroy()
         RegistryWrite(::registryPath + "Monitoring\DontRun", 1)
         turnOFF()
      endif
      
      q:Destroy()
   
      // Nova Query
      s:setValue("INSERT INTO ctes_eventos (cte_id, cte_ev_protocolo, cte_ev_data_hora, cte_ev_evento, cte_ev_detalhe) VALUES ")

      i := 0

      for each e in msg
         i++
         s:add(iif((i==1), [(], [, (])) // Inicio dos VALUES
         s:add(cte:getField('cte_id') + ", ")
         s:add("'CTeMonitor', ")
         s:add(dateTime_hb_to_mysql(Date(), Time()) + ", ")
         s:add("'000', ")
         s:add("'" + string_hb_to_MySQL(e) + "')") // fechamento dos VALUES
      next

      if ! (i == 0)
         q := TSQLQuery():new(s:value)
         if ! q:isExecuted()
            saveLog(q:value)
            q:Destroy()
            turnOFF()
         endif
         q:Destroy()
         saveLog({'Atualizado TMS.CLOUD |CTe Id: ', cte:getField('cte_id'), ' |Atualizado ', hb_ntos(i), ' Evento(s) com sucesso'})
      endif
      
return
