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
#define ENCRYPTED true

procedure mdfe_generateXML(mdfe)
   local sefaz, p
   local emitente := appData:getCompanies(mdfe:InfMDFe:emit:id)

   if mdfe:ValidarMDFe() .and. mdfe:criarMDFeXML()
      // {'DFe' => ['CTe'|'MDFe'], 'chDFe' => , 'dfeId' => , 'sysPath' => , 'remotePath' => , 'situacao' => , 'emitCNPJ' => , 'dhEmi' => , 'tpAmb' => emitente:getField('tpAmb')}
      p := {'DFe' => 'MDFe',;
            'chDFe' => mdfe:infMDFe:Id:raw,;
             'dfeId' => mdfe:infMDFe:ide:mdfe_id,;
             'sysPath' => appData:systemPath,;
             'remotePath' => mdfe:remotePath,;
             'situacao' => mdfe:situacao,;
             'emitCNPJ' => mdfe:infMDFe:emit:CNPJ:value,;
             'dhEmi' => mdfe:infMDFe:ide:dhEmi:value,;
             'tpAmb' => emitente:getField('tpAmb')}

      sefaz := TACBrMonitor():new(p)
      if sefaz:Assinar() .and. sefaz:Validar()
         if !sefaz:Enviar()
            if sefaz:StatusServico()
               sefaz:Consultar()
            endif
         endif
      endif
      updateMDFeStatus(sefaz)
   else
      updateMDFeErrors(mdfe)
   endif

return

procedure updateMDFeStatus(sefaz)
   local adMsg := {}, msg := {'Atualizado TMS.CLOUD |MDFe Id: '}
   local xml, pdf, i := 0
   local xmlUpdated := False
   local pdfUpdated := False
   local e, q, s := TSQLString():new("UPDATE mdfes SET ")

   if (sefaz:situacao == 'TRANSMITIDO')
      sefaz:situacao := 'DIGITAÇÃO'
   endif
   s:add("situacao = '" + STRING_HB_TO_MySQL(sefaz:situacao) + "', ")
   s:add("cMDF = '" + sefaz:chDFe + "', ")

   if (hmg_len(sefaz:events) == 0)
      AAdd(sefaz:events, {'dhRecbto' => dateTime_hb_to_mysql(Date(), Time()), 'nProt' => 'CTeMonitor', 'cStat' => '000', 'xMotivo' => 'Sem resposta da Sefaz, verifique seu servidor local | Ambiente de ' + sefaz:xTpAmb})
   endif

   for each e in sefaz:events
      // e = {'dhRecbto' => ::dhRecbto, 'nProt' => ::nRec, 'cStat' => ::cStat, 'xMotivo' => ::xMotivo + ' | Ambiente de ' + ::tpAmb}
      if e['cStat'] == '100' .and. !Empty(e['nProt'])
         s:add("nProt = '" + string_hb_to_MySQL(e['nProt']) + "', ")
         Exit
      endif
   next

   if (sefaz:situacao $ 'AUTORIZADO|CANCELADO|ENCERRADO')
      if !Empty(sefaz:xmlName)
         xml := TgedFTP():new(sefaz:xmlName, sefaz:remotePath)
         if xml:upload()
            s:add("`xml` = '" + xml:getURL() + "', ")
         endif
         xmlUpdated := xml:isUpload
      endif
      if !Empty(sefaz:xmlCancel)
         xml := TgedFTP():new(sefaz:xmlCancel, sefaz:remotePath)
         if xml:upload()
            s:add("cancelado_xml = '" + xml:getURL() + "', ")
         endif
         xmlUpdated := xml:isUpload
      endif
      if !Empty(sefaz:pdfName)
         pdf := TgedFTP():new(sefaz:pdfName, sefaz:remotePath)
         if pdf:upload()
            s:add("pdf = '" + pdf:getURL() + "', ")
         endif
         pdfUpdated := pdf:isUpload
      endif
      if !Empty(sefaz:pdfCancel)
         pdf := TgedFTP():new(sefaz:pdfCancel, sefaz:remotePath)
         if pdf:upload()
            s:add("cancelado_pdf = '" + pdf:getURL() + "', ")
         endif
         pdfUpdated := pdf:isUpload
      endif
      adMsg := {' |PDF: ', iif(pdfUpdated, 'upload com sucesso', 'falha no upload'), ' |XML: ', iif(xmlUpdated, 'upload com sucesso', 'falha no upload')}
      if !xmlUpdated .or. !pdfUpdated
         AAdd(sefaz:events, {'dhRecbto' => dateTime_hb_to_mysql(Date(), Time()), 'nProt' => 'CTeMonitor', 'cStat' => '000', 'xMotivo' => 'FTP: Falha ao fazer upload do PDF/XML, avise ao suporte | Ambiente de ' + sefaz:xTpAmb})
      endif

   endif

   s:add("cte_monitor_action = 'EXECUTED' " )
   s:add("WHERE id = " + sefaz:dfe_id)
   q := TSQLQuery():new(s:value)
   saveLog('mdfe: SQL: ' + s:value, ENCRYPTED)
   if !q:isExecuted()
      q:Destroy()
      return
   endif
   q:Destroy()
   AAdd(msg, sefaz:dfe_id)
   AAdd(msg, ' |Situação do MDFe: ')
   AAdd(msg, sefaz:situacao)
   for each e in adMsg
      AAdd(msg, e)
   next

   saveLog(msg)

   if Empty(sefaz:events)
      saveLog('Erro: Não foi inserido eventos para o upload')
      return
   endif

   s:setValue("INSERT INTO mdfes_eventos (mdfe_id, protocolo, data_hora, evento, detalhe) VALUES ")
   for each e in sefaz:events
      // e = {'dhRecbto' => ::dhRecbto, 'nProt' => ::nRec, 'cStat' => ::cStat, 'xMotivo' => ::xMotivo + ' | Ambiente de ' + ::tpAmb}
      i++
      s:add(iif((i==1), [(], [, (])) // Inicio dos VALUES
      s:add(sefaz:dfe_id + ", ")
      s:add("'" + string_hb_to_MySQL(e['nProt']) + "', ")
      s:add(e['dhRecbto'] + ", ")
      s:add("'" + string_hb_to_MySQL(e['cStat']) + "', ")
      e['xMotivo'] := StrTran(e['xMotivo'], '; ;', ';')
      s:add("'" + string_hb_to_MySQL(e['xMotivo']) + "')") // fechamento dos VALUES
   next
   q := TSQLQuery():new(s:value)
   if !q:isExecuted()
      q:Destroy()
      turnOFF()
   endif
   q:Destroy()
   saveLog({'Atualizado TMS.CLOUD |MDFe Id: ', sefaz:dfe_id, ' |Atualizado ', hb_ntos(i), ' Evento(s) com sucesso'})
return

procedure updateMDFeErrors(c, eventStatus)
   local i := 0
   local msg, q, cId
   local s := TSQLString():new("UPDATE mdfes SET ")

   default eventStatus := False

   if eventStatus
      cId := c:dfe_id
      if (c:situacao == 'ENCERRADO')
         s:add("situacao = 'ENCERRADO', " )
      endif
   else
      cId := c:infMDFe:ide:mdfe_id
      s:add("situacao = 'REJEITADO', " )
   endif
   s:add("cte_monitor_action = 'EXECUTED' " )
   s:add("WHERE id = " + cId)

   q := TSQLQuery():new(s:value)

   if !q:isExecuted()
      return
   endif
   q:Destroy()
   saveLog({'Atualizado TMS.CLOUD |MDFe Id: ', cId, ' |Evento do MDFe: REJEITADO'})

   s:setValue("INSERT INTO mdfes_eventos (mdfe_id, protocolo, data_hora, evento, detalhe) VALUES ")
   if eventStatus
      s:add("(")
      s:add(cId + ", ")
      s:add("'CTeMonitor', ") // cte_ev_protocolo
      s:add(dateTime_hb_to_mysql(Date(), Time()) + ", ") // cte_ev_data_hora
      s:add("'N/A', ") // cte_ev_evento
      s:add("'EVENTO REJEITADO - VERIFICAR COM O SUPORTE | Status: " + c:situacao + "')") // cte_ev_detalhe e fechamento dos VALUES
      i := 1
   else
      with object c:infMDFe:ide
         for each msg in c:msgError
            i++
            msg := StrTran(msg, hb_eol(), '; ')
            s:add(iif((i==1), [(], [, (])) // Inicio dos VALUES
            s:add(cId + ", ")
            s:add("'CTeMonitor', ") // cte_ev_protocolo
            s:add(dateTime_hb_to_mysql(Date(), Time()) + ", ") // cte_ev_data_hora
            s:add("'N/A', ") // cte_ev_evento
            s:add("'" + string_hb_to_MySQL(msg) + "')") // cte_ev_detalhe e fechamento dos VALUES
         next
      endwith
   endif
   q := TSQLQuery():new(s:value)
   if !q:isExecuted()
      q:Destroy()
      turnOFF()
   endif
   q:Destroy()
   saveLog({'Atualizado TMS.CLOUD |MDFe Id: ', cId, ' |Atualizado ', hb_ntos(i), ' Evento(s) com sucesso'})

return
