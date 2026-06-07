# Política de Privacidade — toDoin

**Última atualização:** 7 de junho de 2026  
**Versão:** 1.0

---

## 1. Quem somos

O **toDoin** (“App”, “nós”) é um aplicativo de produtividade e foco gentil, pensado para ajudar pessoas — especialmente com TDAH — a iniciar tarefas, manter o foco e reduzir a procrastinação.

**Controlador dos dados:** Cubit App  
**E-mail de contato:** suporte@todoin.app  
**Site:** https://todoin.app

Esta Política de Privacidade descreve como tratamos informações quando você utiliza o toDoin em dispositivos iOS e Android.

---

## 2. Visão geral

O toDoin foi projetado com abordagem **local-first**: a maior parte dos seus dados (tarefas, progresso, configurações) fica **armazenada no seu dispositivo**. Não exigimos criação de conta para usar o App.

Alguns serviços opcionais ou necessários para funcionalidades específicas podem enviar dados limitados a terceiros, conforme descrito nesta política. **Não vendemos seus dados pessoais.**

---

## 3. Dados que coletamos e como usamos

### 3.1 Dados armazenados localmente no seu dispositivo

Por padrão, o App armazena no dispositivo:

| Dado | Finalidade |
|------|------------|
| Tarefas e subtarefas (títulos, status, tipo) | Funcionamento principal do App |
| Pontos de experiência (XP) e estatísticas (sequências, resumo semanal) | Gamificação e motivação |
| Preferências (som, vibração, modo “dia difícil”) | Personalização da experiência |
| Configurações de lembretes (horário, ativo/inativo) | Envio de notificações locais (recurso Pro) |
| Status do plano Pro (local) | Liberar recursos premium |
| Identificador de dispositivo para sync (UUID gerado localmente) | Sincronização em nuvem (recurso Pro, opcional) |

Esses dados permanecem no seu aparelho até que você os exclua, desinstale o App ou restaure/importe um backup.

### 3.2 Dados que **não** coletamos por padrão

- Nome, e-mail ou telefone (não há cadastro obrigatório)
- Localização geográfica
- Contatos, fotos ou arquivos do dispositivo
- Conteúdo de mensagens ou redes sociais

### 3.3 Analytics de uso (PostHog)

Quando configurado em produção, utilizamos o **PostHog** para entender como o App é usado e melhorar a experiência.

**O que pode ser registrado:**
- Eventos de uso anonimizados (ex.: app aberto, tela visitada, tarefa criada/concluída, timer iniciado, paywall exibido)
- Plataforma (iOS/Android), versão do build e propriedades técnicas do App
- Após uma compra Pro: status `is_pro` e tipo de plano (`monthly`, `yearly`, `lifetime`)

**O que **não** enviamos ao PostHog:**
- Títulos ou conteúdo das suas tarefas
- Texto de subtarefas
- Conteúdo de backups

Perfis de usuário no PostHog são criados apenas após identificação vinculada à compra Pro (`identifiedOnly`).

**Base legal (LGPD):** legítimo interesse e melhoria do serviço.

### 3.4 Relatórios de erro (Sentry)

Quando configurado, utilizamos o **Sentry** para receber relatórios de falhas e erros técnicos, incluindo stack traces e informações do dispositivo necessárias para diagnóstico.

Esses dados são usados exclusivamente para corrigir bugs e aumentar a estabilidade do App. Não incluímos intencionalmente conteúdo das suas tarefas nesses relatórios.

**Base legal (LGPD):** legítimo interesse.

### 3.5 Compras e assinaturas (RevenueCat, Apple, Google)

Assinaturas e compras no App são processadas pelas lojas **Apple App Store** e **Google Play**, com gestão via **RevenueCat**.

**Dados tratados:**
- Identificadores de transação e assinatura
- Status do plano Pro (ativo, tipo, renovação)
- Informações exigidas pelas lojas para faturamento (gerenciadas diretamente pela Apple/Google)

Nós **não** armazenamos números de cartão de crédito. Pagamentos são processados integralmente pelas lojas.

Consulte também:
- [Política de Privacidade da Apple](https://www.apple.com/legal/privacy/)
- [Política de Privacidade do Google](https://policies.google.com/privacy)
- [Política de Privacidade da RevenueCat](https://www.revenuecat.com/privacy)

**Base legal (LGPD):** execução de contrato.

### 3.6 Sincronização em nuvem — Pro (Supabase)

Usuários Pro podem ativar **Sync automático**, que envia um backup JSON dos dados locais para infraestrutura **Supabase**, identificado por um `device_id` gerado no dispositivo.

**Dados sincronizados (quando você ativa o recurso):**
- Tarefas, subtarefas, XP, estatísticas, configurações e lembretes (mesmo conteúdo do backup local)

**Importante:**
- O sync é **opcional** e requer plano Pro
- Os dados ficam associados ao identificador do dispositivo, não a uma conta de e-mail
- Você pode desativar o sync a qualquer momento nas Configurações

**Base legal (LGPD):** execução de contrato e consentimento (ativação explícita).

### 3.7 Subtarefas inteligentes — Pro (OpenAI)

Usuários Pro podem usar a geração de subtarefas por IA. Nesse caso, o **título da tarefa** e o **tipo da tarefa** são enviados à API da **OpenAI** para sugerir micro-passos.

- O envio ocorre **somente quando você solicita** a geração
- Se a API falhar, o App usa sugestões locais (heurísticas) como alternativa
- Não enviamos todo o histórico de tarefas

Consulte a [Política de Privacidade da OpenAI](https://openai.com/policies/privacy-policy).

**Base legal (LGPD):** execução de contrato.

### 3.8 Backup manual (exportar/importar)

Você pode exportar e importar um arquivo JSON com seus dados. Esse arquivo fica **sob seu controle** — no dispositivo, em serviço de nuvem pessoal ou onde você escolher salvá-lo. Nós não acessamos backups exportados manualmente.

---

## 4. Permissões do dispositivo

O App pode solicitar as seguintes permissões:

| Permissão | Motivo |
|-----------|--------|
| Notificações | Lembretes diários, conclusão do timer de foco |
| Execução em segundo plano (Android) | Manter o timer ativo com serviço em primeiro plano |
| Live Activities (iOS) | Exibir timer na tela de bloqueio/Dynamic Island |
| Widget na tela inicial (Pro) | Mostrar tarefas pendentes no widget |

Você pode revogar permissões nas configurações do sistema a qualquer momento. Algumas funcionalidades podem deixar de funcionar sem a permissão correspondente.

---

## 5. Compartilhamento com terceiros

Compartilhamos dados apenas com os prestadores listados nesta política, estritamente para as finalidades descritas:

| Prestador | Finalidade |
|-----------|------------|
| PostHog | Analytics de uso |
| Sentry | Relatórios de erro |
| RevenueCat | Gestão de assinaturas |
| Apple / Google | Processamento de pagamentos |
| Supabase | Sync em nuvem (Pro, opcional) |
| OpenAI | Geração de subtarefas (Pro, sob demanda) |

**Não vendemos, alugamos ou comercializamos seus dados pessoais.**

Podemos divulgar informações se exigido por lei, ordem judicial ou autoridade competente.

---

## 6. Retenção de dados

| Tipo de dado | Retenção |
|--------------|----------|
| Dados locais no dispositivo | Até você excluir, restaurar backup ou desinstalar o App |
| Sync em nuvem (Supabase) | Enquanto o sync estiver ativo; remova desativando o sync ou entre em contato |
| Analytics (PostHog) | Conforme política e configuração do PostHog |
| Crashes (Sentry) | Conforme política e configuração do Sentry |
| Dados de compra (RevenueCat/lojas) | Conforme políticas das respectivas plataformas e obrigações legais/fiscais |

---

## 7. Segurança

Adotamos medidas técnicas e organizacionais razoáveis para proteger seus dados, incluindo:

- Armazenamento local no dispositivo
- Comunicação criptografada (HTTPS) com serviços externos
- Minimização de dados enviados a terceiros (ex.: analytics sem títulos de tarefas)

Nenhum sistema é 100% seguro. Recomendamos manter seu dispositivo atualizado e protegido.

---

## 8. Seus direitos (LGPD)

Se você estiver no Brasil, nos termos da **Lei Geral de Proteção de Dados (Lei nº 13.709/2018)**, você pode solicitar:

- Confirmação do tratamento de dados
- Acesso aos dados que tratamos sobre você
- Correção de dados incompletos ou desatualizados
- Anonimização, bloqueio ou eliminação de dados desnecessários
- Portabilidade (quando aplicável)
- Informação sobre compartilhamento com terceiros
- Revogação de consentimento (quando o tratamento se basear em consentimento)

**Como exercer seus direitos:** envie e-mail para **suporte@todoin.app** com o assunto “Privacidade — LGPD”. Responderemos em prazo razoável.

Para dados tratados diretamente pela Apple ou Google (pagamentos), parte das solicitações deve ser feita também junto a essas plataformas.

---

## 9. Crianças e adolescentes

O toDoin não se destina a menores de 13 anos. Não coletamos intencionalmente dados de crianças. Se você acredita que um menor nos forneceu dados, entre em contato para que possamos tomar as medidas cabíveis.

---

## 10. Transferência internacional de dados

Alguns prestadores (PostHog, Sentry, Supabase, OpenAI, RevenueCat) podem processar dados em servidores fora do Brasil, inclusive nos Estados Unidos. Nesses casos, buscamos parceiros que ofereçam salvaguardas adequadas conforme a LGPD.

---

## 11. Alterações desta política

Podemos atualizar esta Política de Privacidade periodicamente. A data da “Última atualização” no topo será revisada. Alterações relevantes podem ser comunicadas no App ou em nosso site.

O uso continuado do App após a publicação de alterações constitui ciência da nova versão, salvo quando a lei exigir consentimento adicional.

---

## 12. Contato

Dúvidas sobre privacidade ou tratamento de dados:

**E-mail:** suporte@todoin.app  
**Site:** https://todoin.app

---

*Este documento descreve as práticas de privacidade do toDoin com base nas funcionalidades atuais do aplicativo. Recomenda-se revisão por assessoria jurídica antes da publicação oficial.*
