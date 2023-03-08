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


CLASS TSQLQuery

		DATA query AS OBJECT READONLY
		DATA sql readonly

		method new(sql) constructor
		method setQuery(sql)
		method isExecuted(noWarning)
		method getQuery() INLINE ::query
		method getRow(nRow) INLINE ::query:getRow(nRow)
		method getField(params)
		method goTop() INLINE ::query:goTop()
		method goTo(nRow) INLINE ::query:goTo(nRow)
		method EOF() INLINE ::query:EOF()
		method Skip(nRows) INLINE ::query:Skip(nRows)
		method RecNo() INLINE ::query:RecNo()
		method LastRec() INLINE ::query:LastRec()
		method FCount() INLINE ::query:FCount()
		method Destroy() SETGET
		method serverBusy()
		method padCenter(field_name_or_number, width, fill)
		method padLeft(field_name_or_number, width, fill)
		method padRight(field_name_or_number, width, fill)
		method zeroFill(field_name_or_number, width)

END CLASS

method new(sql) CLASS TSQLQuery

	WITH OBJECT appData
		::sql := sql
		if !:MySQLDataSource:connected
			if !:MySQLDataSource:connect()
				return self
			endif
		endif

		msgNotify({'notifyTooltip' => "Executando query..."})

		if ::setQuery(sql)
			::query:GoTop()
			msgNotify()
		endif

	END

return self

method setQuery(sql) CLASS TSQLQuery
	LOCAL y AS NUMERIC

	WITH OBJECT appData:MySQLDataSource

		::query := :server:Query(sql)

		if (::query == NIL)

			if !:connect()
				msgNotify({'notifyTooltip' => "B.D. não conectado!"})
				saveLog('Banco de Dados não conectado!')
				return False
			endif

			::query := :server:Query(sql)

			if (::query == NIL)
				msgNotify({'notifyTooltip' => "Erro de SQL!"})
				System.Clipboard := 'Erro ao executar ::query![Query is NIL]' + CRLF + CRLF
				System.Clipboard := System.Clipboard + ProcName(2) + '(' + hb_NToS(ProcLine(2)) + ')' + CRLF
				System.Clipboard := System.Clipboard + ProcName(1) + '(' + hb_NToS(ProcLine(1)) + ')' + CRLF
				System.Clipboard := System.Clipboard + ProcName(0) + '(' + hb_NToS(ProcLine(0)) + ')' + CRLF + CRLF
				System.Clipboard := System.Clipboard + CRLF + CRLF + sql
				saveLog(System.Clipboard)
				msgDebugInfo({'Erro ao executar ::query, avise ao suporte!', CRLF+CRLF, 'Ver Clipboard, Erro: Query is NIL'})
				return False
			endif

		endif

		if ::serverBusy()
			::query:Destroy()
			msgNotify({'notifyTooltip' => "Servidor ocupado..."})

			if !:connect()
				msgNotify({'notifyTooltip' => "B.D. não conectado!"})
				saveLog('Banco de Dados não conectado!')
				return False
			endif

			for y:=1 to 2
				::query := :server:Query(sql)
				if !::serverBusy()
					EXIT
				endif

				SysWait(1)

			next

			if ::serverBusy()
				System.Clipboard := 'Servidor ocupado, tente mais tarde!' + CRLF+CRLF
				System.Clipboard := System.Clipboard + ProcName(2) + '(' + hb_NToS(ProcLine(2)) + ')' + CRLF
				System.Clipboard := System.Clipboard + ProcName(1) + '(' + hb_NToS(ProcLine(1)) + ')' + CRLF
				System.Clipboard := System.Clipboard + ProcName(0) + '(' + hb_NToS(ProcLine(0)) + ')' + CRLF + CRLF
				System.Clipboard := System.Clipboard + ::query:Error()
				saveLog(System.Clipboard)
				MsgDebugInfo({'Servidor ocupado, tente mais tarde!', CRLF+CRLF, 'Ver Clipboard, mensagem: ', CRLF, ::query:Error()})
				::query:Destroy()
				return False
			endif

		endif

	END

return True

method serverBusy() CLASS TSQLQuery
return (::query:NetErr() .and. 'server has gone away' $ ::query:Error())

method isExecuted(noWarning) CLASS TSQLQuery
		LOCAL isExecuted := False
		LOCAL table AS CHARACTER
		LOCAL mode AS CHARACTER
		LOCAL command AS CHARACTER
		DEFAULT noWarning := False

		if (::query == NIL)
			msgNotify({'notifyTooltip' => "Database Sem conexão"})
		else

			command := HMG_UPPER(First_String(HB_UTF8STRTRAN(::query:cQuery, ";")))

			do case
			case command $ "SELECT|DELETE"
				table := HB_USUBSTR(::query:cQuery, HB_UAT(' FROM ', ::query:cQuery))
				table := First_String(HB_USUBSTR(table, 7))
				mode := IF(command == 'SELECT', 'selecionar', 'excluir')
			case command == "INSERT"
				table := HB_USUBSTR(::query:cQuery, HB_UAT(' INTO ', ::query:cQuery))
				table := First_String(HB_USUBSTR(table, 7))
				mode := "incluir"
			case command == "UPDATE"
				table := HB_USUBSTR(::query:cQuery, HB_UAT(' ', ::query:cQuery))
				table := First_String(table)
				mode := 'alterar'
			OTHERWISE   // START, ROOLBACK ou COMMIT
				table := ''
				mode :=  'executar transação'
			endcase

			if !Empty(table)
				table := Capitalize(table)
			endif

			if ::query:NetErr()
				if 'Duplicate entry' $ ::query:Error()
					saveLog('Erro de duplicidade ao ' + mode + ' ' + table + CRLF + string_mysql_to_hb(::sql))
				else
					saveLog('Erro ao ' + mode + iif(Empty(table), ' ', ' na tabela de ' + table) + CRLF + ::query:Error() + CRLF + CRLF + string_mysql_to_hb(::query:cQuery))
				endif
				::query:Destroy()
				msgNotify({'notifyTooltip' => "Erro de SQL" + CRLF + "Ver Log do sistema"})
			elseif (command $ "SELECT|START|ROOLBACK|COMMIT")
					// Query SELECT executada com sucesso!
					isExecuted := True
					::query:goTop()
			else
					// Query INSERT, UPDATE ou DELETE executada com sucesso!

					if (mysql_affected_rows(::query:nSocket) == 0) .and. !noWarning
							saveLog('Não foi possível ' + mode + ' na tabela de ' + table + CRLF + 'Registros afetados: ' + hb_NToS(mysql_affected_rows(::query:nSocket)) + CRLF + CRLF + mysql_error(::query:nSocket) + CRLF + CRLF + string_mysql_to_hb(::query:cQuery))
							msgNotify({'notifyTooltip' => "Não foi possível " + mode + " na tabela de " + table + CRLF + "Ver Log do sistema"})
							::query:Destroy()
					elseif (mysql_affected_rows(::query:nSocket) < 0)
							saveLog('Não foi possível ' + mode + ' na tabela de ' + table + CRLF + 'Erro de SQL - Registros afetados: ' + hb_NToS(mysql_affected_rows(::query:nSocket)) + CRLF + CRLF + mysql_error(::query:nSocket) + CRLF + CRLF + string_mysql_to_hb(::query:cQuery))
							msgNotify({'notifyTooltip' => "Não foi possível " + mode + " na tabela de " + table + CRLF + "Ver Log do sistema"})
							::query:Destroy()
					else
							isExecuted := True
					endif
			endif

		endif

return isExecuted

method getField(params) CLASS TSQLQuery
		local fieldResult, fieldGet, field_name_or_number, number_as_string, date_as_string, dateTime_as_string, dateTime_as_TDZ

		default params := 1

		if !ValType(::query) == "O"
			saveLog(iif(::isExecuted(), 'Query/Tabela Executada','Query/Tabela está fechada!') + CRLF + 'SQL: ' + string_mysql_to_hb(::sql))
			//msgDebugInfo({field_name_or_number, ::sql, ::query, number_as_string})
			turnOFF()
		endif

		if hb_isHash(params)
			field_name_or_number := hb_HGetDef(params, 'field_name_or_number', 1)
			number_as_string := hb_HGetDef(params, 'number_as_string', True)
			date_as_string := hb_HGetDef(params, 'date_as_string', True)
			dateTime_as_string := hb_HGetDef(params, 'dateTime_as_string', False)
			dateTime_as_TDZ := hb_HGetDef(params, 'dateTime_as_TDZ', False)
		else
			field_name_or_number := iif(empty(params), 1, params)
			number_as_string := True
			date_as_string := True
			dateTime_as_string := False
			dateTime_as_TDZ := False
		endif

		fieldGet := ::query:FieldGet(field_name_or_number)

		if (ValType(fieldGet) == "C")
			fieldResult := String_MySQL_to_hb(fieldGet)
			if dateTime_as_string
				fieldResult := hb_utf8StrTran(fieldGet, ' ', 'T')
			elseif dateTime_as_TDZ
				fieldResult := hb_utf8StrTran(fieldGet, ' ', 'T') + appData:UTC
			endif
		elseif (valType(fieldGet) == "N") .and. number_as_string
			fieldResult := hb_ntos(fieldGet)
		elseif (ValType(fieldGet) == "D") .and. date_as_string
			fieldResult := Transform(DToS(fieldGet), "@R 9999-99-99")
		endif

return fieldResult

method Destroy() CLASS TSQLQuery
		if !(::query == NIL)
			::query:Destroy()
			::query := NIL
		endif
return NIL

method padCenter(field_name_or_number, width, fill) class TSQLQuery
	default width := ::row:FieldLen(iif(valtype(field_name_or_number) == "N", field_name_or_number, FieldPos(field_name_or_number)))
	default fill := " "
return PadC(::getField(field_name_or_number), width, fill)

method padLeft(field_name_or_number, width, fill) class TSQLQuery
	default width := ::row:FieldLen(iif(valtype(field_name_or_number) == "N", field_name_or_number, FieldPos(field_name_or_number)))
	default fill := " "
return PadL(::getField(field_name_or_number), width, fill)

method padRight(field_name_or_number, width, fill) class TSQLQuery
	default width := ::row:FieldLen(iif(valtype(field_name_or_number) == "N", field_name_or_number, FieldPos(field_name_or_number)))
	default fill := " "
return PadR(::getField(field_name_or_number), width, fill)

method zeroFill(field_name_or_number, width) class TSQLQuery
	default width := ::row:FieldLen(iif(valtype(field_name_or_number) == "N", field_name_or_number, FieldPos(field_name_or_number)))
return PadL(::getField(field_name_or_number), width, "0")
