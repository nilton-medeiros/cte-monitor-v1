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
      local qCte, rowCTe, e, n := 1, 
      local sql := TSQLString():new()

      sql:setValue("SELECT cte_id, ")
      sql:add("emp_id, ")
      sql:add("cte_numero, ")
      sql:add("cte_chave ")
      sql:add("FROM view_ctes ")

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
      sql:add(" AND TIMESTAMPDIFF(MINUTE , cte_getfiles_date, " + dateTime_hb_to_mysql(Date(), Time()) + ") > 5 ")
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
      local up
      local s := TSQLString():new("UPDATE ctes SET ")

      if hb_FileExists(xmlFile)
         up := TgedFTP():new(xmlFile, remotePath)
      if up:upload()
         s:add("cte_xml = '" + up:getURL() + "', ")
      endif


return
