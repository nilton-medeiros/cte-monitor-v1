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

// Atualizado: 2022-05-29 15:00
function mdfe_createObject(mdfe_record)
   local mdfe := TMDFe():new(appData:ACBr, appData:UTC, appData:systemPath)
   local emitente := appData:getCompanies(mdfe_record:getField('emp_id'))

   // Inicio: atribuição de dados
   mdfe:situacao := mdfe_record:getField('situacao')
   mdfe:remotePath := emitente:getField('remote_file_path') + '/mdf/files'

   // Fornece os primeiros campos para gerar a chave do CTe
   mdfeKey_firstFields(mdfe, emitente, mdfe_record)

   // infMDFe | Informações do MDF-e
   mdfe:infMDFe:versao:value := emitente:getField('versao_xml')
   // :infMDFe:Id gerado na Validação automaticamente

   // ide | Identificação do MDF-e
   ideMDFe(mdfe:infMDFe:ide, mdfe_record, emitente)

   // emit | Identificação do Emitente do Manifesto
   emitMDFe(mdfe:infMDFe:emit, emitente)

   // infModal:rodo | Informações do modal Rodoviário
   rodoMDFe(mdfe:infMDFe:infModal:rodo, mdfe_record, emitente)

   // infModal:infDoc | Informações dos Documentos fiscais vinculados ao manifesto
   infDocMDFe(mdfe:infMDFe:infDoc, mdfe_record:getField('id'))

   // seg | Informações de Seguro da Carga
   segMDFe(mdfe:infMDFe, emitente, mdfe_record:getField('id'))

   // prodPred | Grupo de informações do Produto predominante da carga do MDF-e
   prodPred(mdfe:infMDFe:prodPred, mdfe_record:getField('id'), mdfe:infMDFe:emit:enderEmit:CEP:value)

   // tot | Totalizadores da carga transportada e seus documentos fiscais
   totMDFe(mdfe:infMDFe:tot, mdfe_record)

   // autXML | Autorizados para download do XML do DF-e
   autXML_MDFe(mdfe:infMDFe)

   // infAdic | Informações Adicionais
   with object mdfe:infMDFe:infAdic
      :infAdFisco:value := mdfe_record:getField('infAdFisco')
      :infCpl:value := mdfe_record:getField('infCpl')
   endwith

   // infRespTec | Informações do Responsável Técnico pela emissão do DF-e
   with object mdfe:infMDFe:infRespTec
      :submit := True
      :CNPJ:value := "11568220000132"
      :CNPJ:raw := "11568220000132"
      :xContato:value := "Nilton Goncalves Medeiros"
      :email:value := "nilton@sistrom.com.br"
      :fone:value := "1125020108"
      /* Os campos abaixos não foram implementados pela Sefaz ainda
         * idCSRT // Identificador do código de segurança do responsável técnico
         * hashCSRT // Hash do token do código de segurança do responsável técnico
         * Ao implementar, não esquecer de habilitar a validação desses campos na classe TCTe linha 657 e 658 respectivamente
      */
   endwith

return mdfe

procedure mdfeKey_firstFields(mdfe, emitente, mdfe_record)
   // Fornece os primeiros campos para gerar a chave do MDFe
   mdfe:infMDFe:emit:CNPJ:value := emitente:getField('CNPJ')
   mdfe:infMDFe:emit:CNPJ:raw := onlyNumbers(emitente:getField('CNPJ'))
   // ide | Identificação do MDF-e
   with object mdfe:infMDFe:ide
      :mdfe_id := mdfe_record:getField('id')
      :cUF:value := emitente:getField('cUF')
      :dhEmi:value := mdfe_record:getField({'field_name_or_number' => "dhEmi", 'dateTime_as_TDZ' => True})
      :mod:value := mdfe_record:getField('modelo')
      :serie:raw := mdfe_record:getField('serie')
      :serie:value := mdfe_record:zeroFill('serie', 3)
      :nMDF:raw := mdfe_record:getField('nMDF')
      :nMDF:value := mdfe_record:zeroFill('nMDF', 9)
      :cMDF:raw := mdfe_record:getField('id')
      :cMDF:value := mdfe_record:zeroFill('id', 8)
      :tpEmis:value := mdfe_record:getField('tpEmis')
      :tpEmis:raw := onlyNumbers(:tpEmis:value)
   end
return

procedure ideMDFe(ide, record, emitente)
   local q
   local s := TSQLString():new('SELECT t1.cid_origem_codigo_municipio AS cMunCarrega, ')

   s:add('t1.cid_origem_municipio AS xMunCarrega ')
   s:add('FROM view_ctes AS t1 ')
   s:add('INNER JOIN mdfes_ctes AS t2 ON t2.ctes_id = t1.cte_id ')
   s:add('WHERE t2.mdfe_id = ' + ide:mdfe_id + ' ')
   s:add('GROUP BY t1.cid_origem_codigo_municipio, t1.cid_origem_municipio')

   q := TSQLQuery():new(s:value)

   with object ide
      // mdfe_id|cUF|mod|serie|nMDF|cMDF|tpEmis Gerado em mdfeKey_firstFields()
      :tpAmb:value := emitente:getField('tpAmb')
      :tpEmit:value := record:getField('tpEmit')
      :tpTransp:value := '' // 1 - ETC: Transporte Rodoviário de Cargas
      // :cDV: Gerado em generateKeyMDFe() ao validarMDFe()
      /* ATENÇÃO - MDFe - modal size é 1 e sempre é rodoviário '01' */
      :modal:value := '1' // Right(emitente:getField('modal'), 1)
      :procEmi:value := record:getField('procEmi')
      :verProc:value := record:getField('verProc')
      :UFIni:value := record:getField('UFIni')
      :UFFim:value := record:getField('UFFim')

      if q:isExecuted()
         do while !q:EOF()
            :add_infMunCarrega({'cMunCarrega' => q:getField('cMunCarrega'), 'xMunCarrega' => q:getField('xMunCarrega')})
            q:Skip()
         enddo
      endif
      q:Destroy()

      s:setValue('SELECT DISTINCT UFPer FROM mdfes_percurso ')
      s:add("WHERE mdfe_id = " + ide:mdfe_id + " ")
      s:add("AND UFPer IS NOT NULL AND UFPer != '' ")
      s:add("ORDER BY id")

      q := TSQLQuery():new(s:value)
      if q:isExecuted()
         do while !q:EOF()
            :add_infPercurso({'UFPer' => q:getField('UFPer')})
            q:Skip()
         enddo
      endif
   endwith
   q:Destroy()
return

procedure emitMDFe(emit, emitente)
   with object emit
      :id := emitente:getField('id')
      :IE:value := emitente:getField('IE')
      // :IEST:value := emitente:getField('IEST')  // Inscrição Estadual do Substituto Tributário não implementado, não requerido
      :xNome:value := emitente:getField('xNome')
      //:xFant:value := emitente:getField('xFant')
      :enderEmit:xLgr:value := emitente:getField('xLgr')
      :enderEmit:nro:value := emitente:getField('nro')
      :enderEmit:xCpl:value := emitente:getField('xCpl')
      :enderEmit:xBairro:value := emitente:getField('xBairro')
      :enderEmit:cMun:value := emitente:getField('cMunEnv')
      :enderEmit:xMun:value := emitente:getField('xMunEnv')
      :enderEmit:CEP:value := emitente:getField('CEP')
      :enderEmit:UF:value := emitente:getField('UF')
      :fone:value := onlyNumbers(emitente:getField('fone'))
      :fone:raw := onlyNumbers(:fone:value)
      :email:value := emitente:getField('email')
   endwith
return

procedure rodoMDFe(rodo, record, emitente)
   local q, s := TSQLString():new('SELECT cte_vp_cnpj_fornec AS CNPJForn, ')

   s:add('cte_vp_cnpj_responsavel AS CNPJPg, ')
   s:add('cte_vp_comprov_compra AS nCompra, ')
   s:add('cte_vp_valor_vale AS vValePed ')
   s:add('FROM ctes_rod_vale_pedagio AS t1 ')
   s:add('INNER JOIN mdfes_ctes AS t2 ON t2.ctes_id = t1.cte_id ')
   s:add('WHERE t2.mdfe_id = ' + record:getField('id'))

   // Informações do modal Rodoviário
   with object rodo
      :submit := True
      // Grupo de informações para Agência Reguladora
      with object :infANTT
         :submit := !Empty(emitente:getField('RNTRC'))
         :RNTRC:value := emitente:getField('RNTRC')
         q := TSQLQuery():new(s:value)
         if q:isExecuted()
            do while !q:EOF()
               :valePed:add_disp({'CNPJForn' => q:getField('CNPJForn'), 'CNPJPg' => q:getField('CNPJPg'), 'nCompra' => q:getField('nCompra'), 'vValePed' => q:getField('vValePed')})
               q:Skip()
            enddo
            :valePed:submit := !(hmg_len(:valePed:disp:value) == 0)
         else
            :valePed:submit := False
            saveLog('ctes_rod_vale_pedagio: Erro de SQL: ' + s:value, ENCRYPTED)
         endif
         q:Destroy()
         q := TSQLQuery():new('SELECT clie_id, clie_cnpj FROM clientes WHERE clie_id IN (' + record:getField('lista_tomadores') + ') ORDER BY clie_cnpj')
         if q:isExecuted()
            do while !q:EOF()
               :add_infContratante({'CNPJ' => q:getField('clie_cnpj')})
               q:Skip()
            enddo
         endif
         q:Destroy()
      endwith
      // Dados do Veículo com a Tração
      with object :veicTracao
         s:setValue('SELECT ')
         s:add("IF(t1.veic_trac_id > 0, t4.cInt, t3.cte_rv_codigo_interno) AS cInt, ")
         s:add("IF(t1.veic_trac_id > 0, t4.placa, t3.cte_rv_placa) AS placa, ")
         s:add("IF(t1.veic_trac_id > 0, t4.RENAVAM, t3.cte_rv_renavam) AS RENAVAM, ")
         s:add("IF(t1.veic_trac_id > 0, t4.tara, t3.cte_rv_tara) AS tara, ")
         s:add("IF(t1.veic_trac_id > 0, t4.capKG, t3.cte_rv_cap_kg) AS capKG, ")
         s:add("IF(t1.veic_trac_id > 0, t4.capM3, t3.cte_rv_cap_m3) AS capM3, ")
         s:add("RIGHT(CONCAT('0', IF(t1.veic_trac_id > 0, t4.tpRod, t3.cte_rv_tp_rodado)), 2) AS tpRod, ")
         s:add("RIGHT(CONCAT('0', IF(t1.veic_trac_id > 0, t4.tpCar, t3.cte_rv_tp_carroceria)), 2) AS tpCar, ")
         s:add("IF(t1.veic_trac_id > 0, t4.UF, t3.cte_rv_uf_licenciado) AS uf_licenciado, ")
         s:add("IF(t1.veic_trac_id > 0, IF(t4.agre_id > 0, 'T', 'P'), t3.cte_rv_tp_propriedade) AS tp_propriedade, ")
         s:add("RIGHT(CONCAT('00000000000000', IF(t1.veic_trac_id > 0, IF(t5.tipo_documento = 'CNPJ', t5.documento, NULL), t3.cte_rv_cnpj)), 14) AS cnpj, ")
         s:add("RIGHT(CONCAT('00000000000000', IF(t1.veic_trac_id > 0, IF(t5.tipo_documento = 'CPF', t5.documento, NULL), t3.cte_rv_cpf)), 11) AS cpf, ")
         s:add("IF(t1.veic_trac_id > 0, t5.RNTRC, t3.cte_rv_rntrc) AS RNTRC, ")
         s:add("IF(t1.veic_trac_id > 0, t5.xNome, t3.cte_rv_razao_social) AS xNome, ")
         s:add("IF(t1.veic_trac_id > 0, t5.IE, t3.cte_rv_inscricao_estadual) AS IE, ")
         s:add("IF(t1.veic_trac_id > 0, t5.tpProp, t3.cte_rv_tp_proprietario) AS tpProp ")
         s:add("FROM mdfes_inf_unid_transp AS t1 ")
         s:add("LEFT JOIN ctes_rod_motoristas AS t2 ON t2.cte_mo_id = t1.cte_mo_id ")
         s:add("LEFT JOIN ctes_rod_veiculos AS t3 ON t3.cte_rv_id = t2.cte_rv_id ")
         s:add("LEFT JOIN veiculos AS t4 ON t4.id = t1.veic_trac_id ")
         s:add("LEFT JOIN agregados AS t5 ON t5.id = t4.agre_id ")
         s:add("WHERE t1.mdfe_id = " + record:getField('id') + " ")
         s:add("AND (t1.cte_mo_id > 0 OR t1.veic_trac_id > 0) ")
         s:add("LIMIT 1")
         q := TSQLQuery():new(s:value)
         if q:isExecuted()
            if (q:LastRec() == 0)
               saveLog('veicTracao: SQL retornou vazio: ' + s:value, ENCRYPTED)
               return
            else
               :cInt:value := q:getField('cInt')
               :placa:value := q:getField('placa')
               :RENAVAM:value := q:getField('RENAVAM')
               :tara:value := q:getField('tara')
               :capKG:value := q:getField('capKG')
               :capM3:value := q:getField('capM3')
               :tpRod:value := q:getField('tpRod')
               :tpCar:value := q:getField('tpCar')
               :UF:value := q:getField('uf_licenciado')

               // Proprietários do Veículo. Só preenchido quando o veículo não pertencer à empresa emitente do MDF-e
               if (q:getField('tp_propriedade') == 'T')
                  :prop:submit := True
                  :prop:CPF:value := q:getField('cpf')
                  :prop:CNPJ:value := q:getField('cnpj')
                  :prop:RNTRC:value := q:getField('RNTRC')
                  :prop:xNome:value := q:getField('xNome')
                  :prop:IE:value := q:getField('IE')
                  :prop:UF:value := q:getField('uf_licenciado')
                  :prop:tpProp:value := q:getField('tpProp')
               endif
            endif
         else
            saveLog('Erro: SQL não executado: ' + s:value, ENCRYPTED)
         endif
         q:Destroy()
         // Informações do(s) Condutor(es) do veículo
         s:setValue("SELECT ")
         s:add("IF(t1.mot_id > 0, t3.cpf, t2.cte_mo_cpf) AS CPF,")
         s:add("IF(t1.mot_id > 0, t3.nome, t2.cte_mo_motorista) AS xNome ")
         s:add("FROM mdfes_inf_unid_transp AS t1 ")
         s:add("LEFT JOIN ctes_rod_motoristas AS t2 ON t2.cte_mo_id = t1.cte_mo_id ")
         s:add("LEFT JOIN motoristas AS t3 ON t3.id = t1.mot_id ")
         s:add("WHERE t1.mdfe_id = " + record:getField('id') + " ")
         s:add("AND (t1.cte_mo_id OR t1.mot_id > 0) ")
         s:add("ORDER BY cte_mo_motorista")
         q := TSQLQuery():new(s:value)

         if q:isExecuted()
            if !(q:LastRec() == 0)
               do while !q:EOF()
                  :add_condutor({'xNome' => q:getField('xNome'), 'CPF' => q:zeroFill('CPF', 11)})
                  q:Skip()
               enddo
            endif
         else
            saveLog('Erro: SQL não executado: ' + s:value, ENCRYPTED)
         endif
         q:Destroy()
      endwith

      // Dados dos reboques
      s:setValue("SELECT cte_rv_codigo_interno AS cInt, ")
      s:add("cte_rv_placa AS placa, ")
      s:add("cte_rv_renavam AS RENAVAM, ")
      s:add("cte_rv_tara AS tara, ")
      s:add("cte_rv_cap_kg AS capKG, ")
      s:add("cte_rv_cap_m3 AS capM3, ")
      s:add("cte_rv_tp_carroceria AS tpCar, ")
      s:add("cte_rv_tp_propriedade AS tp_propriedade, ")
      s:add("cte_rv_cpf AS cpf, ")
      s:add("cte_rv_cnpj AS cnpj, ")
      s:add("cte_rv_rntrc AS RNTRC, ")
      s:add("cte_rv_razao_social AS xNome, ")
      s:add("cte_rv_inscricao_estadual AS IE, ")
      s:add("cte_rv_uf_licenciado AS uf_licenciado, ")
      s:add("cte_rv_uf_proprietario AS uf_proprietario, ")
      s:add("cte_rv_tp_proprietario AS tp_proprietario ")
      s:add("FROM ctes_rod_veiculos AS t1 ")
      s:add("INNER JOIN mdfes_ctes AS t2 ON t2.ctes_id = t1.cte_id ")
      s:add("WHERE t2.mdfe_id = " + record:getField('id') + " ")
      s:add("AND t1.cte_rv_tp_veiculo = 1") // 1 - Reboque; 0 - Tração
      q := TSQLQuery():new(s:value)

      if q:isExecuted()
         do while !q:EOF()
            if :add_veicReboque({'cInt' => q:getField('cInt'),;
                                 'placa' => q:getField('placa'),;
                                 'RENAVAM' => q:getField('RENAVAM'),;
                                 'tara' => q:getField('tara'),;
                                 'capKG' => q:getField('capKG'),;
                                 'capM3' => q:getField('capM3'),;
                                 'tpCar' => q:getField('tpCar'),;
                                 'UF' => q:getField('uf_licenciado')})

               if (q:getField('tp_propriedade') == 'T')
                  with object :veicReboque:value[hmg_len(:veicReboque:value)]
                     :prop:submit := True
                     :prop:CPF:value := q:getField('cpf')
                     :prop:CNPJ:value := q:getField('cnpj')
                     :prop:RNTRC:value := q:getField('RNTRC')
                     :prop:xNome:value := q:getField('xNome')
                     :prop:IE:value := q:getField('IE')
                     :prop:UF:value := q:getField('uf_proprietario')
                     :prop:tpProp:value := q:getField('tp_proprietario')
                  endwith
               endif
            endif
            q:Skip()
         enddo
      endif
      q:Destroy()

      // lacRodo | Lacres
      s:setValue("SELECT t1.lac_numero AS nLacre FROM ctes_rod_lacres AS t1 ")
      s:add("WHERE t1.cte_id IN (SELECT cte_id FROM mdfes_ctes WHERE mdfe_id = ' + record:getField('id') + ') ")
      s:add("UNION ")
      s:add("SELECT t2.nLacre FROM mdfes_lacres AS t2 ")
      s:add("WHERE t2.mdfe_id = ' + record:getField('id') + ' ")
      s:add("ORDER BY nLacre")
      q := TSQLQuery():new(s:value)

      if q:isExecuted()
         do while !q:EOF()
            :add_lacRodo(q:getField('nLacre'))
            q:Skip()
         enddo
      endif
      q:Destroy()

   endwith

return

procedure infDocMDFe(infDoc, mdfe_id)
   local q, q2, s := TSQLString():new("SELECT t1.cid_id_destino AS destino_cid_id, ")
   s:add("t1.cid_destino_codigo_municipio AS cMunDescarga, ")
   s:add("t1.cid_destino_municipio AS xMunDescarga ")
   s:add("FROM view_ctes AS t1 ")
   s:add("INNER JOIN mdfes_ctes AS t2 ON t2.ctes_id = t1.cte_id ")
   s:add("WHERE t2.mdfe_id = " + mdfe_id + " ")
   s:add("GROUP BY t1.cid_id_destino")
   q := TSQLQuery():new(s:value)

   if q:isExecuted()
      with object infDoc
         if (q:LastRec() == 0)
            saveLog('view_ctes: Consulta SQL retornou vazia! SQL: ' + s:value, ENCRYPTED)
         else
            do while !q:EOF()
               if :add_infMunDescarga({'cMunDescarga' => q:getField('cMunDescarga'), 'xMunDescarga' => q:getField('xMunDescarga')})
                  s:setValue("SELECT t1.cte_chave AS chCTe FROM ctes AS t1 ")
                  s:add("INNER JOIN mdfes_ctes AS t2 ON t2.ctes_id = t1.cte_id ")
                  s:add("WHERE t2.mdfe_id = " + mdfe_id + " ")
                  s:add("AND t1.cid_id_destino = " + q:getField('destino_cid_id') + " ")
                  s:add("ORDER BY t1.cte_chave")
                  q2 := TSQLQuery():new(s:value)
                  if q2:isExecuted()
                     do while !q2:EOF()
                        :infMunDescarga:value[hmg_len(:infMunDescarga:value)]:add_infCTe(q2:getField('chCTe'))
                        q2:Skip()
                     enddo
                  else
                     saveLog('ctes: Erro ao executar SLQ: ' + s:value, ENCRYPTED)
                  endif
                  q2:Destroy()
               endif
               q:Skip()
            enddo
         endif
      endwith
   endif
   q:Destroy()
return

procedure segMDFe(infMDFe, emitente, mdfe_id)
   local q, s := TSQLString():new("SELECT cte_seg_averbacao AS nAver ")
   with object infMDFe
      if :add_seg({'respSeg' => '1', 'xSeg' => emitente:getField('seguradora'), 'nApol' => emitente:getField('apolice'), 'CNPJ' => emitente:getField('CNPJ'), 'segCNPJ' => emitente:getField('CNPJ')})
         s:add("FROM ctes_seguro ")
         s:add("WHERE cte_id IN (SELECT ctes_id FROM mdfes_ctes WHERE mdfe_id = " + mdfe_id + ") AND ")
         s:add("NOT ISNULL(cte_seg_averbacao) .AND. ")
         s:add("cte_seg_averbacao != '' ")
         s:add("GROUP BY cte_seg_averbacao")
         q := TSQLQuery():new(s:value)

         if q:isExecuted()
            if (q:LastRec() == 0)
               :seg:value[1]:add_nAver(:ide:nMDF:value)
            else
               do while !q:EOF()
                  :seg:value[1]:add_nAver(q:getField('nAver'))
                  q:Skip()
               enddo
            endif
         else
            saveLog('ctes_seguro: Erro SQL: ' + s:value, ENCRYPTED)
         endif
         q:Destroy()
      endif
   endwith
return

procedure prodPred(prodPred, mdfe_id, emitCEP)
   local q, s := TSQLString():new("SELECT pr.prod_produto AS xProd, ")

   s:add("cl.clie_cep AS destCEP ")
   s:add("FROM mdfes_ctes AS md ")
   s:add("INNER JOIN ctes AS ct ON ct.cte_id = md.ctes_id ")
   s:add("INNER JOIN produtos AS pr ON pr.prod_id = ct.prod_id ")
   s:add("INNER JOIN clientes AS cl ON cl.clie_id = ct.clie_destinatario_id ")
   s:add("WHERE md.mdfe_id = " + mdfe_id + " LIMIT 1")

   q := TSQLQuery():new(s:value)
   if q:isExecuted()
      with object prodPred
         :tpCarga:value := '05'
         :xProd:value := q:getField('xProd')
         :cEAN:value := 'SEM GTIN'
         :NCM:value := '00000000'
         :infLocalCarrega:value := emitCEP
         :infLocalDescarrega:value := q:getField('destCEP')
      endwith
   endif
return

procedure totMDFe(tot, record)
   with object tot
      :qCTe:value := record:getField('qCTe')
      :vCarga:value := record:getField('vCarga')
      :cUnid:value := record:zeroFill('cUnid', 2)
      :qCarga:value := record:getField('qCarga')
   endwith
return

procedure autXML_MDFe(infMDFe)
   local infMunDescarga, chCTe, y := 0
   local doc, cnpj_cpf := {}
   local q, s := TSQLString():new("SELECT emp_cnpj, ")

   s:add("rem_tipo_documento, rem_cnpj_cpf, ")
   s:add("des_tipo_documento, des_cnpj_cpf, ")
   s:add("tom_tipo_documento, tom_cnpj_cpf, ")
   s:add("exp_tipo_documento, exp_cnpj_cpf, ")
   s:add("rec_tipo_documento, rec_cnpj_cpf, ")
   s:add("col_tipo_documento, col_cnpj_cpf, ")
   s:add("ent_tipo_documento, ent_cnpj_cpf, ")
   s:add("rep_tipo_documento, rep_cnpj_cpf ")
   s:add("FROM view_ctes ")
   s:add("WHERE cte_chave IN ('")

   with object infMDFe:infDoc:infMunDescarga
      for each infMunDescarga in :value
         for each chCTe in infMunDescarga:infCTe:value
            y++
            if !(y == 1)
               s:add(", '")
            endif
            s:add(chCTe:value +"'")
         next
      next
   endwith

   if !(y == 0)
      s:add(") ORDER BY emp_cnpj, rem_cnpj_cpf")
      q := TSQLQuery():new(s:value)
      if q:isExecuted()
         with object infMDFe
            do while !q:EOF()

               doc := q:getField('emp_cnpj')
               if (hb_AScan(cnpj_cpf, doc,,, True) == 0)
                  AAdd(cnpj_cpf, doc)
                  :add_autXML({'CNPJ' => doc})
               endif

               doc := q:getField('rem_cnpj_cpf')
               if !Empty(q:getField('rem_tipo_documento')) .and. !Empty(doc)
                  if (hb_AScan(cnpj_cpf, doc,,, True) == 0)
                     AAdd(cnpj_cpf, doc)
                     :add_autXML(iif((q:getField('rem_tipo_documento') == 'CNPJ'), {'CNPJ' => doc}, {'CPF' => doc}))
                  endif
               endif

               doc := q:getField('des_cnpj_cpf')
               if !Empty(q:getField('des_tipo_documento')) .and. !Empty(doc)
                  if (hb_AScan(cnpj_cpf, doc,,, True) == 0)
                     AAdd(cnpj_cpf, doc)
                     :add_autXML(iif((q:getField('des_tipo_documento') == 'CNPJ'), {'CNPJ' => doc}, {'CPF' => doc}))
                  endif
               endif

               doc := q:getField('tom_cnpj_cpf')
               if !Empty(q:getField('tom_tipo_documento')) .and. !Empty(doc)
                  if (hb_AScan(cnpj_cpf, doc,,, True) == 0)
                     AAdd(cnpj_cpf, doc)
                     :add_autXML(iif((q:getField('tom_tipo_documento') == 'CNPJ'), {'CNPJ' => doc}, {'CPF' => doc}))
                  endif
               endif

               doc := q:getField('exp_cnpj_cpf')
               if !Empty(q:getField('exp_tipo_documento')) .and. !Empty(doc)
                  if (hb_AScan(cnpj_cpf, doc,,, True) == 0)
                     AAdd(cnpj_cpf, doc)
                     :add_autXML(iif((q:getField('exp_tipo_documento') == 'CNPJ'), {'CNPJ' => doc}, {'CPF' => doc}))
                  endif
               endif

               doc := q:getField('rec_cnpj_cpf')
               if !Empty(q:getField('rec_tipo_documento')) .and. !Empty(doc)
                  if (hb_AScan(cnpj_cpf, doc,,, True) == 0)
                     AAdd(cnpj_cpf, doc)
                     :add_autXML(iif((q:getField('rec_tipo_documento') == 'CNPJ'), {'CNPJ' => doc}, {'CPF' => doc}))
                  endif
               endif

               doc := q:getField('col_cnpj_cpf')
               if !Empty(q:getField('col_tipo_documento')) .and. !Empty(doc)
                  if (hb_AScan(cnpj_cpf, doc,,, True) == 0)
                     AAdd(cnpj_cpf, doc)
                     :add_autXML(iif((q:getField('col_tipo_documento') == 'CNPJ'), {'CNPJ' => doc}, {'CPF' => doc}))
                  endif
               endif

               doc := q:getField('ent_cnpj_cpf')
               if !Empty(q:getField('ent_tipo_documento')) .and. !Empty(doc)
                  if (hb_AScan(cnpj_cpf, doc,,, True) == 0)
                     AAdd(cnpj_cpf, doc)
                     :add_autXML(iif((q:getField('ent_tipo_documento') == 'CNPJ'), {'CNPJ' => doc}, {'CPF' => doc}))
                  endif
               endif

               doc := q:getField('rep_cnpj_cpf')
               if !Empty(q:getField('rep_tipo_documento')) .and. !Empty(doc)
                  if (hb_AScan(cnpj_cpf, doc,,, True) == 0)
                     AAdd(cnpj_cpf, doc)
                     :add_autXML(iif((q:getField('rep_tipo_documento') == 'CNPJ'), {'CNPJ' => doc}, {'CPF' => doc}))
                  endif
               endif

               q:Skip()

            enddo
         endwith
      endif
   endif

return