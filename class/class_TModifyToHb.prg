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


class TModifyToHb
	data row PROTECTED
	method new(row) constructor
	method getField(field_name_or_number, number_as_string)
	method padCenter(field_name_or_number, width, fill)
	method padLeft(field_name_or_number, width, fill)
	method padRight(field_name_or_number, width, fill)
	method zeroFill(field_name_or_number, width)
end class

method new(row) class TModifyToHb
	::row := row
return Self

method getField(params) CLASS TModifyToHb
	local fieldResult, fieldGet, field_name_or_number, number_as_string, date_as_string, dateTime_as_string, dateTime_as_TDZ

	default params := 1

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
	fieldGet := ::row:fieldGet(field_name_or_number)

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

method padCenter(field_name_or_number, width, fill) class TModifyToHb
	default width := ::row:FieldLen(iif(valtype(field_name_or_number) == "N", field_name_or_number, FieldPos(field_name_or_number)))
	default fill := " "
return PadC(::getField(field_name_or_number), width, fill)

method padLeft(field_name_or_number, width, fill) class TModifyToHb
	default width := ::row:FieldLen(iif(valtype(field_name_or_number) == "N", field_name_or_number, FieldPos(field_name_or_number)))
	default fill := " "
return PadL(::getField(field_name_or_number), width, fill)

method padRight(field_name_or_number, width, fill) class TModifyToHb
	default width := ::row:FieldLen(iif(valtype(field_name_or_number) == "N", field_name_or_number, FieldPos(field_name_or_number)))
	default fill := " "
return PadR(::getField(field_name_or_number), width, fill)

method zeroFill(field_name_or_number, width) class TModifyToHb
	default width := ::row:FieldLen(iif(valtype(field_name_or_number) == "N", field_name_or_number, FieldPos(field_name_or_number)))
return PadL(::getField(field_name_or_number), width, "0")
