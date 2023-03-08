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

//#define UM_SEGUNDO 1000
//#define UM_MINUTO 60000

REQUEST HB_CODEPAGE_UTF8

// Atualizado: 2022-11-04 15:00

procedure main
      public appData := TAppData():new("1.2.92")
      if HMG SUPPORT UNICODE RUN
      hb_langSelect('PT')
      hb_cdpSelect('UTF8')
      SET CODEPAGE TO UNICODE
      SET LANGUAGE TO PORTUGUESE
      SET MULTIPLE OFF
      SET TOOLTIPSTYLE BALLOON
      SET NAVIGATION EXTENDED // Simula tecla TAB ao teclar ENTER nos campos do formulário
      SET DATE BRITISH
      SET CENTURY ON
      SET EPOCH TO year(date()) - 20
      appData:registerSystem()
      LOAD WINDOW Main
      Main.CENTER
      Main.ACTIVATE
return

procedure about()
      ShellAbout( "CTeMonitor", ;
      "Monitoramento de CT-es emitidos pelo sistema web TMS.CLOUD " + ;
      appData:version + CRLF + Chr(169) + ;
      " by Sistrom Sistemas Web, 2010-" + hb_ntos(year(date())) + " | suporte@sistrom.com.br" , ;
      LoadTrayIcon(GetInstance(), "MAIN") )
return

procedure turnOFF(isUser)
      default isUser := False
      SetProperty("Main", "TimerCTe", "Enabled", False)
      if isUser
         saveLog('Sistema encerrado pelo usuário')
      else
         saveLog('Sistema encerrou a execução')
      endif
      RegistryWrite(appData:registryPath + "Monitoring\Running", 0)
      RELEASE WINDOW ALL
return

procedure mainForm_onInit()
      SetProperty("Main", "TimerCTe", "Enabled", False)
      if (RegistryRead(appData:registryPath + "Monitoring\DontRun") == 1)
         saveLog('Parada forçada: O parâmetro DontRun está ativo')
         MessageBoxTimeout('O parâmetro DontRun está ativo!', 'Parada forçada', MB_ICONEXCLAMATION, 5000 )
         turnOFF()
      endif
      with object appData
         :registerDatabase()
         if :MySQLDataSource:connect()
            loadCompanies()
            loadAdminUsers()
         else
            turnOFF()
         endif
         if !:ACBr:installedStatus
            MsgExclamation('ACBrMonitor não está instalado!', 'ACBrMonitor: Avise o suporte')
            turnOFF()
         endif
         if !:ACBr:activeStatus
            MsgExclamation('ACBrMonitor não está executando!', 'ACBrMonitor: Avise o suporte')
            turnOFF()
         endif
         SetProperty('Main', 'notifyIcon', 'ntfyICON')
      endwith
      SetProperty('Main', 'TimerCTe', 'Enabled', True)
return

procedure main_timerCTe_action()
   local time := hb_ULeft(Time(), 5)

   SetProperty("Main", "TimerCTe", "Enabled", False)

   if isWindowActive(setup)
      appData:timer := Seconds()
      return
   endif
   if (RegistryRead(appData:registryPath + "Monitoring\Stop_Execution") == 1)
      saveLog("Parada forçada para atualização")
      turnOFF()
   endif
   // :startTime e :endTime são período de Inatividade
   if (appData:startTime < appData:endTime)
      // Inatividade dentro do mesmo dia
      if (time >= appData:startTime) .and. (time <= appData:endTime)
         // Período de intatividade dentro do dia
         SetProperty("Main", "TimerCTe", "Enabled", True)
         appData:timer := Seconds()
         return
      endif
   else
      // Inatividade de um dia para o outro
      if ((time >= appData:startTime) .and. (time <= '23:59')) .or. ((time >= '00:00') .and. (time <= appData:endTime))
         // Período de intatividade entre antes da meia noite e madrugada
         SetProperty("Main", "TimerCTe", "Enabled", True)
         appData:timer := Seconds()
         return
      endif
   endif

   if ((Seconds() - appData:timer) >= appData:frequency)
      monitorCTe()
      monitorMDFe()
      //monitorGetFiles()
      appData:timer := Seconds()
   endif

   SetProperty('Main', 'TimerCTe', 'Enabled', True)

return
