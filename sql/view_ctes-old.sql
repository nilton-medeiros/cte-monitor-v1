-- Conferido- Baixado do DB tmscte_ap em 2022-mm-dd as hh:mm - descricao
CREATE OR REPLACE VIEW view_ctes AS
SELECT t1.cte_id AS cte_id,
       t1.emp_id AS emp_id,
       t23.emp_cnpj AS emp_cnpj,
       t1.clie_representante_id AS clie_representante_id,
       t1.clie_remetente_id AS clie_remetente_id,
       t1.clie_coleta_id AS clie_coleta_id,
       t1.clie_expedidor_id AS clie_expedidor_id,
       t1.clie_recebedor_id AS clie_recebedor_id,
       t1.clie_destinatario_id AS clie_destinatario_id,
       t1.clie_entrega_id AS clie_entrega_id,
       t1.clie_tomador_id AS clie_tomador_id,
       t1.cid_id_origem AS cid_id_origem,
       t1.cid_id_destino AS cid_id_destino,
       t1.cid_id_passagem AS cid_id_passagem,
       t1.prod_id AS prod_id,
       t1.cid_id_etiqueta_entrega AS cid_id_etiqueta_entrega,
       t1.cte_endereco_etiqueta_entrega AS cte_endereco_etiqueta_entrega,
       t1.cte_versao_leiaute_xml AS cte_versao_leiaute_xml,
       t1.cte_minuta AS cte_minuta,
       t1.cte_modelo AS cte_modelo,
       t1.cte_serie AS cte_serie,
       t1.cte_numero AS cte_numero,
       t1.cte_chave AS cte_chave,
       t1.cte_protocolo_autorizacao AS cte_protocolo_autorizacao,
       t1.cte_data_hora_emissao AS cte_data_hora_emissao,
       t1.cte_remetente AS cte_remetente,
       t1.cte_outro_local_coleta AS cte_outro_local_coleta,
       t1.cte_expedidor AS cte_expedidor,
       t1.cte_recebedor AS cte_recebedor,
       t1.cte_destinatario AS cte_destinatario,
       t1.cte_outro_local_entrega AS cte_outro_local_entrega,
       t1.cte_tomador AS cte_tomador,
       t1.cte_modal AS cte_modal,
       t1.cte_emissora_master AS cte_emissora_master,
       t1.cte_cia_master AS cte_cia_master,
       t1.cte_serie_master AS cte_serie_master,
       t1.cte_numero_master AS cte_numero_master,
       t1.cte_operacional_master AS cte_operacional_master,
       t1.cte_chave_master AS cte_chave_master,
       t1.cte_chave_referenciado AS cte_chave_referenciado,
       t1.cte_data_emissao_declaracao_tom AS cte_data_emissao_declaracao_tom,
       t1.cte_natureza_operacao AS cte_natureza_operacao,
       t1.cte_tipo_servico AS cte_tipo_servico,
       t1.cte_tipo_do_cte AS cte_tipo_do_cte,
       t1.cte_forma_emissao AS cte_forma_emissao,
       t1.cte_codigo_rota AS cte_codigo_rota,
       t1.cte_forma_pgto AS cte_forma_pgto,
       t1.cte_impressao_dacte AS cte_impressao_dacte,
       t1.cte_cfop AS cte_cfop,
       t1.cte_tabela_frete AS cte_tabela_frete,
       t1.cte_tabela_id AS cte_tabela_id,
       t1.redespacho_id AS redespacho_id,
       t1.cte_frete_manual AS cte_frete_manual,
       t1.cte_carac_adic_transp AS cte_carac_adic_transp,
       t1.cte_carac_adic_servico AS cte_carac_adic_servico,
       t1.cte_emissor AS cte_emissor,
       t1.cte_retira AS cte_retira,
       t1.cte_detalhe_retira AS cte_detalhe_retira,
       t1.cte_tp_data_entrega AS cte_tp_data_entrega,
       t1.cte_data_programada AS cte_data_programada,
       t1.cte_data_inicial AS cte_data_inicial,
       t1.cte_data_final AS cte_data_final,
       t1.cte_tp_hora_entrega AS cte_tp_hora_entrega,
       t1.cte_hora_programada AS cte_hora_programada,
       t1.cte_hora_inicial AS cte_hora_inicial,
       t1.cte_hora_final AS cte_hora_final,
       t1.cte_obs_gerais AS cte_obs_gerais,
       t1.cte_outras_carac_carga AS cte_outras_carac_carga,
       t1.cte_peso_bruto AS cte_peso_bruto,
       t1.cte_peso_cubado AS cte_peso_cubado,
       t1.cte_peso_bc AS cte_peso_bc,
       t1.cte_cubagem_m3 AS cte_cubagem_m3,
       t1.cte_qtde_volumes AS cte_qtde_volumes,
       t1.cte_codigo_sit_tributaria AS cte_codigo_sit_tributaria,
       t1.cte_hb_cod_sit_tributaria AS cte_hb_cod_sit_tributaria,
       t1.cte_valor_carga AS cte_valor_carga,
       t1.cte_valor_total AS cte_valor_total,
       t1.cte_perc_reduc_bc AS cte_perc_reduc_bc,
       t1.cte_valor_bc AS cte_valor_bc,
       t1.cte_aliquota_icms AS cte_aliquota_icms,
       t1.cte_valor_icms AS cte_valor_icms,
       t1.cte_valor_cred_outorgado AS cte_valor_cred_outorgado,
       t1.cte_valor_pis AS cte_valor_pis,
       t1.cte_valor_cofins AS cte_valor_cofins,
       t1.cte_info_fisco AS cte_info_fisco,
       t1.cte_tipo_doc_anexo AS cte_tipo_doc_anexo,
       t1.cte_data_entrega_prevista AS cte_data_entrega_prevista,
       t1.cte_data_entrega_efetuada AS cte_data_entrega_efetuada,
       t1.cte_indicador_lotacao AS cte_indicador_lotacao,
       t1.cte_ciot AS cte_ciot,
       t1.cte_situacao AS cte_situacao,
       t1.cte_monitor_action AS cte_monitor_action,
       t1.cte_xml AS cte_xml,
       t1.cte_pdf AS cte_pdf,
       t1.cte_cancelado_xml AS cte_cancelado_xml,
       t1.cte_cancelado_pdf AS cte_cancelado_pdf,
       t1.cte_dacte_impresso AS cte_dacte_impresso,
       t1.cte_email_enviado AS cte_email_enviado,
       t1.cte_exibe_consulta_fatura AS cte_exibe_consulta_fatura,
       t1.cte_exibe_consulta_cliente AS cte_exibe_consulta_cliente,
       t1.cte_tipo_coleta AS cte_tipo_coleta,
       t1.cte_arquivos_baixados AS cte_arquivos_baixados,
       t1.cte_cadastrado_por AS cte_cadastrado_por,
       t1.cte_cadastrado_em AS cte_cadastrado_em,
       t1.cte_alterado_por AS cte_alterado_por,
       t1.cte_alterado_em AS cte_alterado_em,
       t1.cte_versao AS cte_versao,
       if((t4.cta_rec_id > 0), 1, 0) AS cte_faturado,
       t5.clie_razao_social AS rem_razao_social,
       t5.clie_nome_fantasia AS rem_nome_fantasia,
       t5.clie_tipo_documento AS rem_tipo_documento,
       t5.clie_cnpj AS rem_cnpj,
       t5.clie_cpf AS rem_cpf,
       if(
         (
           (t5.clie_cnpj is not null)
           and (t5.clie_cnpj <> '')
         ),
         t5.clie_cnpj,
         t5.clie_cpf
       ) AS rem_cnpj_cpf,
       t5.clie_inscr_estadual AS rem_ie,
       t5.clie_rg AS rem_rg,
       t5.clie_inscr_municipal AS rem_im,
       t5.clie_contrib_icms AS rem_icms,
       t5.clie_logradouro AS rem_end_logradouro,
       t5.clie_numero AS rem_end_numero,
       t5.clie_complemento AS rem_end_complemento,
       t5.clie_bairro AS rem_end_bairro,
       t5.clie_cep AS rem_end_cep,
       t5.clie_fone1 AS rem_fone,
       left(cid5.cid_codigo_municipio, 2) AS rem_cid_codigo_uf,
       cid5.cid_codigo_municipio AS rem_cid_codigo_municipio,
       cid5.cid_municipio AS rem_cid_municipio,
       cid5.cid_uf AS rem_cid_uf,
       cid5.cid_sigla AS rem_cid_sigla,
       cid5.cid_nome_aeroporto AS rem_cid_nome_aeroporto,
       concat_ws(' - ', cid5.cid_uf, cid5.cid_municipio) AS rem_cid_nome,
       concat(
         cid5.cid_uf,
         ' - ',
         cid5.cid_municipio,
         if(
           (
             (cid5.cid_nome_aeroporto is not null)
             and (cid5.cid_nome_aeroporto <> '')
             and (cid5.cid_sigla is not null)
             and (cid5.cid_sigla <> '')
           ),
           concat(
             ' (',
             cid5.cid_sigla,
             ' - ',
             cid5.cid_nome_aeroporto,
             ')'
           ),
           ''
         )
       ) AS rem_cid_nome_completo,
       t6.clie_razao_social AS col_razao_social,
       t6.clie_nome_fantasia AS col_nome_fantasia,
       t6.clie_tipo_documento AS col_tipo_documento,
       t6.clie_cnpj AS col_cnpj,
       t6.clie_cpf AS col_cpf,
       if(
         (
           (t6.clie_cnpj is not null)
           and (t6.clie_cnpj <> '')
         ),
         t6.clie_cnpj,
         t6.clie_cpf
       ) AS col_cnpj_cpf,
       t6.clie_inscr_estadual AS col_ie,
       t6.clie_rg AS col_rg,
       t6.clie_inscr_municipal AS col_im,
       t6.clie_contrib_icms AS col_icms,
       t6.clie_logradouro AS col_end_logradouro,
       t6.clie_numero AS col_end_numero,
       t6.clie_complemento AS col_end_complemento,
       t6.clie_bairro AS col_end_bairro,
       t6.clie_cep AS col_end_cep,
       t6.clie_fone1 AS col_fone,
       left(cid6.cid_codigo_municipio, 2) AS col_cid_codigo_uf,
       cid6.cid_codigo_municipio AS col_cid_codigo_municipio,
       cid6.cid_municipio AS col_cid_municipio,
       cid6.cid_uf AS col_cid_uf,
       cid6.cid_sigla AS col_cid_sigla,
       cid6.cid_nome_aeroporto AS col_cid_nome_aeroporto,
       concat_ws(' - ', cid6.cid_uf, cid6.cid_municipio) AS col_cid_nome,
       concat(
         cid6.cid_uf,
         ' - ',
         cid6.cid_municipio,
         if(
           (
             (cid6.cid_nome_aeroporto is not null)
             and (cid6.cid_nome_aeroporto <> '')
             and (cid6.cid_sigla is not null)
             and (cid6.cid_sigla <> '')
           ),
           concat(
             ' (',
             cid6.cid_sigla,
             ' - ',
             cid6.cid_nome_aeroporto,
             ')'
           ),
           ''
         )
       ) AS col_cid_nome_completo,
       t7.clie_razao_social AS exp_razao_social,
       t7.clie_nome_fantasia AS exp_nome_fantasia,
       t7.clie_tipo_documento AS exp_tipo_documento,
       t7.clie_cnpj AS exp_cnpj,
       t7.clie_cpf AS exp_cpf,
       if(
         (
           (t7.clie_cnpj is not null)
           and (t7.clie_cnpj <> '')
         ),
         t7.clie_cnpj,
         t7.clie_cpf
       ) AS exp_cnpj_cpf,
       t7.clie_inscr_estadual AS exp_ie,
       t7.clie_rg AS exp_rg,
       t7.clie_inscr_municipal AS exp_im,
       t7.clie_contrib_icms AS exp_icms,
       t7.clie_logradouro AS exp_end_logradouro,
       t7.clie_numero AS exp_end_numero,
       t7.clie_complemento AS exp_end_complemento,
       t7.clie_bairro AS exp_end_bairro,
       t7.clie_cep AS exp_end_cep,
       t7.clie_fone1 AS exp_fone,
       left(cid7.cid_codigo_municipio, 2) AS exp_cid_codigo_uf,
       cid7.cid_codigo_municipio AS exp_cid_codigo_municipio,
       cid7.cid_municipio AS exp_cid_municipio,
       cid7.cid_uf AS exp_cid_uf,
       cid7.cid_sigla AS exp_cid_sigla,
       cid7.cid_nome_aeroporto AS exp_cid_nome_aeroporto,
       concat_ws(' - ', cid7.cid_uf, cid7.cid_municipio) AS exp_cid_nome,
       concat(
         cid7.cid_uf,
         ' - ',
         cid7.cid_municipio,
         if(
           (
             (cid7.cid_nome_aeroporto is not null)
             and (cid7.cid_nome_aeroporto <> '')
             and (cid7.cid_sigla is not null)
             and (cid7.cid_sigla <> '')
           ),
           concat(
             ' (',
             cid7.cid_sigla,
             ' - ',
             cid7.cid_nome_aeroporto,
             ')'
           ),
           ''
         )
       ) AS exp_cid_nome_completo,
       t8.clie_razao_social AS rec_razao_social,
       t8.clie_nome_fantasia AS rec_nome_fantasia,
       t8.clie_tipo_documento AS rec_tipo_documento,
       t8.clie_cnpj AS rec_cnpj,
       t8.clie_cpf AS rec_cpf,
       if(
         (
           (t8.clie_cnpj is not null)
           and (t8.clie_cnpj <> '')
         ),
         t8.clie_cnpj,
         t8.clie_cpf
       ) AS rec_cnpj_cpf,
       t8.clie_inscr_estadual AS rec_ie,
       t8.clie_rg AS rec_rg,
       t8.clie_inscr_municipal AS rec_im,
       t8.clie_contrib_icms AS rec_icms,
       t8.clie_logradouro AS rec_end_logradouro,
       t8.clie_numero AS rec_end_numero,
       t8.clie_complemento AS rec_end_complemento,
       t8.clie_bairro AS rec_end_bairro,
       t8.clie_cep AS rec_end_cep,
       t8.clie_fone1 AS rec_fone,
       left(cid8.cid_codigo_municipio, 2) AS rec_cid_codigo_uf,
       cid8.cid_codigo_municipio AS rec_cid_codigo_municipio,
       cid8.cid_municipio AS rec_cid_municipio,
       cid8.cid_uf AS rec_cid_uf,
       cid8.cid_sigla AS rec_cid_sigla,
       cid8.cid_nome_aeroporto AS rec_cid_nome_aeroporto,
       concat_ws(' - ', cid8.cid_uf, cid8.cid_municipio) AS rec_cid_nome,
       concat(
         cid8.cid_uf,
         ' - ',
         cid8.cid_municipio,
         if(
           (
             (cid8.cid_nome_aeroporto is not null)
             and (cid8.cid_nome_aeroporto <> '')
             and (cid8.cid_sigla is not null)
             and (cid8.cid_sigla <> '')
           ),
           concat(
             ' (',
             cid8.cid_sigla,
             ' - ',
             cid8.cid_nome_aeroporto,
             ')'
           ),
           ''
         )
       ) AS rec_cid_nome_completo,
       t9.clie_razao_social AS des_razao_social,
       t9.clie_nome_fantasia AS des_nome_fantasia,
       t9.clie_tipo_documento AS des_tipo_documento,
       t9.clie_cnpj AS des_cnpj,
       t9.clie_cpf AS des_cpf,
       if(
         (
           (t9.clie_cnpj is not null)
           and (t9.clie_cnpj <> '')
         ),
         t9.clie_cnpj,
         t9.clie_cpf
       ) AS des_cnpj_cpf,
       t9.clie_inscr_estadual AS des_ie,
       t9.clie_rg AS des_rg,
       t9.clie_inscr_municipal AS des_im,
       t9.clie_contrib_icms AS des_icms,
       t9.clie_logradouro AS des_end_logradouro,
       t9.clie_numero AS des_end_numero,
       t9.clie_complemento AS des_end_complemento,
       t9.clie_bairro AS des_end_bairro,
       t9.clie_cep AS des_end_cep,
       t9.clie_fone1 AS des_fone,
       left(cid9.cid_codigo_municipio, 2) AS des_cid_codigo_uf,
       cid9.cid_codigo_municipio AS des_cid_codigo_municipio,
       cid9.cid_municipio AS des_cid_municipio,
       cid9.cid_uf AS des_cid_uf,
       cid9.cid_sigla AS des_cid_sigla,
       cid9.cid_nome_aeroporto AS des_cid_nome_aeroporto,
       concat_ws(' - ', cid9.cid_uf, cid9.cid_municipio) AS des_cid_nome,
       concat(
         cid9.cid_uf,
         ' - ',
         cid9.cid_municipio,
         if(
           (
             (cid9.cid_nome_aeroporto is not null)
             and (cid9.cid_nome_aeroporto <> '')
             and (cid9.cid_sigla is not null)
             and (cid9.cid_sigla <> '')
           ),
           concat(
             ' (',
             cid9.cid_sigla,
             ' - ',
             cid9.cid_nome_aeroporto,
             ')'
           ),
           ''
         )
       ) AS des_cid_nome_completo,
       t10.clie_razao_social AS ent_razao_social,
       t10.clie_nome_fantasia AS ent_nome_fantasia,
       t10.clie_tipo_documento AS ent_tipo_documento,
       t10.clie_cnpj AS ent_cnpj,
       t10.clie_cpf AS ent_cpf,
       if(
         (
           (t10.clie_cnpj is not null)
           and (t10.clie_cnpj <> '')
         ),
         t10.clie_cnpj,
         t10.clie_cpf
       ) AS ent_cnpj_cpf,
       t10.clie_inscr_estadual AS ent_ie,
       t10.clie_rg AS ent_rg,
       t10.clie_inscr_municipal AS ent_im,
       t10.clie_contrib_icms AS ent_icms,
       t10.clie_logradouro AS ent_end_logradouro,
       t10.clie_numero AS ent_end_numero,
       t10.clie_complemento AS ent_end_complemento,
       t10.clie_bairro AS ent_end_bairro,
       t10.clie_cep AS ent_end_cep,
       t10.clie_fone1 AS ent_fone,
       left(cid10.cid_codigo_municipio, 2) AS ent_cid_codigo_uf,
       cid10.cid_codigo_municipio AS ent_cid_codigo_municipio,
       cid10.cid_municipio AS ent_cid_municipio,
       cid10.cid_uf AS ent_cid_uf,
       cid10.cid_sigla AS ent_cid_sigla,
       cid10.cid_nome_aeroporto AS ent_cid_nome_aeroporto,
       concat_ws(' - ', cid10.cid_uf, cid10.cid_municipio) AS ent_cid_nome,
       concat(
         cid10.cid_uf,
         ' - ',
         cid10.cid_municipio,
         if(
           (
             (cid10.cid_nome_aeroporto is not null)
             and (cid10.cid_nome_aeroporto <> '')
             and (cid10.cid_sigla is not null)
             and (cid10.cid_sigla <> '')
           ),
           concat(
             ' (',
             cid10.cid_sigla,
             ' - ',
             cid10.cid_nome_aeroporto,
             ')'
           ),
           ''
         )
       ) AS ent_cid_nome_completo,
       left(t19.cid_codigo_municipio, 2) AS ent_etiqueta_cid_codigo_uf,
       t19.cid_codigo_municipio AS ent_etiqueta_cid_codigo_municipio,
       t19.cid_municipio AS ent_etiqueta_cid_municipio,
       t19.cid_uf AS ent_etiqueta_cid_uf,
       t19.cid_sigla AS ent_etiqueta_cid_sigla,
       t19.cid_nome_aeroporto AS ent_etiqueta_cid_nome_aeroporto,
       concat_ws(' - ', t19.cid_uf, t19.cid_municipio) AS ent_etiqueta_cid_nome,
       concat(
         t19.cid_uf,
         ' - ',
         t19.cid_municipio,
         if(
           (
             (t19.cid_nome_aeroporto is not null)
             and (t19.cid_nome_aeroporto <> '')
             and (t19.cid_sigla is not null)
             and (t19.cid_sigla <> '')
           ),
           concat(
             ' (',
             t19.cid_sigla,
             ' - ',
             t19.cid_nome_aeroporto,
             ')'
           ),
           ''
         )
       ) AS ent_etiqueta_cid_nome_completo,
       t11.clie_razao_social AS tom_razao_social,
       t11.clie_nome_fantasia AS tom_nome_fantasia,
       t11.clie_tipo_documento AS tom_tipo_documento,
       t11.clie_cnpj AS tom_cnpj,
       t11.clie_cpf AS tom_cpf,
       if(
         (
           (t11.clie_cnpj is not null)
           and (t11.clie_cnpj <> '')
         ),
         t11.clie_cnpj,
         t11.clie_cpf
       ) AS tom_cnpj_cpf,
       t11.clie_inscr_estadual AS tom_ie,
       t11.clie_ie_isento AS tom_ie_isento,
       t11.clie_rg AS tom_rg,
       t11.clie_inscr_municipal AS tom_im,
       t11.clie_contrib_icms AS tom_icms,
       t11.clie_logradouro AS tom_end_logradouro,
       t11.clie_numero AS tom_end_numero,
       t11.clie_complemento AS tom_end_complemento,
       t11.clie_bairro AS tom_end_bairro,
       t11.clie_cep AS tom_end_cep,
       t11.clie_fone1 AS tom_fone,
       left(cid11.cid_codigo_municipio, 2) AS tom_cid_codigo_uf,
       cid11.cid_codigo_municipio AS tom_cid_codigo_municipio,
       cid11.cid_municipio AS tom_cid_municipio,
       cid11.cid_uf AS tom_cid_uf,
       cid11.cid_sigla AS tom_cid_sigla,
       cid11.cid_nome_aeroporto AS tom_cid_nome_aeroporto,
       t22.clie_razao_social AS rep_razao_social,
       t22.clie_nome_fantasia AS rep_nome_fantasia,
       t22.clie_tipo_documento AS rep_tipo_documento,
       if(
         (
           (t22.clie_cnpj is not null)
           and (t22.clie_cnpj <> '')
         ),
         t22.clie_cnpj,
         t22.clie_cpf
       ) AS rep_cnpj_cpf,
       concat_ws(' - ', cid11.cid_uf, cid11.cid_municipio) AS tom_cid_nome,
       concat(
         cid11.cid_uf,
         ' - ',
         cid11.cid_municipio,
         if(
           (
             (cid11.cid_nome_aeroporto is not null)
             and (cid11.cid_nome_aeroporto <> '')
             and (cid11.cid_sigla is not null)
             and (cid11.cid_sigla <> '')
           ),
           concat(
             ' (',
             cid11.cid_sigla,
             ' - ',
             cid11.cid_nome_aeroporto,
             ')'
           ),
           ''
         )
       ) AS tom_cid_nome_completo,
       left(t12.cid_codigo_municipio, 2) AS cid_origem_codigo_uf,
       t12.cid_codigo_municipio AS cid_origem_codigo_municipio,
       t12.cid_municipio AS cid_origem_municipio,
       t12.cid_uf AS cid_origem_uf,
       t12.cid_sigla AS cid_origem_sigla,
       t12.cid_nome_aeroporto AS cid_origem_nome_aeroporto,
       concat_ws(' - ', t12.cid_uf, t12.cid_municipio) AS cid_origem_nome,
       concat(
         t12.cid_uf,
         ' - ',
         t12.cid_municipio,
         if(
           (
             (t12.cid_nome_aeroporto is not null)
             and (t12.cid_nome_aeroporto <> '')
             and (t12.cid_sigla is not null)
             and (t12.cid_sigla <> '')
           ),
           concat(
             ' (',
             t12.cid_sigla,
             ' - ',
             t12.cid_nome_aeroporto,
             ')'
           ),
           ''
         )
       ) AS cid_origem_nome_completo,
       left(t13.cid_codigo_municipio, 2) AS cid_destino_codigo_uf,
       t13.cid_codigo_municipio AS cid_destino_codigo_municipio,
       t13.cid_municipio AS cid_destino_municipio,
       t13.cid_uf AS cid_destino_uf,
       t13.cid_sigla AS cid_destino_sigla,
       t13.cid_nome_aeroporto AS cid_destino_nome_aeroporto,
       concat_ws(' - ', t13.cid_uf, t13.cid_municipio) AS cid_destino_nome,
       concat(
         t13.cid_uf,
         ' - ',
         t13.cid_municipio,
         if(
           (
             (t13.cid_nome_aeroporto is not null)
             and (t13.cid_nome_aeroporto <> '')
             and (t13.cid_sigla is not null)
             and (t13.cid_sigla <> '')
           ),
           concat(
             ' (',
             t13.cid_sigla,
             ' - ',
             t13.cid_nome_aeroporto,
             ')'
           ),
           ''
         )
       ) AS cid_destino_nome_completo,
       left(t14.cid_codigo_municipio, 2) AS cid_passagem_codigo_uf,
       t14.cid_codigo_municipio AS cid_passagem_codigo_municipio,
       t14.cid_municipio AS cid_passagem_municipio,
       t14.cid_uf AS cid_passagem_uf,
       t14.cid_sigla AS cid_passagem_sigla,
       t14.cid_nome_aeroporto AS cid_passagem_nome_aeroporto,
       concat_ws(' - ', t14.cid_uf, t14.cid_municipio) AS cid_passagem_nome,
       concat(
         t14.cid_uf,
         ' - ',
         t14.cid_municipio,
         if(
           (
             (t14.cid_nome_aeroporto is not null)
             and (t14.cid_nome_aeroporto <> '')
             and (t14.cid_sigla is not null)
             and (t14.cid_sigla <> '')
           ),
           concat(
             ' (',
             t14.cid_sigla,
             ' - ',
             t14.cid_nome_aeroporto,
             ')'
           ),
           ''
         )
       ) AS cid_passagem_nome_completo,
       t17.iic_codigo AS iic_codigo,
       t15.gt_id_codigo AS gt_id_codigo,
       t15.prod_produto AS produto_predominante_nome,
       concat_ws(' - ', t15.prod_codigo, t15.prod_produto) AS produto_predominante,
       concat_ws(' - ', t17.iic_codigo, t17.iic_descricao) AS produto_predominante_iic,
       t16.gt_descricao AS produto_predominante_gt,(
         case
           t1.cte_modal
           when 1 then '01 - Rodoviário'
           when 2 then '02 - Aéreo'
           when 3 then '03 - Aquaviário'
           when 4 then '04 - Ferroviário'
           when 5 then '05 - Dutoviário'
           when 6 then '06 - Multimodal'
           else '(indefinido)'
         end
       ) AS cte_modal_nome,(
         case
           t1.cte_tipo_servico
           when 0 then '0 - Normal'
           when 1 then '1 - Subcontratação'
           when 2 then '2 - Redespacho'
           when 3 then '3 - Redespacho Intermediário'
           when 4 then '4 - Serviço Vinculado à Multimodal'
           else '(indefinido)'
         end
       ) AS cte_tipo_servico_nome,(
         case
           t1.cte_tipo_do_cte
           when 0 then '0 - CT-e Normal'
           when 1 then '1 - CT-e de Complemento de Valores'
           when 2 then '2 - CT-e de Anulação'
           when 3 then '3 - CT-e Substituto'
           else '(indefinido)'
         end
       ) AS cte_tipo_do_cte_nome,(
         case
           t1.cte_forma_emissao
           when 1 then '1 - Normal'
           when 5 then '5 - Contingência FSDA'
           when 7 then '7 - Autorização pela SVC-RS'
           when 8 then '8 - Autorização pela SVC-SP'
           else '(indefinido)'
         end
       ) AS cte_forma_emissao_nome,(
         case
           t1.cte_remetente
           when 1 then '1 - Com Remetente'
           when 2 then '2 - Sem Remetente: Redespacho Intermediário'
           when 3 then '3 - Sem Remetente: Serviço Vinculado a multimodal'
           else '(indefinido)'
         end
       ) AS cte_remetente_nome,(
         case
           t1.cte_destinatario
           when 1 then '1 - Com Destinatário'
           when 2 then '2 - Sem Destinatário: Redespacho Intermediário'
           when 3 then '3 - Sem Destinatário: Serviço Vinculado a multimodal'
           else '(indefinido)'
         end
       ) AS cte_destinatario_nome,(
         case
           t1.cte_tomador
           when 0 then '0 - Remetente'
           when 1 then '1 - Expedidor'
           when 2 then '2 - Recebedor'
           when 3 then '3 - Destinatário'
           when 4 then '4 - Outros'
           else '(indefinido)'
         end
       ) AS cte_tomador_nome,(
         case
           t1.cte_forma_pgto
           when 0 then '0 - Pago'
           when 1 then '1 - A Pagar'
           when 2 then '2 - Outros'
           else '(indefinido)'
         end
       ) AS cte_forma_pgto_nome,(
         case
           t1.cte_impressao_dacte
           when 1 then '1 - Retrato'
           when 2 then '2 - Paisagem'
           else '(indefinido)'
         end
       ) AS cte_impressao_dacte_nome,(
         case
           t1.cte_tp_data_entrega
           when 0 then '0 - Sem data definida'
           when 1 then '1 - Na data'
           when 2 then '2 - Até a data'
           when 3 then '3 - A partir da data'
           when 4 then '4 – No período'
           else '(indefinido)'
         end
       ) AS cte_tp_data_entrega_nome,(
         case
           t1.cte_tp_hora_entrega
           when 0 then '0 - Sem hora definida'
           when 1 then '1 - Na hora'
           when 2 then '2 - Até a hora'
           when 3 then '3 - A partir da hora'
           when 4 then '4 – No intervalo de tempo'
           else '(indefinido)'
         end
       ) AS cte_tp_hora_entrega_nome,(
         case
           t1.cte_codigo_sit_tributaria
           when 1 then '1 - (00 - Tribut. normal do ICMS)'
           when 2 then '2 - (20 - Tribut. com redução de BC do ICMS)'
           when 3 then '3 - (40 - ICMS isenção)'
           when 4 then '4 - (41 - ICMS não tribut)'
           when 5 then '5 - (51 - ICMS diferido)'
           when 6 then '6 - (60 - ICMS cobrado anteriormente por substit. tribut.)'
           when 7 then '7 - (90 - ICMS outros)'
           when 8 then '8 - (90 - ICMS devido à UF de origem da prestação quando diferente da uf do emitente)'
           else '(indefinido)'
         end
       ) AS cte_codigo_sit_tributaria_nome,(
         case
           t1.cte_tipo_doc_anexo
           when 1 then '1 - Nota Fiscal'
           when 2 then '2 - NF-e'
           when 3 then '3 - Declaração/Outros'
           else '(indefinido)'
         end
       ) AS cte_tipo_doc_anexo_nome,
       t18.cte_ev_data_hora AS cte_data_hora_autorizacao,
       t2.user_nome AS cte_cadastrado_por_nome,
       t3.user_nome AS cte_alterado_por_nome,
       t20.recebedor_nome AS recebedor_nome,
       t20.recebedor_doc AS recebedor_doc,
       t20.ultima_entrega_em AS cte_data_entrega_ultima,
       round(
         (
           (t20.total_volumes / t1.cte_qtde_volumes) * 100
         ),
         2
       ) AS cte_perc_entregue,
       t21.lista_documentos AS lista_documentos,
       t21.lista_documentos_numeros AS lista_documentos_numeros
FROM (
    (
      (
        (
          (
            (
              (
                (
                  (
                    (
                      (
                        (
                          (
                            (
                              (
                                (
                                  (
                                    (
                                      (
                                        (
                                          (
                                            (
                                              (
                                                (
                                                  (
                                                    (
                                                      (
                                                        (
                                                          (
                                                            ctes t1
                                                            LEFT JOIN usuarios t2 ON((t2.user_id = t1.cte_cadastrado_por))
                                                          )
                                                          LEFT JOIN usuarios t3 ON((t3.user_id = t1.cte_alterado_por))
                                                        )
                                                        LEFT JOIN ctes_faturados t4 ON((t4.cte_id = t1.cte_id))
                                                      )
                                                      LEFT JOIN clientes t5 ON((t5.clie_id = t1.clie_remetente_id))
                                                    )
                                                    LEFT JOIN clientes t6 ON((t6.clie_id = t1.clie_coleta_id))
                                                  )
                                                  LEFT JOIN clientes t7 ON((t7.clie_id = t1.clie_expedidor_id))
                                                )
                                                LEFT JOIN clientes t8 ON((t8.clie_id = t1.clie_recebedor_id))
                                              )
                                              LEFT JOIN clientes t9 ON((t9.clie_id = t1.clie_destinatario_id))
                                            )
                                            LEFT JOIN clientes t10 ON((t10.clie_id = t1.clie_entrega_id))
                                          )
                                          LEFT JOIN clientes t11 ON((t11.clie_id = t1.clie_tomador_id))
                                        )
                                        LEFT JOIN clientes t22 ON((t22.clie_id = t1.clie_representante_id))
                                      )
                                      LEFT JOIN cidades cid5 ON((cid5.cid_id = t5.cid_id))
                                    )
                                    LEFT JOIN cidades cid6 ON((cid6.cid_id = t6.cid_id))
                                  )
                                  LEFT JOIN cidades cid7 ON((cid7.cid_id = t7.cid_id))
                                )
                                LEFT JOIN cidades cid8 ON((cid8.cid_id = t8.cid_id))
                              )
                              LEFT JOIN cidades cid9 ON((cid9.cid_id = t9.cid_id))
                            )
                            LEFT JOIN cidades cid10 ON((cid10.cid_id = t10.cid_id))
                          )
                          LEFT JOIN cidades cid11 ON((cid11.cid_id = t11.cid_id))
                        )
                        LEFT JOIN cidades t12 ON((t12.cid_id = t1.cid_id_origem))
                      )
                      LEFT JOIN cidades t13 ON((t13.cid_id = t1.cid_id_destino))
                    )
                    LEFT JOIN cidades t14 ON((t14.cid_id = t1.cid_id_passagem))
                  )
                  LEFT JOIN cidades t19 ON(
                    (t19.cid_id = t1.cid_id_etiqueta_entrega)
                  )
                )
                LEFT JOIN produtos t15 ON((t15.prod_id = t1.prod_id))
              )
              LEFT JOIN grupo_tarifas t16 ON((t16.gt_id_codigo = t15.gt_id_codigo))
            )
            LEFT JOIN iata_imp_codes t17 ON((t17.iic_id = t15.iic_id))
          )
          LEFT JOIN ctes_eventos t18 ON(
            (
              (t18.cte_id = t1.cte_id)
              and (t18.cte_ev_evento = '100')
            )
          )
        )
        LEFT JOIN view_sum_entrega_ctes_ocorrencias t20 ON((t20.cte_id = t1.cte_id))
      )
      LEFT JOIN view_ctes_documentos_group t21 ON((t21.cte_id = t1.cte_id))
    )
    JOIN empresas t23 ON((t23.emp_id = t1.emp_id))
  )
GROUP BY
  t1.cte_id