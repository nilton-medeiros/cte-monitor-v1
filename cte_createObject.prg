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

// Atualizado: 2022-11-03 12:30
/* Adicionado regra para o DIFAL, destinatário tem que ser o tomador */

function cte_createObject(rowCTe, qObs, qCc, qDoc)
   local cte := TCTe():new(appData:ACBr, appData:UTC, appData:systemPath)
   local emitente := appData:getCompanies(rowCTe:getField('emp_id'))

   cte:situacao := rowCTe:getField('situacao')
   cte:remotePath := emitente:getField('remote_file_path') + '/ctes/files'
   // Fornece os primeiros campos para gerar a chave do CTe
   cteKey_firstFields(cte, emitente, rowCTe)

   // infCte | Informações do CT-e
   // :infCte:Id será gerado na Validação automaticamente
   cte:infCte:versao:value := rowCTe:getField('versao_xml')

   // ide | Identificação do CT-e
   ideCTe(cte:infCte:ide, rowCTe, emitente)

   // compl | Dados complementares do CT-e para fins operacionais ou comerciais
   compl(cte:infCte:compl, rowCTe, cte:infCte:ide, qObs)

   // emit | Identificação do Emitente do CT-e
   emit(cte:infCte:emit, emitente)

   if (cte:infCte:ide:tpServ:value $ "012")
      /*
         * Serviço igual a 0 - Normal; 1 - Subcontratação; 2 - Redespacho
         * Informar o remetente e destinatário
         * Não informar o expedidor e nem o recebedor
      */
      // rem | Informações do remetente do CT-e
      rem(cte:infCte:rem, rowCTe)

      // dest | Informações do destinatário do CT-e
      dest(cte:infCte:dest, rowCTe)

      // receb | Informações do recebedor do CT-e se houver
      if !empty(rowCTe:getField('rec_cnpj')) .or. !empty(rowCTe:getField('rec_cpf'))
         receb(cte:infCte:receb, rowCTe)
      endif

      // exped | Informações do expedidor do CT-e
      if !empty(rowCTe:getField('exp_cnpj')) .or. !empty(rowCTe:getField('exp_cpf'))
         exped(cte:infCte:exped, rowCTe)
      endif

   else
      /* Serviço igual a 3 - Redespacho Intermediário; 4 - Serviço Vinculado a Multimodal
         * Informar o expedidor e o recebedor
         * Não informar o remetente e destinatário para este tipo de serviço
      */
      // exped | Informações do expedidor do CT-e
      exped(cte:infCte:exped, rowCTe)

      // receb | Informações do recebedor do CT-e
      receb(cte:infCte:receb, rowCTe)
      /*
         * Serviço Vinculado a Multimodal não implementado
         *
         * if (cte:infCte:ide:tpServ:value == "4")
         *      // 4 - Serviço Vinculado a Multimodal
         *      chCTeMultimodal recebe_de_cte_outros()
         *      cte:infCte:infCTeNorm:infServVinc:addInfCTeMultimodal(chCTeMultimodal)
         * endif
      */
   endif

   // vPrest | Valores da Prestação de Serviço
   vPrest(cte:infCte:vPrest, rowCTe, qCc)

   // imp | Informações relativas aos Impostos
   imp(cte:infCte:imp, rowCTe)

   // tpCTe = 0-Normal, 1-Complemento de Valores, 3-Substituto
   if (rowCTe:getField('tpCTe') $ '03')
      // 0 - CT-e Normal e 3 - CT-e de Substituição
      cte:infCte:infCTeNorm:submit := True
      // infCarga | Informações da Carga do CT-e
      infCarga(cte:infCte:infCTeNorm:infCarga, rowCTe, qDoc)

      // infDoc | Informações dos documentos transportados pelo CT-e Opcional para Redespacho Intermediario e Serviço vinculado a multimodal.
      infDoc(cte:infCte:infCTeNorm:infDoc, rowCTe, qDoc)
      if (rowCTe:getField('tpServ') $ '123')
         /* docAnt | Documentos de Transporte Anterior
            * Para: tpCTe (0 - CT-e Normal ou 3 - CT-e de Substituição) e
            *       tpServ (1 - Subcontratação; 2 - Redespacho; 3 - Redespacho Intermediário)
            * O grupo de Documentos Anteriores (docAnt) deve ser informado
         */
         docAnt(cte:infCte:infCTeNorm:docAnt, rowCTe)

      elseif (rowCTe:getField('tpCTe') == '0')
         // tpCTe: 0 - Normal | infCte/infCTeNorm/infModal
         // tpServ 0 - Normal; 1 - Subcontratação; 2 – Redespacho; 3 – Redespacho Intermediário; 4 – Serviço Vinculado à Multimodal
         if (rowCTe:getField('tpServ') == '0')
            // tpServ (0 - Normal)
            if (rowCTe:zeroFill('modal', 2) == '01')
               // Informações do modal Rodoviário
               rodo(cte:infCte:infCTeNorm:infModal:rodo, emitente, rowCTe:getField('id'))
            else
               // Imformações do modal Aéreo
               aereo(cte:infCte:infCTeNorm:infModal:aereo, rowCTe, qCc)
            endif
            // veicNovos | informações dos veículos transportados
            veicNovos(cte:infCte:infCTeNorm, rowCTe:getField('id'))

            // cobr | Dados da cobrança do CT-e : Não implementado, normalmente o faturamento só ocorre depois depois da emissão

            if (rowCTe:getField('tpCTe') == '3')
               // infCteSub | Informações do CT-e de substituição
               // Não immplementado
            endif

            // infGlobalizado | Informações do CT-e Globalizado
            if !Empty(cte:infCte:infCTeNorm:infDoc:infNFe:value)
               infGlobalizado(cte:infCte)
            endif
         else
            // tpServ: 4 – Serviço Vinculado à Multimodal
            // infServVinc() * Não implementado
         endif
      endif

   elseif (cte:infCte:ide:tpCTe:value == "1")
      // 1 - CT-e de Complemento de Valores;
      cte:infCte:infCteComp:submit := True
      // compl | Dados complementares do CT-e para fins operacionais ou comerciais
      //infCteComp(cte:infCte:infCteComp)  * Módulo não implementado
   else
      // 2 - CT-e de Anulação
      // infCteAnu | Detalhamento do CT-e do tipo Anulação
      cte:infCte:infCteAnu:submit := True
      // infCTeAnu() * Módulo não implementado
   endif

   // autXML | Autorizados para download do XML do DF-e
   autXML(cte:infCte)

   /* infRespTec | Informações do Responsável Técnico pela emissão do DF-e
      * NT 2018.005 v1.30
      * Implementação futura para o grupo de campos de identificação do responsável técnico e geração do hashCSRT
      * http://nstecnologia.com.br/blog/nt-2018-005-v-1-30/
   */

   with object cte:infCte:infRespTec
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

return cte

procedure cteKey_firstFields(cte, emitente, rowCTe)
   // Fornece os primeiros campos para gerar a chave do CTe
   cte:infCte:emit:CNPJ:value := emitente:getField('CNPJ')
   cte:infCte:emit:CNPJ:raw := onlyNumbers(emitente:getField('CNPJ'))

   // ide | Identificação do CT-e
   with object cte:infCte:ide
      :cte_id := rowCTe:getField('id')
      :cUF:value := emitente:getField('cUF')
      :dhEmi:value := rowCTe:getField({'field_name_or_number' => "dhEmi", 'dateTime_as_TDZ' => True})
      :mod:value := rowCTe:getField('modelo')
      :serie:raw := rowCTe:getField('serie')
      :serie:value := rowCTe:zeroFill('serie', 3)
      :nCT:raw := rowCTe:getField('nCT')
      :nCT:value := rowCTe:zeroFill('nCT', 9)
      :tpEmis:value := rowCTe:getField('tpEmis')
      :cCT:raw := rowCTe:getField('cCT')
      :cCT:value := rowCTe:zeroFill('cCT', 8)
   end
return

procedure ideCTe(ide, rowCTe, emitente)
   with object ide
      :CFOP:value := rowCTe:getField('CFOP')
      :natOp:value := rowCTe:getField('natOp')
      :tpAmb:value := emitente:getField('tpAmb')
      :tpCTe:value := rowCTe:getField('tpCTe')
      :procEmi:value := "0"  // 0 - emissão de CT-e com aplicativo do contribuinte
      :verProc:value := "1.0.0"  // versão do aplicativo emissor de CT-e
      :cMunEnv:value := emitente:getField('cMunEnv')
      :xMunEnv:value := emitente:getField('xMunEnv')
      :UFEnv:value := emitente:getField('UF')
      :modal:raw := ''  // O raw tem que estar fazio, no xml a prioridade é o raw se não estiver vazio, nesse caso, tem que entrar o modal:value
      :modal:value := rowCTe:zeroFill('modal', 2)
      :tpServ:value := rowCTe:getField('tpServ')
      :cMunIni:value := rowCTe:getField('cMunIni')
      :xMunIni:value := rowCTe:getField('xMunIni')
      :UFIni:value := rowCTe:getField('UFIni')
      :cMunFim:value := rowCTe:getField('cMunFim')
      :xMunFim:value := rowCTe:getField('xMunFim')
      :UFFim:value := rowCTe:getField('UFFim')
      :retira:value := rowCTe:getField('retira')
      :xDetRetira:value := rowCTe:getField('xDetRetira')
      :indIEToma:value := iif(rowCTe:getField('indIEToma') == '0', '9', iif(rowCTe:getField('tom_ie_isento') == '1', '2', '1'))
      if (rowCTe:getField('cte_tomador') == '4')
         :toma4:toma:value := rowCTe:getField('cte_tomador')
         if !empty(rowCTe:getField('tom_cnpj'))
            :toma4:CNPJ:value := rowCTe:getField('tom_cnpj')
            :toma4:IE:value := rowCTe:getField('tom_ie')
         else
            :toma4:CPF:value := rowCTe:getField('tom_cpf')
         endif
         :toma4:xNome:value := rowCTe:getField('tom_xNome')
         //:toma4:xFant:value := rowCTe:getField('tom_xFant')
         :toma4:fone:value := rowCTe:getField('tom_fone')
         :toma4:fone:raw := onlyNumbers(:toma4:fone:value)
         :toma4:enderToma:xLgr:value := rowCTe:getField('tom_end_logradouro')
         :toma4:enderToma:nro:value := rowCTe:getField('tom_end_numero')
         :toma4:enderToma:xCpl:value := rowCTe:getField('tom_end_complemento')
         :toma4:enderToma:xBairro:value := rowCTe:getField('tom_end_bairro')
         :toma4:enderToma:cMun:value := rowCTe:getField('tom_cid_codigo_municipio')
         :toma4:enderToma:xMun:value := rowCTe:getField('tom_cid_municipio')
         :toma4:enderToma:CEP:value := rowCTe:getField('tom_end_cep')
         :toma4:enderToma:UF:value := rowCTe:getField('tom_cid_uf')
         :toma4:email:value := getEmailClient(rowCTe:getField('clie_tomador_id'))
      else
         :toma3:toma:value := rowCTe:getField('cte_tomador')
      endif

      /*
      * Data e hora da entrega em contingência
      * Módulo não implementado no TMS.CLOUD
      *
      if (:tpEmis:value == '5')
         :dhCont:value := rowCTe:getField({'field_name_or_number' => "dhCont", 'date_as_string' => True})
         :xJust:value := 'SEFAZ FORA DE SERVICO'
      endif
      */
   endwith
return

function getEmailClient(cliente_id)
   local sql := TSQLString():new()
   local q, r := ""

   sql:setValue("SELECT con_email_cte ")
   sql:add("FROM clientes_contatos ")
   sql:add("WHERE clie_id = " + cliente_id + " AND ")
   sql:add("NOT ISNULL(con_email_cte) AND ")
   sql:add("con_email_cte != '' AND ")
   sql:add("LOCATE('.', con_email_cte, LOCATE('@', con_email_cte)) > 0 ")
   sql:add("LIMIT 1")
   q := TSQLQuery():new(sql:value)

   if q:isExecuted .and. !(q:LastRec() == 0)
      r := q:getField('con_email_cte')
   endif
   q:Destroy()
return r

procedure compl(compl, rowCTe, ide, qObs)
   local pas

   with object compl
      :submit := True
      :xCaracAd:value := rowCTe:getField('xCaracAd')
      :xCaracSer:value := rowCTe:getField('xCaracSer')
      :xEmi:value := rowCTe:getField('xEmi')
      if (ide:modal:value == '02')
         // Modal Aéreo
         :fluxo:submit := True
         :fluxo:xOrig:value := rowCTe:getField('xOrig')
         :fluxo:xOrig:required := True
         pas := :fluxo:addPass()
         if ! Empty(rowCTe:getField('xPass'))
            pas:xPass:value := rowCTe:getField('xPass')
         endif
         pas:xDest:value := rowCTe:getField('xDest')
      endif
      :Entrega:setTpPer(rowCTe:getField('tpPer'))
      if (:Entrega:tpPer:value == '4')
         // 4-No período
         :Entrega:dIni:value := rowCTe:getField({'field_name_or_number' => "dIni", 'date_as_string' => True})
         :Entrega:dFim:value := rowCTe:getField({'field_name_or_number' => "dFim", 'date_as_string' => True})
      elseif  !(:Entrega:tpPer:value == '0')
         // 1-Na data; 2-Até a data; 3-A partir da data
         :Entrega:dProg:value := rowCTe:getField({'field_name_or_number' => "dProg", 'date_as_string' => True})
      endif
      :Entrega:setTpHor(rowCTe:getField('tpHor'))
      if (:Entrega:tpHor:value == '4')
         // 4-No Intervalo de Tempo
         :Entrega:hIni:value := rowCTe:getField('hIni')
         :Entrega:hFim:value := rowCTe:getField('hFim')
      else
         // 1-No horário; 2-Até o horário; 3-A partir do horário
         :Entrega:hProg:value := rowCTe:getField('hProg')
      endif
      :origCalc:value := ide:xMunIni:value
      :destCalc:value := ide:xMunFim:value
      :xObs:raw := hb_utf8StrTran(removeAccentuation(rowCTe:getField('xObs')), '\n', ';')
      :xObs:value := removeAccentuation(rowCTe:getField('xObs'))
      if (ide:indGlobalizado:value == '1')
         :xObs:raw := :xObs:raw + ';Procedimento efetuado conforme Resolução/SEFAZ n. 2.833/2017'
         :xObs:value := :xObs:value + '\nProcedimento efetuado conforme Resolução/SEFAZ n. 2.833/2017'
      endif

      if !Empty(rowCTe:getField({'field_name_or_number' => 'vTotTrib', 'number_as_string' => False}))
         :addObsCont({'xCampo' => 'LEI DA TRANSPARENCIA',;
                      'xTexto' => 'Lei da transparencia 12741/12, o valor aproximado dos tributos incidentes sobre o preço do serviço:'+;
                                  ' PIS ' + rowCTe:getField('vPIS')+;
                                  ' COFINS ' + rowCTe:getField('vCOFINS')+;
                                  ' ICMS ' +  rowCTe:getField('vICMS')+;
                                  ' TOTAL ' + rowCTe:getField('vTotTrib')})
      endif

      if qObs:isExecuted()
         do while !qObs:EOF()
            if (qObs:getField('interessado') == 'CONTRIBUINTE')
               :addObsCont({'xCampo' => qObs:getField('xCampo'), 'xTexto' => qObs:getField('xTexto')})
            else
               :addObsFisco({'xCampo' => qObs:getField('xCampo'), 'xTexto' => qObs:getField('xTexto')})
            endif
            qObs:Skip()
         enddo
      endif
      qObs:Destroy()
   endwith

return

procedure emit(emit, emitente)
   with object emit
      :IE:value := emitente:getField('IE')
      // :IEST:value := emitente:getField('IEST')  // Inscrição Estadual do Substituto Tributário não implementado, não requerido
      :id := emitente:getField('id')
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
      :fone:value := emitente:getField('fone')
      :fone:raw := onlyNumbers(:fone:value)
      
      if DtoS(Date()) > "20220630"
         /* NT 2022.001v.1.00 - A partir de 01/07/22 nova tag obrigatória CRT - Código do Regime Tributário
            1 - Simples Nacional;
            2 - Simples Nacional, excesso sublimite de receita bruta;
            3 - Regime Normal.
            AP = 1 e LW =3
          ** Deveria ter entrado em 01/07 mas não entrou, Sefaz não seguiu data prevista no manual!
         */
      //:CRT:value := iif(emitente:getField('CRT') == "1", "1", "3")
      endif
   endwith
return

procedure rem(rem, rowCTe)
   with object rem
      :submit := True
      if !empty(rowCTe:getField('rem_cnpj'))
         :CNPJ:value := rowCTe:getField('rem_cnpj')
         :IE:value := rowCTe:getField('rem_ie')
      elseif !empty(rowCTe:getField('rem_cpf'))
         :CPF:value := rowCTe:getField('rem_cpf')
      endif
      :xNome:value := rowCTe:getField('rem_razao_social')
      //:xFant:value := rowCTe:getField('rem_nome_fantasia')
      :fone:value := rowCTe:getField('rem_fone')
      :fone:raw := onlyNumbers(:fone:value)
      :endereco:xLgr:value := rowCTe:getField('rem_end_logradouro')
      :endereco:nro:value := rowCTe:getField('rem_end_numero')
      :endereco:xCpl:value := rowCTe:getField('rem_end_complemento')
      :endereco:xBairro:value := rowCTe:getField('rem_end_bairro')
      :endereco:cMun:value := rowCTe:getField('rem_cid_codigo_municipio')
      :endereco:xMun:value := rowCTe:getField('rem_cid_municipio')
      :endereco:CEP:value := rowCTe:getField('rem_end_cep')
      :endereco:UF:value := rowCTe:getField('rem_cid_uf')
      :email:value := getEmailClient(rowCTe:getField('clie_remetente_id'))
      :contribuinte_ICMS := rowCTe:getField('rem_icms')
   endwith
return

procedure dest(dest, rowCTe)
   with object dest
      :submit := True
      if !empty(rowCTe:getField('des_cnpj'))
         :CNPJ:value := rowCTe:getField('des_cnpj')
         :IE:value := rowCTe:getField('des_ie')
      elseif !empty(rowCTe:getField('des_cpf'))
         :CPF:value := rowCTe:getField('des_cpf')
      endif
      :xNome:value := rowCTe:getField('des_razao_social')
      //:xFant:value := rowCTe:getField('des_nome_fantasia')
      :fone:value := onlyNumbers(rowCTe:getField('des_fone'))
      :fone:raw := onlyNumbers(:fone:value)
      :endereco:xLgr:value := rowCTe:getField('des_end_logradouro')
      :endereco:nro:value := rowCTe:getField('des_end_numero')
      :endereco:xCpl:value := rowCTe:getField('des_end_complemento')
      :endereco:xBairro:value := rowCTe:getField('des_end_bairro')
      :endereco:cMun:value := rowCTe:getField('des_cid_codigo_municipio')
      :endereco:xMun:value := rowCTe:getField('des_cid_municipio')
      :endereco:CEP:value := rowCTe:getField('des_end_cep')
      :endereco:UF:value := rowCTe:getField('des_cid_uf')
      :email:value := getEmailClient(rowCTe:getField('clie_destinatario_id'))
      :contribuinte_ICMS := rowCTe:getField('des_icms')
   endwith
return

procedure exped(exped, rowCTe)
   with object exped
      :submit := True
      if !empty(rowCTe:getField('exp_cnpj'))
         :CNPJ:value := rowCTe:getField('exp_cnpj')
         :IE:value := rowCTe:getField('exp_ie')
      elseif !empty(rowCTe:getField('exp_cpf'))
         :CPF:value := rowCTe:getField('exp_cpf')
      endif
      :xNome:value := rowCTe:getField('exp_razao_social')
      //:xFant:value := rowCTe:getField('exp_nome_fantasia')
      :fone:value := rowCTe:getField('exp_fone')
      :fone:raw := onlyNumbers(:fone:value)
      :endereco:xLgr:value := rowCTe:getField('exp_end_logradouro')
      :endereco:nro:value := rowCTe:getField('exp_end_numero')
      :endereco:xCpl:value := rowCTe:getField('exp_end_complemento')
      :endereco:xBairro:value := rowCTe:getField('exp_end_bairro')
      :endereco:cMun:value := rowCTe:getField('exp_cid_codigo_municipio')
      :endereco:xMun:value := rowCTe:getField('exp_cid_municipio')
      :endereco:CEP:value := rowCTe:getField('exp_end_cep')
      :endereco:UF:value := rowCTe:getField('exp_cid_uf')
      :email:value := getEmailClient(rowCTe:getField('clie_expedidor_id'))
      :contribuinte_ICMS := rowCTe:getField('exp_icms')
   endwith
return

procedure receb(receb, rowCTe)
   local var_log := 'Incluindo Recebedor: '
   with object receb
      :submit := True
      if !empty(rowCTe:getField('rec_cnpj'))
         :CNPJ:value := rowCTe:getField('rec_cnpj')
         :IE:value := rowCTe:getField('rec_ie')
         var_log += 'CNPJ: ' + :CNPJ:value + '| '
      elseif !empty(rowCTe:getField('rec_cpf'))
         :CPF:value := rowCTe:getField('rec_cpf')
         var_log += 'CPF: ' + :CPF:value + '| '
      endif
      :xNome:value := rowCTe:getField('rec_razao_social')
      var_log += 'Nome: ' + :xNome:value
      //:xFant:value := rowCTe:getField('rec_nome_fantasia')
      :fone:value := rowCTe:getField('rec_fone')
      :fone:raw := onlyNumbers(:fone:value)
      :endereco:xLgr:value := rowCTe:getField('rec_end_logradouro')
      :endereco:nro:value := rowCTe:getField('rec_end_numero')
      :endereco:xCpl:value := rowCTe:getField('rec_end_complemento')
      :endereco:xBairro:value := rowCTe:getField('rec_end_bairro')
      :endereco:cMun:value := rowCTe:getField('rec_cid_codigo_municipio')
      :endereco:xMun:value := rowCTe:getField('rec_cid_municipio')
      :endereco:CEP:value := rowCTe:getField('rec_end_cep')
      :endereco:UF:value := rowCTe:getField('rec_cid_uf')
      :email:value := getEmailClient(rowCTe:getField('clie_recebedor_id'))
      :contribuinte_ICMS := rowCTe:getField('rec_icms')
   endwith
   saveLog(var_log)
return

procedure vPrest(vPrest, rowCTe, qCc)
   with object vPrest
      :vTPrest:value := rowCTe:getField('vTPrest')
      :vRec:value := rowCTe:getField('vTPrest')
      if qCc:isExecuted()
         do while !qCc:EOF()
            :addComp({'xNome' => qCc:getField('xNome'), 'vComp' => qCc:getField('vComp')})
            qCc:Skip()
         enddo
      endif
   endwith
return

procedure imp(imp, rowCTe)
   local cst45, difal

   switch rowCTe:getField('cte_codigo_sit_tributaria')
      case '00 - Tributação normal do ICMS'
         with object imp:ICMS00
            :submit := True
            :CST:value := "00"
            :vBC:value :=  rowCTe:getField('vBC')
            :pICMS:value :=  rowCTe:getField('pICMS')
            :vICMS:value :=  rowCTe:getField('vICMS')
         endwith
         exit
      case '20 - Tributação com redução de BC do ICMS'
         with object imp:ICMS20
            :submit := True
            :CST:value := "20"
            :pRedBC:value :=  rowCTe:getField('pRedBC')
            :vBC:value :=  rowCTe:getField('vBC')
            :pICMS:value :=  rowCTe:getField('pICMS')
            :vICMS:value :=  rowCTe:getField('vICMS')
         endwith
         exit
      case '60 - ICMS cobrado anteriormente por substituição tributária'
         with object imp:ICMS60
            :submit := True
            :CST:value := "60"
            :vBCSTRet:value :=  rowCTe:getField('vBC')
            :pICMSSTRet:value :=  rowCTe:getField('pICMS')
            :vICMSSTRet:value :=  rowCTe:getField('vICMS')
            :vCred:value :=  rowCTe:getField('vCred')
         endwith
         exit
      case '90 - ICMS outros'
         with object imp:ICMS90
            :submit := True
            :CST:value := "90"
            :pRedBC:value :=  rowCTe:getField('pRedBC')
            :vBC:value :=  rowCTe:getField('vBC')
            :pICMS:value :=  rowCTe:getField('pICMS')
            :vICMS:value :=  rowCTe:getField('vICMS')
            :vCred:value :=  rowCTe:getField('vCred')
         endwith
         exit
      case '90 - ICMS devido à UF de origem da prestação, quando diferente da UF emitente'
         with object imp:ICMSOutraUF
            :submit := True
            :CST:value := "90"
            :pRedBCOutraUF:value :=  rowCTe:getField('pRedBC')
            :vBCOutraUF:value :=  rowCTe:getField('vBC')
            :pICMSOutraUF:value :=  rowCTe:getField('pICMS')
            :vICMSOutraUF:value :=  rowCTe:getField('vICMS')
         endwith
         exit
      case 'SIMPLES NACIONAL'
         with object imp:ICMSSN
            :submit := True
            :CST:value := "90"
            :indSN:value :=  '1'
         endwith
         exit
   endswitch

   // '40 - ICMS isenção','41 - ICMS não tributado','51 - ICMS diferido'
   cst45 := hb_ULeft(rowCTe:getField('cte_codigo_sit_tributaria'), 2)
   if (cst45 $ '40|41|51')
      imp:ICMS45:submit := True
      imp:ICMS45:CST:value := cst45
   endif

   with object imp
      // Módulo não implementado no TMS.CLOUD, enviando somente o necessário para autorização
      :vTotTrib:value := rowCTe:getField('vTotTrib')
      :infAdFisco:value := rowCTe:getField('cte_info_fisco')

      // Informações do ICMS de partilha com a UF de término do serviço de transporte na operação interestadual
      if (rowCTe:getField('tpCTe') $ '013') .and.; // Tipo de CTe (tpCTe) = 0-Normal, 1-Complemento de Valores, 3-Substituto
         ! (rowCTe:getField('UFIni') == rowCTe:getField('UFFim')) .and.; // e UF de término do serviço de transporte na operação interestadual
         (rowCTe:getField('tpServ') == '0') .and.; // e Tipo de Serviço = 0-Normal
         (rowCTe:getField('des_icms') == '0') .and.; // e consumidor (destinatário) não contribuinte do ICMS
         (rowCTe:getField('cte_tomador') == '3') .and.; // Tomador tem que ser o DESTINATÁRIO
         ! :ICMSSN:submit  // O STF decidiu que essa cobrança do ICMS do Diferencial de Alíquota – DIFAL, para empresas Optantes pelo Simples é inconstitucional, pois seu recolhimento foi previsto pela Lei Complementar n° 123, de 14 de dezembro de 2006, e seu recolhimento é feito pela guia unificada do Simples Nacional – DAS
         
         /* A T E N Ç Ã O  :  ESTE IF SE ALTERADO, MUDAR TAMBÉM EM class_TCTe.prg liha 442*/ 
         
         saveLog("DIFAL CALCULADO")
         :ICMSUFFim := True
         // DIFAL - Diferença de Alíquota | FCP - Fundo de Combate a Pobreza | Arquivo SeFaz: CTe_Nota_Tecnica_2015_004.pdf (Pagina 4)
         :vBCUFFim:value := rowCTe:getField('vTPrest') // cte_valor_total | Informar o Valor da Base de Cáclculo do ICMS na UF de término da prestação do serviço de transporte.
         difal := calcDifal(rowCTe:getField('UFIni'), rowCTe:getField('UFFim'), Val(:vBCUFFim:value))
         :tem_difal := difal['tem_difal']
         :pDIFAL := hb_ntos(difal['pDIFAL'])
         :vDIFAL := hb_ntos(difal['vDIFAL'])
         :pFCPUFFim:value := difal['pFCPUFFim'] // Informar o Percentual de ICMS correspondente ao Fundo de Combate à pobreza na UF de término da prestação. (NT2015/004)
         :pICMSUFFim:value := difal['pICMSUFFim'] // Informar a Alíquota interna da UF de término da prestação do serviço de transporte.
         :pICMSInter:value := difal['pICMSInter'] // Informar a Alíquota interestadual das UF envolvidas
         :vFCPUFFim:value := difal['vFCPUFFim'] // Informar o Valor de ICMS correspondente ao Fundo de Combate à pobreza na UF de término da prestação. (NT2015/004)
         :vICMSUFFim:value := difal['vICMSUFFim'] // Informar o Valor do ICMS de partilha para a UF de término da prestação do serviço de transporte.
         :vICMSUFIni:value := difal['vICMSUFIni'] // Informar o Valor do ICMS de partilha para a UF de início da prestação do serviço de transporte.
      else
         :ICMSUFFim := False
         saveLog("DIFAL ISENTO")
      endif
   endwith
return

function calcDifal(uf_origem, uf_destino, valorPrestacao)
   local calcDifal := {'pFCPUFFim' => '0.00', 'pICMSUFFim' => '0.00', 'pICMSInter' => '0.00', 'vFCPUFFim' => '0.00', 'vICMSUFFim' => '0.00', 'vICMSUFIni' => '0.00', 'tem_difal' => False, 'pDIFAL' => 0, 'vDIFAL' => 0}
   local s, q
   local pInter, pFim, vFCP
   if !(uf_destino $ 'AC|AL|AM|BA|CE|DF|ES|GO|MA|MG|MS|MT|PB|PE|PI|PR|RJ|RN|RO|RR|RS|SE|SP|TO')
      return calcDifal
   endif
   s := TSQLString():new("SELECT uf_origem, uf_" + uf_destino + " ")
   s:add("FROM icms ")
   s:add("WHERE uf_origem IN ('")
   s:add(uf_origem + "','")
   s:add(uf_destino + "') ")
   s:add("LIMIT 2")
   q := TSQLQuery():new(s:value)
   if q:isExecuted()
      if (q:LastRec() == 2)
         calcDifal['pFCPUFFim'] := '2.00'
         vFCP := valorPrestacao * 0.02
         calcDifal['vFCPUFFim'] := LTrim(Transform(vFCP, "99999999.99"))

         // Verifica se o primeiro registro é a origem ou o destino
         if (q:getField('uf_origem') == uf_origem)
            pInter := Val(q:getField('uf_' + uf_destino))
         endif
         if (q:getField('uf_origem') == uf_destino)
            pFim := Val(q:getField('uf_' + uf_destino))
         endif
         
         // Verifica o segundo registro
         q:Skip()

         //  Verifica se o segundo registro é a origem ou o destino
         if (q:getField('uf_origem') == uf_origem)
            pInter := Val(q:getField('uf_' + uf_destino))
         endif
         if (q:getField('uf_origem') == uf_destino)
            pFim := Val(q:getField('uf_' + uf_destino))
         endif
         calcDifal['pICMSUFFim'] := LTrim(Transform(pFim, "99.99"))
         calcDifal['pICMSInter'] := LTrim(Transform(pInter, "99.99"))
         if (pFim > pInter)
            calcDifal['pDIFAL'] := pFim - pInter
            calcDifal['vDIFAL'] := valorPrestacao * (calcDifal['pDIFAL']/100)
            calcDifal['vICMSUFFim'] := hb_ntos(calcDifal['vDIFAL'] + vFCP)
         endif
         calcDifal['tem_difal'] := True
      else
         saveLog({'Consulta SQL não retornou dois registros necessários: SQL: ' + s:value})
      endif
   else
      saveLog('Query não executada: ' + s:value)
   endif
return calcDifal

procedure infCarga(infCarga, rowCTe)
   local p

   with object infCarga
      :vCarga:value := rowCTe:getField('vCarga')
      :proPred:value := rowCTe:getField('proPred')
      :xOutCat:value := rowCTe:getField('xOutCat')
      :infQ:value := {}
      :addInfQ({'cUnid' => "01", 'tpMed' => "PESO BRUTO", 'qCarga' => rowCTe:getField('cte_peso_bruto')})
      :addInfQ({'cUnid' => "01", 'tpMed' => "PESO BC", 'qCarga' => rowCTe:getField('cte_peso_bc')})
      :addInfQ({'cUnid' => "01", 'tpMed' => "PESO CUBADO", 'qCarga' => rowCTe:getField('cte_peso_cubado')})
      :addInfQ({'cUnid' => "00", 'tpMed' => "CUBAGEM", 'qCarga' => rowCTe:getField('cte_cubagem_m3')})
      :addInfQ({'cUnid' => "03", 'tpMed' => "VOLS.", 'qCarga' => rowCTe:getField('cte_qtde_volumes')+'.0000'})
      :infQ:value[5]:qCarga:raw := rowCTe:getField('cte_qtde_volumes')
   endwith
return

procedure infDoc(infDoc, rowCTe, qDoc)
   if qDoc:isExecuted()
      with object infDoc
         // :infNF, :infNFe e :infOutros são arrays de objtos com as classes TinfNFe, TinfNF e TinfOutros respectivamente
         if rowCte:getField('cte_tipo_doc_anexo') == '1'
            do while !qDoc:EOF()
               :addInfNF({'mod' => qDoc:zeroFill('modelo', 2),;
                          'serie' => qDoc:zeroFill('serie', 3),;
                          'nDoc' => qDoc:getField('nDoc'),;
                          'dEmi' => qDoc:getField('dEmi'),;
                          'vBC' => qDoc:getField('vBC'),;
                          'vICMS' => qDoc:getField('vICMS'),;
                          'vBCST' => qDoc:getField('vBCST'),;
                          'vST' => qDoc:getField('vST'),;
                          'vProd' => qDoc:getField('vProd'),;
                          'vNF' => qDoc:getField('vNF'),;
                          'nCFOP' => qDoc:getField('nCFOP'),;
                          'nPeso' => qDoc:getField('nPeso'),;
                          'PIN' => iif((qDoc:getField('PIN') == '0'), '', qDoc:getField('PIN'))})
               qDoc:Skip()
            enddo
         elseif rowCte:getField('cte_tipo_doc_anexo') == '2'
            do while !qDoc:EOF()
               :addInfNFe({'chave' => qDoc:getField('chave'), 'PIN' => iif((qDoc:getField('PIN') == '0'), '', qDoc:getField('PIN'))})
               qDoc:Skip()
            enddo
         else
            if (qDoc:LastRec() == 0)
               saveLog('ctes_documentos: tpDoc = 00 SQL retornou vazio! SQL: ' + qDoc:sql)
            else
               do while !qDoc:EOF()
                  :addInfOutros({'tpDoc' => qDoc:zeroFill('tpDoc', 2),;
                                  'descOutros' => qDoc:getField('descOutros'),;
                                  'nDoc' => qDoc:getField('nDoc'),;
                                  'dEmi' => qDoc:getField('dEmi'),;
                                  'vDocFisc' => qDoc:getField('vDocFisc')})
                  qDoc:Skip()
               enddo
            endif
         endif
      endwith
   endif
   qDoc:Destroy()
return

procedure docAnt(docAnt, rowCTe)
   local s := TSQLString():new("SELECT ")
   local emi, qEmi, qTra

   s:add("cte_eda_id, ")
   s:add("cte_eda_tipo_doc AS tipoDoc, ")
   s:add("cte_eda_cnpj AS CNPJ, ")
   s:add("cte_eda_cpf AS CPF, ")
   s:add("cte_eda_ie AS IE, ")
   s:add("cte_eda_ie_uf AS UF, ")
   s:add("cte_eda_raz_social_nome AS xNome ")
   s:add("FROM ctes_emitentes_ant ")
   s:add("WHERE cte_id = " + rowCte:getField('id') + " ")
   s:add("ORDER BY cte_eda_raz_social_nome")
   qEmi := TSQLQuery():new(s:value)
   saveLog(s:value)

   if qEmi:isExecuted()
      with object docAnt
         :submit := True
         do while !qEmi:EOF()
            emi := :addEmiDocAnt()
            emi:submit := True
            if (qEmi:getField('tipoDoc') == "CNPJ")
               emi:CNPJ:value := qEmi:getField('CNPJ')
               emi:IE:value := qEmi:getField('IE')
            else
               emi:CPF:value := qEmi:getField('CPF')
            endif
            emi:UF:value := qEmi:getField('UF')
            emi:xNome:value := qEmi:getField('xNome')
            s:setValue("SELECT ")
            s:add("cte_dta_tpdoc AS tpDoc, ")
            s:add("cte_dta_serie AS serie, ")
            s:add("cte_dta_sub_serie AS subser, ")
            s:add("cte_dta_numero AS nDoc, ")
            s:add("cte_dta_data_emissao AS dEmi, ")
            s:add("cte_dta_chave AS chCTe ")
            s:add("FROM ctes_doc_transp_ant ")
            s:add("WHERE cte_eda_id = " + qEmi:getField('cte_eda_id')+ " ")
            s:add("ORDER BY cte_dta_chave, cte_dta_serie, cte_dta_sub_serie, cte_dta_numero")
            saveLog(s:value)

            qTra := TSQLQuery():new(s:value)
            if qTra:isExecuted()
               do while !qTra:EOF()
                  if !Empty(qTra:getField('chCTe'))
                     doc := emi:addIdDocAntEle()
                     doc:submit := True
                     doc:chCTe:value := qTra:getField('chCTe')
                  elseif !Empty(qTra:getField('tpDoc'))
                     doc := emi:addIdDocAnt()
                     doc:submit := True
                     doc:tpDoc:raw := qTra:getField('tpDoc')
                     doc:tpDoc:value := qTra:zeroFill('tpDoc', 2)
                     doc:serie:raw := qTra:getField('serie')
                     doc:serie:value := qTra:zeroFill('serie', 3)
                     doc:subser:raw := qTra:getField('subser')
                     doc:subser:value := qTra:zeroFill('subser', 2)
                     doc:nDoc:value := qTra:getField('nDoc')
                     doc:dEmi:value := qTra:getField('dEmi')
                  endif
                  qTra:Skip()
               enddo
            endif
            qTra:Destroy()
            qEmi:Skip()
         enddo
      endwith
   endif
   qEmi:Destroy()
return

procedure rodo(rodo, emi, cte_id)
   local q, oca
   local s := TSQLString():new("SELECT ")

   s:add("oca_numero AS occ, ")
   s:add("oca_data_emissao AS dEmi, ")
   s:add("oca_cnpj_emitente AS CNPJ, ")
   s:add("oca_inscricao_estadual AS IE, ")
   s:add("oca_uf_ie AS UF ")
   s:add("FROM ctes_rod_coletas ")
   s:add("WHERE cte_id = " + cte_id + " ")
   s:add("ORDER BY oca_data_emissao")
   q := TSQLQuery():new(s:value)

   with object rodo
      :submit := True
      :RNTRC:value := emi:getField('RNTRC')
      // Ordens de Coleta Associados
      if q:isExecuted()
         do while !q:EOF()
            oca := :occAdd()
            oca:nOcc:value := q:getField('occ')
            oca:dEmi:value := q:getField('dEmi')
            oca:emiOcc:CNPJ:value := q:getField('CNPJ')
            oca:emiOcc:IE:value := q:getField('IE')
            oca:emiOcc:UF:value := q:getField('UF')
            q:Skip()
         enddo
      endif
   endwith
   q:Destroy()
return

procedure aereo(aereo, rowCTe, qCc)
   local s, q

   s := "SELECT "
   s += "cte_dim_cumprimento * 100 AS cumprimento, "
   s += "cte_dim_altura * 100 AS altura, "
   s += "cte_dim_largura * 100 AS largura, "
   s += "cte_dim_cubagem_m3 "
   s += "FROM ctes_dimensoes "
   s += "WHERE cte_id = " + rowCTe:getField('id') + " "
   s += "ORDER BY cte_dim_cubagem_m3 DESC LIMIT 1"
   q := TSQLQuery():new(s)

   with object aereo
      :submit := True
      :nMinu:raw := rowCTe:getField('cCT')
      :nMinu:value := rowCTe:zeroFill('cCT', 9)
      :nOCA:value := rowCTe:getField('nOCA')
      :dPrevAereo:value := rowCTe:getField('dPrevAereo')
      if q:isExecuted()
         :natCarga:xDime:value := q:zeroFill('cumprimento', 4) + "X" + q:zeroFill('altura', 4) + "X" + q:zeroFill('largura', 4)
         :natCarga:addcInfManu('99') // 99 - Outros; Informações de manuseio para aéreo não implementado, agentes não transportam produtos perigosos
      endif
      q:Destroy()
      if qCc:isExecuted() .and. !qCc:EOF()
         :tarifa:CL:value := hb_uLeft(qCc:getField('CL'), 1)
         :tarifa:cTar:value := rowCTe:getField('cTar') 
         :tarifa:vTar:value := qCc:getField('vTar')
      endif
   endwith

return

procedure veicNovos(infCTeNorm, cte_id)
   local s, q, vn

   s := "SELECT "
   s += "cte_vn_chassi AS chassi, "
   s += "cte_vn_cor AS cCor, "
   s += "cte_vn_descricao_cor AS xCor, "
   s += "cte_vn_modelo AS cMod, "
   s += "cte_vn_valor_unit AS vUnit, "
   s += "cte_vn_frete_unit AS vFrete "
   s += "FROM ctes_veiculos_novos "
   s += "WHERE cte_id = " + cte_id + " "
   s += "ORDER BY cte_vn_chassi"
   q := TSQLQuery():new(s)

   if q:isExecuted()
      with object infCTeNorm
         do while !q:EOF()
            vn := :addVeicNovos()
            vn:chassi:value := q:getField('chassi')
            vn:cCor:value := q:getField('cCor')
            vn:xCor:value := q:getField('xCor')
            vn:cMod:value := q:getField('cMod')
            vn:vUnit:value := q:getField('vUnit')
            vn:vFrete:value := q:getField('vFrete')
            q:Skip()
         enddo
      endwith
   endif

return

procedure autXML(infCte)

   with object infCte
      if !Empty(:rem:email:value)
         :add_autXML({'CNPJ' => :rem:CNPJ:value, 'CPF' => :rem:CPF:value})
      endif
      if !Empty(:dest:email:value)
         :add_autXML({'CNPJ' => :dest:CNPJ:value, 'CPF' => :dest:CPF:value})
      endif
      if !Empty(:exped:email:value)
         :add_autXML({'CNPJ' => :exped:CNPJ:value, 'CPF' => :exped:CPF:value})
      endif
      if !Empty(:receb:email:value)
         :add_autXML({'CNPJ' => :receb:CNPJ:value, 'CPF' => :receb:CPF:value})
      endif
   endwith
return

procedure infGlobalizado(infCte)
   local nfe, cnpj, reme := {}, dest := {}

   with object infCte
      if (:ide:tpCTe:value == '0') .and. (:ide:tpServ:value == '0') .and. (Len(:infCTeNorm:infDoc:infNFe:value) > 4) .and. (:ide:UFIni:value == :ide:UFFim:value)
         for each nfe in :infCTeNorm:infDoc:infNFe:value
            cnpj := SubStr(nfe:chave:value, 7, 14)
            if (cnpj == :rem:CNPJ:value) .and. (hb_AScan(reme, cnpj,,, True) == 0)
               AAdd(reme, cnpj)
            elseif (cnpj == :dest:CNPJ:value) .and. (hb_AScan(dest, cnpj,,, True) == 0)
               AAdd(dest, cnpj)
            endif
         next
         if (:ide:toma3:toma:value == '3') .and. (Len(reme) > 4)
            // Tomador: Destinatário, o número de CNPJ diferentes nas chaves emitidas pelos Remetentes são maior ou igual a 5
            :ide:indGlobalizado:value := '1'
         elseif (:ide:toma3:toma:value == '0') .and. (Len(reme) == 1) .and. (:dest:xNome:value == 'DIVERSOS') .and. (:dest:CNPJ:raw == :emit:CNPJ:raw)
            // Tomador: Remetente, tem mais de 4 NFes, todas as NFes são do mesmo emitente (remetente) e tem vários destinatários
            :ide:indGlobalizado:value := '1'
         else
            :ide:indGlobalizado:value := ''
         endif
      endif
   endwith

return