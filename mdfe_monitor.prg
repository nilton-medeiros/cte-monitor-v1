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


procedure monitorMDFe()
   local s AS OBJECT // sql
   local q AS OBJECT // query
   local r AS OBJECT // row
   local c AS OBJECT // company
   local n := 0
   //local p AS NUMERIC // position

   s := TSQLString():new('SELECT id, ')
   s:add('emp_id, ')
   s:add('cte_seg_id, ')
   s:add('tpEmit, ')
   s:add('tpEmit_rotulo, ')
   s:add('`mod` AS modelo, ')
   s:add('serie, ')
   s:add('nMDF, ')
   s:add('cMDF as chMDFe, ')
   s:add('nProt, ')
   s:add('dhEmi, ')
   s:add('tpEmis, ')
   s:add('tpEmis_rotulo, ')
   s:add('procEmi, ')
   s:add('verProc, ')
   s:add('UFIni, ')
   s:add('UFFim, ')
   s:add('qCTe, ')
   s:add('vCarga, ')
   s:add('cUnid, ')
   s:add('qCarga, ')
   s:add('infAdFisco, ')
   s:add('infCpl, ')
   s:add('lista_tomadores, ')
   s:add('situacao, ')
   s:add('cte_monitor_action ')
   s:add('FROM view_mdfes ')

   if (hmg_len(appData:companies) == 1)
      c := appData:companies[1]
      s:add("WHERE emp_id = " + c:getField('id'))
   else
      s:add("WHERE emp_id IN (")
      for each c in appData:companies
         n++
         if (n > 1)
            s:add(",")
         endif
         s:add(c:getField('id'))
      next
      s:add(")")
   endif

   s:add(" AND cte_monitor_action IN ('SUBMIT','CANCEL','CLOSE') ")
   s:add("ORDER BY cte_monitor_action, emp_id, nMDF")
   q := TSQLQuery():new(s:value)
   // saveLog({'Lendo tabela view_mdfes... query ', iif(q:isExecuted(), 'executada, retornou ' + hb_NtoS(q:LastRec()) + ' registros', 'nao executada'), ': SQL: ', s:value}, ENCRYPTED)
   if q:isExecuted()
      do while !q:EOF()
         r := TModifyToHb():new(q:getRow())
         appData:setUTC(r:getField('emp_id'))
         switch r:getField('cte_monitor_action')
            case 'SUBMIT'  // Enviar
               submitMDFe(r)
               exit
            case 'CANCEL'  // Cancelar
               cancelMDFe(r)
               exit
            case 'CLOSE'   // Encerrar
               closeMDFe(r)
               exit
         endswitch
         q:Skip()
         DO EVENTS
      enddo
   endif
   q:Destroy()

return

procedure submitMDFe(r)
   local mdfe := mdfe_createObject(r)
   mdfe_generateXML(mdfe)
   mdfe := Nil
   msgNotify()
return

procedure cancelMDFe(r)
   local sefaz, p
   local emitente := appData:getCompanies(r:getField('emp_id'))
   msgNotify({'notifyTooltip' => "Cancelando MDFe " + r:getField('id')})

   // {'DFe' => ['CTe'|'MDFe'], 'chDFe' => , 'dfeId' => , 'sysPath' => , 'remotePath' => , 'situacao' => , 'emitCNPJ' => , 'dhEmi' => , 'tpAmb' => emitente:getField('tpAmb')}
   p := {'DFe' => 'MDFe',;
         'dfeId' => r:getField('id'),;
         'chDFe' => r:getField('chMDFe'),;
         'nProt' => r:getField('nProt'),;
         'sysPath' => appData:systemPath,;
         'remotePath' => emitente:getField('remote_file_path') + '/mdf/files',;
         'situacao' => r:getField('situacao'),;
         'emitCNPJ' => emitente:getField('CNPJ'),;
         'dhEmi' => r:getField({'field_name_or_number' => "dhEmi", 'dateTime_as_TDZ' => True}),;
         'tpAmb' => emitente:getField('tpAmb')}

   sefaz := TACBrMonitor():new(p)
   if sefaz:Cancelar()
      updateMDFeStatus(sefaz)
   else
      updateMDFeErrors(sefaz, True)
   endif
   msgNotify()
return

procedure closeMDFe(r)
   local sefaz, p
   local emitente := appData:getCompanies(r:getField('emp_id'))
   msgNotify({'notifyTooltip' => "Encerramento MDFe " + r:getField('id')})

   // {'DFe' => ['CTe'|'MDFe'], 'chDFe' => , 'dfeId' => , 'sysPath' => , 'remotePath' => , 'situacao' => , 'emitCNPJ' => , 'dhEmi' => , 'tpAmb' => emitente:getField('tpAmb')}
   p := {'DFe' => 'MDFe',;
         'dfeId' => r:getField('id'),;
         'chDFe' => r:getField('chMDFe'),;
         'nProt' => r:getField('nProt'),;
         'sysPath' => appData:systemPath,;
         'remotePath' => emitente:getField('remote_file_path') + '/mdf/files',;
         'situacao' => r:getField('situacao'),;
         'emitCNPJ' => emitente:getField('CNPJ'),;
         'dhEmi' => r:getField({'field_name_or_number' => "dhEmi", 'dateTime_as_TDZ' => True}),;
         'tpAmb' => emitente:getField('tpAmb')}

   sefaz := TACBrMonitor():new(p)

   if sefaz:Encerrar(emitente:getField('cMunEnv'))
      updateMDFeStatus(sefaz)
   else
      updateMDFeErrors(sefaz, True)
   endif
   msgNotify()
return
