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

// Atualziado: 2022-06-07 15:30 | Troca da propriedade tpAmb para xTpAmb class TACBrMonitor

procedure cte_generateXML(cte)
   local sefaz, p
   local emitente := appData:getCompanies(cte:InfCte:emit:id)

   if cte:validarCTe() .and. cte:criarCTeXML()
      // {'DFe' => ['CTe'|'MDFe'], 'chDFe' => , 'dfeId' => , 'sysPath' => , 'remotePath' => , 'situacao' => , 'emitCNPJ' => , 'dhEmi' => , 'tpAmb' => emitente:getField('tpAmb')}
      p := {'DFe' => 'CTe',;
            'chDFe' => cte:InfCte:Id:raw,;
             'dfeId' => cte:infCte:ide:cte_id,;
             'sysPath' => appData:systemPath,;
             'remotePath' => cte:remotePath,;
             'situacao' => cte:situacao,;
             'emitCNPJ' => cte:infCte:emit:CNPJ:value,;
             'dhEmi' => cte:infCte:ide:dhEmi:value,;
             'tpAmb' => emitente:getField('tpAmb')}   // Caracter '1' ou '2'

      sefaz := TACBrMonitor():new(p)

      if sefaz:ObterCertificado()
         if sefaz:Assinar() .and. sefaz:Validar()
            if !sefaz:Enviar()
               sefaz:StatusServico()
            endif
         endif
      endif
      updateCTeStatus(sefaz, cte)
   else
      updateCTeErrors(cte)
   endif

return

procedure updateCTeStatus(sefaz, up_cte)
   local adMsg := {}, msg := {'Atualizado TMS.CLOUD |CTe Id: '}
   local xml, pdf, i := 0
   local e, q, s := TSQLString():new("UPDATE ctes SET ")
   local xmlUpdated := False
   local pdfUpdated := False

   if (sefaz:situacao == 'TRANSMITIDO')
      sefaz:situacao := 'VALIDADO'
   endif
   
   s:add("cte_situacao = '" + sefaz:situacao + "', ")
   s:add("cte_chave = '" + sefaz:chDFe + "', ")

   if ValType(up_cte) == 'O'
      with object up_cte:infCte:imp
         s:add("cte_tem_difal = " + iif(:tem_difal, '1', '0') + ", ")
         s:add("pUF_inicio = " + :pICMSInter:value + ", ")
         s:add("pUF_fim = " + :pICMSUFFim:value + ", ")
         s:add("pFCP = " + :pFCPUFFim:value + ", ")
         s:add("vFCP = " + :vFCPUFFim:value + ", ")
         s:add("pDIFAL = " + :pDIFAL + ", ")
         s:add("vDIFAL = " + :vDIFAL + ", ")
         s:add("vICMS_uf_fim = " + :vICMSUFFim:value + ", ")
      endwith
   endif

   if (hmg_len(sefaz:events) == 0)
      AAdd(sefaz:events, {'dhRecbto' => dateTime_hb_to_mysql(Date(), Time()), 'nProt' => 'CTeMonitor', 'cStat' => '000', 'xMotivo' => 'Sem resposta da Sefaz, verifique seu servidor local | Ambiente de ' + sefaz:xTpAmb})
   endif

   for each e in sefaz:events
      // e = {'dhRecbto' => ::dhRecbto, 'nProt' => ::nRec, 'cStat' => ::cStat, 'xMotivo' => ::xMotivo + ' | Ambiente de ' + ::tpAmb}
      if e['cStat'] == '100' .and. !Empty(e['nProt'])
         s:add("cte_protocolo_autorizacao = '" + string_hb_to_MySQL(e['nProt']) + "', ")
         Exit
      endif
   next

   if (sefaz:situacao $ 'AUTORIZADO|CANCELADO|INUTILIZADO')
      if !Empty(sefaz:xmlName)
         xml := TgedFTP():new(sefaz:xmlName, sefaz:remotePath)
         if xml:upload()
            s:add("cte_xml = '" + xml:getURL() + "', ")
         endif
         xmlUpdated := xml:isUpload
      endif
      if !Empty(sefaz:xmlCancel)
         xml := TgedFTP():new(sefaz:xmlCancel, sefaz:remotePath)
         if xml:upload()
            s:add("cte_cancelado_xml = '" + xml:getURL() + "', ")
         endif
         xmlUpdated := xml:isUpload
      endif
      if !Empty(sefaz:pdfName)
         pdf := TgedFTP():new(sefaz:pdfName, sefaz:remotePath)
         if pdf:upload()
            s:add("cte_pdf = '" + pdf:getURL() + "', ")
         endif
         pdfUpdated := pdf:isUpload
      endif
      if !Empty(sefaz:pdfCancel)
         pdf := TgedFTP():new(sefaz:pdfCancel, sefaz:remotePath)
         if pdf:upload()
            s:add("cte_cancelado_pdf = '" + pdf:getURL() + "', ")
         endif
         pdfUpdated := pdf:isUpload
      endif
      adMsg := {' |PDF: ', iif(pdfUpdated, 'upload com sucesso', 'falha no upload'), ' |XML: ', iif(xmlUpdated, 'upload com sucesso', 'falha no upload')}
      // Se uma das duplas foram geradas, muda o status de ctes_arquivos_baixados para 1, que será usado pelo CTeMail
      if (!Empty(sefaz:xmlName) .and. !Empty(sefaz:pdfName)) .or. (!Empty(sefaz:xmlCancel) .and. !Empty(sefaz:pdfCancel))
         s:add("cte_arquivos_baixados = 1, ")
      endif
      if !xmlUpdated .or. !pdfUpdated
         AAdd(sefaz:events, {'dhRecbto' => dateTime_hb_to_mysql(Date(), Time()), 'nProt' => 'CTeMonitor', 'cStat' => '000', 'xMotivo' => 'FTP: Falha ao fazer upload do PDF/XML, verifique a internet do servidor, nova tentativa em 5 minutos. | Ambiente de ' + sefaz:xTpAmb})
         s:add("cte_getfiles_date = " + dateTime_hb_to_mysql(Date(), Time()) + ", ")
         s:add("cte_monitor_action = 'GETFILES' ")
      endif
   endif

   if ! ('GETFILES' $ s:value)
      s:add("cte_monitor_action = 'EXECUTED' ")
   endif

   s:add("WHERE cte_id = " + sefaz:dfe_id)

   q := TSQLQuery():new(s:value)
   
   if !q:isExecuted()
      q:Destroy()
      RegistryWrite(::registryPath + "Monitoring\DontRun", 1)
      turnOFF()
   endif
   q:Destroy()
   AAdd(msg, sefaz:dfe_id)
   AAdd(msg, ' |Situação do CTe: ')
   AAdd(msg, sefaz:situacao)
   for each e in adMsg
      AAdd(msg, e)
   next

   saveLog(msg)

   if Empty(sefaz:events)
      saveLog('Erro: Não foi inserido eventos para o upload')
      return
   endif
   s:setValue("INSERT INTO ctes_eventos (cte_id, cte_ev_protocolo, cte_ev_data_hora, cte_ev_evento, cte_ev_detalhe) VALUES ")

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
   saveLog({'Atualizado TMS.CLOUD |CTe Id: ', sefaz:dfe_id, ' |Atualizado ', hb_ntos(i), ' Evento(s) com sucesso'})
return

procedure updateCTeErrors(cte_sefaz, eventStatus)
   local k := i := 0, cId, e
   local msg, q
   local s := TSQLString():new("UPDATE ctes SET ")

   default eventStatus := False

   if eventStatus
      cId := cte_sefaz:dfe_id
   else
      cId := cte_sefaz:infCte:ide:cte_id
      s:add("cte_situacao = 'REJEITADO', " )
   endif
   s:add("cte_monitor_action = 'EXECUTED' " )
   s:add("WHERE cte_id = " + cId)
   q := TSQLQuery():new(s:value)

   if !q:isExecuted()
      return
   endif
   q:Destroy()
   saveLog({'Atualizado TMS.CLOUD |CTe Id: ', cId, ' |Evento do CTe: REJEITADO'})

   s:setValue("INSERT INTO ctes_eventos (cte_id, cte_ev_protocolo, cte_ev_data_hora, cte_ev_evento, cte_ev_detalhe) VALUES ")
   if eventStatus
      s:add("(")
      s:add(cId + ", ")
      s:add("'CTeMonitor', ") // cte_ev_protocolo
      s:add(dateTime_hb_to_mysql(Date(), Time()) + ", ") // cte_ev_data_hora
      s:add("'N/A', ") // cte_ev_evento
      s:add("'EVENTO REJEITADO - VERIFICAR COM O SUPORTE')") // cte_ev_detalhe e fechamento dos VALUES
      i := 1
   else
      with object cte_sefaz:infCte:ide
         for each msg in cte_sefaz:msgError
            i++
            msg := StrTran(msg, hb_eol(), '; ')
            s:add(iif((i==1), [(], [, (])) // Inicio dos VALUES
            s:add(:cte_id + ", ")
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

   // eventStatus = true quando cancelCTe() e inutilizeCTe()
   if eventStatus .and. !Empty(cte_sefaz:events)
      
      s:setValue("INSERT INTO ctes_eventos (cte_id, cte_ev_protocolo, cte_ev_data_hora, cte_ev_evento, cte_ev_detalhe) VALUES ")

      for each e in cte_sefaz:events
         // e = {'dhRecbto' => ::dhRecbto, 'nProt' => ::nRec, 'cStat' => ::cStat, 'xMotivo' => ::xMotivo + ' | Ambiente de ' + ::tpAmb}
         k++
         s:add(iif((k==1), [(], [, (])) // Inicio dos VALUES
         s:add(cte_sefaz:dfe_id + ", ")
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
   
   endif
   saveLog({'Atualizado TMS.CLOUD |CTe Id: ', cId, ' |Atualizado ', hb_ntos(k+i), ' Evento(s) com sucesso'})

return
