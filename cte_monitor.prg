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

// Atualizado: 2022-05-29 15:00
procedure monitorCTe()
      local sql := TSQLString():new()
      local queryCTe
      local rowCTe
      local inutilizarFaixa := {}
      local empIdModSerie, p, e, n := 1

      sql:setValue("SELECT cte_id AS id, ")
      sql:add("emp_id, ")
      sql:add("cte_versao_leiaute_xml AS versao_xml, ")
      sql:add("cte_data_hora_emissao AS dhEmi, ")
      sql:add("cte_modelo AS modelo, ")
      sql:add("cte_serie AS serie, ")
      sql:add("cte_numero AS nCT, ")
      sql:add("cte_minuta AS cCT, ")
      sql:add("cte_situacao AS situacao, ")
      sql:add("cte_chave AS chCTe, ")
      sql:add("cte_protocolo_autorizacao AS nProt, ")
      sql:add("cte_cfop AS CFOP, ")
      sql:add("cte_natureza_operacao AS natOp, ")
      sql:add("cte_forma_emissao AS tpEmis, ")
      sql:add("cte_tipo_do_cte AS tpCTe, ")
      sql:add("cte_modal AS modal, ")
      sql:add("cte_tipo_servico AS tpServ, ")
      sql:add("cid_origem_codigo_municipio AS cMunIni, ")
      sql:add("cid_origem_municipio AS xMunIni, ")
      sql:add("cid_origem_uf AS UFIni, ")
      sql:add("cid_destino_codigo_municipio AS cMunFim, ")
      sql:add("cid_destino_municipio AS xMunFim, ")
      sql:add("cid_destino_uf AS UFFim, ")
      sql:add("cte_retira AS retira, ")
      sql:add("cte_detalhe_retira AS xDetRetira, ")
      sql:add("clie_tomador_id, ")
      sql:add("tom_icms AS indIEToma, ")
      sql:add("tom_ie_isento, ")
      sql:add("cte_tomador, ")
      sql:add("tom_cnpj, ")
      sql:add("tom_ie, ")
      sql:add("tom_cpf, ")
      sql:add("tom_nome_fantasia AS tom_xFant, ")
      sql:add("tom_razao_social AS tom_xNome, ")
      sql:add("tom_fone, ")
      sql:add("tom_end_logradouro, ")
      sql:add("tom_end_numero, ")
      sql:add("tom_end_complemento, ")
      sql:add("tom_end_bairro, ")
      sql:add("tom_cid_codigo_municipio, ")
      sql:add("tom_cid_municipio, ")
      sql:add("tom_end_cep, ")
      sql:add("tom_cid_uf, ")
      sql:add("cte_carac_adic_transp AS xCaracAd, ")
      sql:add("cte_carac_adic_servico AS xCaracSer, ")
      sql:add("cte_emissor AS xEmi, ")
      sql:add("cid_origem_sigla AS xOrig, ")
      sql:add("cid_passagem_sigla AS xPass, ")
      sql:add("cid_destino_sigla AS xDest, ")
      sql:add("cte_tp_data_entrega AS tpPer, ")
      sql:add("cte_data_programada AS dProg, ")
      sql:add("cte_data_inicial AS dIni, ")
      sql:add("cte_data_final AS dFim, ")
      sql:add("cte_tp_hora_entrega AS tpHor, ")
      sql:add("cte_hora_programada AS hProg, ")
      sql:add("cte_hora_inicial AS hIni, ")
      sql:add("cte_hora_final AS hFim, ")
      sql:add("cte_obs_gerais AS xObs, ")
      sql:add("clie_remetente_id, ")
      sql:add("rem_razao_social, ")
      sql:add("rem_nome_fantasia, ")
      sql:add("rem_cnpj, ")
      sql:add("rem_ie, ")
      sql:add("rem_cpf, ")
      sql:add("rem_fone, ")
      sql:add("rem_end_logradouro, ")
      sql:add("rem_end_numero, ")
      sql:add("rem_end_complemento, ")
      sql:add("rem_end_bairro, ")
      sql:add("rem_cid_codigo_municipio, ")
      sql:add("rem_cid_municipio, ")
      sql:add("rem_end_cep, ")
      sql:add("rem_cid_uf, ")
      sql:add("rem_icms, ")
      sql:add("clie_destinatario_id, ")
      sql:add("des_razao_social, ")
      sql:add("des_nome_fantasia, ")
      sql:add("des_cnpj, ")
      sql:add("des_ie, ")
      sql:add("des_cpf, ")
      sql:add("des_fone, ")
      sql:add("des_end_logradouro, ")
      sql:add("des_end_numero, ")
      sql:add("des_end_complemento, ")
      sql:add("des_end_bairro, ")
      sql:add("des_cid_codigo_municipio, ")
      sql:add("des_cid_municipio, ")
      sql:add("des_end_cep, ")
      sql:add("des_cid_uf, ")
      sql:add("des_icms, ")
      sql:add("clie_expedidor_id, ")
      sql:add("exp_razao_social, ")
      sql:add("exp_nome_fantasia, ")
      sql:add("exp_cnpj, ")
      sql:add("exp_ie, ")
      sql:add("exp_cpf, ")
      sql:add("exp_fone, ")
      sql:add("exp_end_logradouro, ")
      sql:add("exp_end_numero, ")
      sql:add("exp_end_complemento, ")
      sql:add("exp_end_bairro, ")
      sql:add("exp_cid_codigo_municipio, ")
      sql:add("exp_cid_municipio, ")
      sql:add("exp_end_cep, ")
      sql:add("exp_cid_uf, ")
      sql:add("exp_icms, ")
      sql:add("clie_recebedor_id, ")
      sql:add("rec_razao_social, ")
      sql:add("rec_nome_fantasia, ")
      sql:add("rec_cnpj, ")
      sql:add("rec_ie, ")
      sql:add("rec_cpf, ")
      sql:add("rec_fone, ")
      sql:add("rec_end_logradouro, ")
      sql:add("rec_end_numero, ")
      sql:add("rec_end_complemento, ")
      sql:add("rec_end_bairro, ")
      sql:add("rec_cid_codigo_municipio, ")
      sql:add("rec_cid_municipio, ")
      sql:add("rec_end_cep, ")
      sql:add("rec_cid_uf, ")
      sql:add("rec_icms, ")
      sql:add("cte_valor_total AS vTPrest, ")
      sql:add("cte_valor_bc AS vBC, ")
      sql:add("cte_aliquota_icms AS pICMS, ")
      sql:add("cte_valor_icms AS vICMS, ")
      sql:add("cte_perc_reduc_bc AS pRedBC, ")
      sql:add("cte_valor_cred_outorgado AS vCred, ")
      sql:add("cte_codigo_sit_tributaria, ")
      sql:add("cte_valor_pis AS vPIS, ")
      sql:add("cte_valor_cofins AS vCOFINS, ")
      sql:add("cte_valor_icms + cte_valor_pis + cte_valor_cofins AS vTotTrib, ")
      sql:add("cte_info_fisco AS infAdFisco, ")
      sql:add("cte_valor_carga AS vCarga, ")
      sql:add("produto_predominante_nome AS proPred, ")
      sql:add("gt_id_codigo AS cTar, ")
      sql:add("cte_outras_carac_carga AS xOutCat, ")
      sql:add("cte_peso_bruto, ")
      sql:add("cte_peso_cubado, ")
      sql:add("cte_peso_bc, ")
      sql:add("cte_cubagem_m3, ")
      sql:add("cte_qtde_volumes, ")
      sql:add("cte_tipo_doc_anexo, ")
      sql:add("cte_operacional_master AS nOCA, ")
      sql:add("cte_data_entrega_prevista AS dPrevAereo, ")
      sql:add("cte_monitor_action ")
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

      sql:add(" AND cte_monitor_action IN ('SUBMIT','GETFILES','CANCEL','INUTILIZE') ")
      sql:add("ORDER BY cte_monitor_action, emp_id, cte_numero")
      queryCTe := TSQLQuery():new(sql:value)
      if queryCTe:isExecuted()

         do while !queryCTe:EOF()

            rowCTe := TModifyToHb():new(queryCTe:getRow())
            appData:setUTC(rowCTe:getField('emp_id'))

            switch rowCTe:getField('cte_monitor_action')
               case 'SUBMIT'
                  submitCTe(rowCTe)
                  exit
               case 'GETFILES'
                  submitCTe(rowCTe)
                  exit
               case 'CANCEL'
                  cancelCTe(rowCTe)
                  exit
               case 'INUTILIZE'
                  empIdModSerie := rowCTe:zeroFill('emp_id', 5) + rowCTe:getField('modelo') + rowCTe:seroFill('serie', 3)
                  p := hb_AScan(inutilizarFaixa, {|key| key['chave'] == empIdModSerie})
                  if (p == 0)
                     AAdd(inutilizarFaixa, {'chave' => empIdModSerie, 'inutCTe' => {}})
                     p := hmg_len(inutilizarFaixa)
                  endif
                  AAdd(inutilizarFaixa[p]['inutCTe'], rowCTe)
                  exit
            endswitch

            queryCte:Skip()
            DO EVENTS

         enddo

         if !(hmg_len(inutilizarFaixa) == 0)
            inutilizeCTe(inutilizarFaixa)
         endif

      endif

      queryCte:Destroy()

return

procedure submitCTe(rowCTe)
   local sql := TSQLString():new(), where := TSQLString():new()
   local queryObs, queryCompCalc, queryDoc
   local cte, xmlFile

   msgNotify({'notifyTooltip' => "Gereando CTe " + rowCTe:getField('nCT')})

   sql:setValue("SELECT cte_ocf_titulo AS xCampo, cte_ocf_texto AS xTexto, cte_ocf_interessado AS interessado ")
   sql:add("FROM ctes_obs_contr_fisco ")
   sql:add("WHERE cte_id = " + rowCTe:getField('id') + " ")
   sql:add("ORDER BY cte_ocf_interessado, cte_ocf_id ")
   queryObs := TSQLQuery():new(sql:value)
   if !queryObs:isExecuted()
      //MsgDebug(queryObs)
      queryObs:Destroy()
      turnOFF()
   endif

   sql:setValue("SELECT ")
   sql:add("ccc_titulo AS xNome, ")
   sql:add("ccc_valor AS vComp, ")
   sql:add("ccc_tipo_tarifa AS CL, ")
   sql:add("ccc_valor_tarifa_kg AS vTar ")
   sql:add("FROM ctes_comp_calculo ")
   sql:add("WHERE cte_id = " + rowCTe:getField('id') + " ")
   sql:add("AND (ccc_exibir_valor_dacte = 1 OR ccc_valor > 0)")
   queryCompCalc := TSQLQuery():new(sql:value)
   if !queryCompCalc:isExecuted()
      //MsgDebug(queryCompCalc)
      queryCompCalc:Destroy()
      turnOFF()
   endif

   // Documentos anexos ao CTe
   sql:setValue("SELECT ")
   where:setValue("WHERE cte_id = " + rowCTe:getField('id') + " ")

   switch rowCTe:getField('cte_tipo_doc_anexo')
      case '1' // 1-Nota Fiscal
         sql:add("cte_doc_modelo AS modelo, ")
         sql:add("cte_doc_serie AS serie, ")
         sql:add("cte_doc_bc_icms AS vBC, ")
         sql:add("cte_doc_valor_icms AS vICMS, ")
         sql:add("cte_doc_bc_icms_st AS vBCST, ")
         sql:add("cte_doc_valor_icms_st AS vST, ")
         sql:add("cte_doc_valor_produtos AS vProd, ")
         sql:add("cte_doc_valor_nota AS vNF, ")
         sql:add("cte_doc_cfop AS nCFOP, ")
         sql:add("cte_doc_peso_total AS nPeso, ") // Continua com mais campos a baixo
         where:add("AND cte_doc_numero IS NOT NULL AND cte_doc_numero != '' ") // WHERE para cada caso
         where:add("AND cte_doc_serie IS NOT NULL ")
//       where:add("AND cte_doc_serie IS NOT NULL AND cte_doc_serie != '' ")                   // série = 0 é considerada '', acaba não entrando neste where
         exit
      case '2' // 2-NFe
         sql:add("cte_doc_chave_nfe AS chave, ") // Continua com mais campos a baixo
         where:add("AND cte_doc_chave_nfe IS NOT NULL AND cte_doc_chave_nfe != '' ")
         exit
      case '3' // 3-Declaração
         sql:add("cte_doc_tipo_doc AS tpDoc, ")
         sql:add("cte_doc_descricao AS descOutros, ")
         sql:add("cte_doc_valor_nota AS vDocFisc, ") // Continua com mais campos a baixo
         where:add("AND cte_doc_tipo_doc IS NOT NULL ")
         exit
   endswitch

   sql:add("cte_doc_numero AS nDoc, ")
   sql:add("cte_doc_pin AS PIN, ")
   sql:add("cte_doc_data_emissao AS dEmi ")
   sql:add("FROM ctes_documentos ")
   sql:add(where:value)
   queryDoc := TSQLQuery():new(sql:value)
   //saveLog({"SQL de cte_documentos:", hb_eol(), sql:value})
   
   if !queryDoc:isExecuted()
      //MsgDebug(queryDoc)
      queryDoc:Destroy()
      turnOFF()
   endif
   cte := cte_createObject(rowCTe, queryObs, queryCompCalc, queryDoc)
   queryObs:Destroy()
   queryCompCalc:Destroy()
   queryDoc:Destroy()
   cte_generateXML(cte, rowCTe:getField('cte_monitor_action'))
   cte := Nil
   msgNotify()

return

procedure cancelCTe(cte)
   local sefaz, p
   local emitente := appData:getCompanies(cte:getField('emp_id'))
   msgNotify({'notifyTooltip' => "Cancelando CTe " + cte:getField('id')})

   // {'DFe' => ['CTe'|'MDFe'], 'chDFe' => , 'dfeId' => , 'sysPath' => , 'remotePath' => , 'situacao' => , 'emitCNPJ' => , 'dhEmi' => , 'tpAmb' => emitente:getField('tpAmb')}
   p := {'DFe' => 'CTe',;
         'chDFe' => cte:getField('chCTe'),;
         'nProt' => cte:getField('nProt'),;
         'dfeId' => cte:getField('id'),;
         'sysPath' => appData:systemPath,;
         'remotePath' => emitente:getField('remote_file_path') + '/ctes/files',;
         'situacao' => cte:getField('situacao'),;
         'emitCNPJ' => emitente:getField('CNPJ'),;
         'dhEmi' => cte:getField({'field_name_or_number' => "dhEmi", 'dateTime_as_TDZ' => True}),;
         'tpAmb' => emitente:getField('tpAmb')}

   sefaz := TACBrMonitor():new(p)
   if sefaz:Cancelar()
      updateCTeStatus(sefaz)
   else
      updateCTeErrors(sefaz, True)
   endif
   msgNotify()
return

procedure inutilizeCTe(faixa)
   local mod, serie
   local sefaz, p1, p2, nCT, cte
   local empIdModSerie := ''
   local incIni := faixaInicial := 0
   local faixaFinal
   local emitente := appData:getCompanies(cte:getField('emp_id'))
   local inuFaixa, anoMes := SubStr(DToS(Date()), 3, 4)

   msgNotify({'notifyTooltip' => "Inutizando faixa de CTe..."})
   // {'DFe' => ['CTe'|'MDFe'], 'chDFe' => , 'dfeId' => , 'sysPath' => , 'remotePath' => , 'situacao' => , 'emitCNPJ' => , 'dhEmi' => , 'tpAmb' => emitente:getField('tpAmb')}
   p1 := {'DFe' => 'CTe',;
          'chDFe' => '00000000000000000000000000000000000000000000',;
          'dfeId' => 0,;
          'sysPath' => appData:systemPath,;
          'remotePath' => emitente:getField('remote_file_path') + '/ctes/files',;
          'situacao' => "INUTILIZADO",;
          'emitCNPJ' => emitente:getField('CNPJ'),;
          'dhEmi' => DToS(Date()) + 'T' + Time(),;
          'tpAmb' => emitente:getField('tpAmb')}
   sefaz := TACBrMonitor():new(p1)

   // {'chave' => empIdModSerie, 'inutCTe' => {}}

   for each inuFaixa in faixa
      if !(empIdModSerie == inuFaixa['chave'])
         empIdModSerie := inuFaixa['chave']
      endif
      for each cte in inuFaixa['inutCTe']
         nCT := cte:getField({'field_name_or_number' => "nCT", 'number_as_string' => False})
         if !((++incIni) == nCT)
            incIni := nCT
            if (faixaInicial == 0)
               faixaInicial := incIni
            else
               mod := SubStr(inuFaixa['chave'], 6, 2)
               serie := SubStr(inuFaixa['chave'], 8, 3)
               p2 := {'xJust' => nCT:getField('inutJust'),;
                      'mod' => mod,;
                      'serie' => serie,;
                      'numInicial' => faixaInicial,;
                      'numFinal' => faixaFinal,;  // 35 2003 13559178000119 57 001 000016677 1000296341
                      'chave' => emitente:getField('cUF') + anoMes + emitente:getField('CNPJ') + mod + serie + padL(faixaInicial, 9, '0') + padL(faixaFinal, 10, '0')}
               sefaz:Inutilizar(p2)
               updateCTeStatus(sefaz)
               faixaInicial := nCT
            endif
         endif
         faixaFinal := nCT
      next
      mod := SubStr(inuFaixa['chave'], 6, 2)
      serie := SubStr(inuFaixa['chave'], 8, 3)
      p2 := {'xJust' => cte:getField('xObs'), 'mod' => mod, 'serie' => serie, 'numInicial' => faixaInicial, 'numFinal' => faixaFinal}
      if sefaz:Inutilizar(p2)
         updateCTeStatus(sefaz)
      else
         updateCTeErrors(sefaz, True)
      endif
   next
   msgNotify()
return
