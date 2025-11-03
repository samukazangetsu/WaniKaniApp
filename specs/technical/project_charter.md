# Charter do Projeto: WaniKani App

> **Versão:** 1.0.0  
> **Data:** 11 de Outubro de 2025  
> **Status:** Ativo - Desenvolvimento Inicial

---

## 📜 Declaração de Visão

### Propósito do Projeto

O **WaniKani App** é um cliente mobile alternativo para a plataforma WaniKani, projetado para fornecer uma experiência otimizada de acompanhamento de progresso no aprendizado de japonês (kanji, vocabulário e radicais) através do método de repetição espaçada (SRS - Spaced Repetition System).

### Por Que Este Projeto Existe?

**Problema Identificado:**
- Usuários do WaniKani precisam de acesso rápido e offline às suas estatísticas de progresso
- A necessidade de visualizar dashboard de reviews e estatísticas mesmo sem conexão constante
- Experiência mobile nativa superior ao web app

**Solução Proposta:**
- Cliente mobile nativo (Flutter) com suporte offline-first
- Cache inteligente de dados (24h) conforme recomendações da API WaniKani
- Interface otimizada para mobile com design japonês tradicional
- Sincronização automática quando online

### Valor Entregue

**Para o Usuário:**
- ✅ Acesso rápido ao progresso de estudos
- ✅ Visualização offline de estatísticas e reviews
- ✅ Interface mobile nativa e responsiva
- ✅ Design inspirado na cultura japonesa (estético e funcional)
- ✅ Performance superior (dados cacheados localmente)

**Para o Desenvolvedor:**
- ✅ Projeto portfolio demonstrando Clean Architecture
- ✅ Experiência com offline-first e sincronização de dados
- ✅ Prática com APIs REST e cache strategies
- ✅ Aplicação real do padrão BLoC/Cubit
- ✅ Integração com ferramentas de IA no desenvolvimento

---

## 🎯 Critérios de Sucesso

### Objetivos Mensuráveis (MVP - v1.0)

#### 1. Funcionalidades Core
- [ ] **Dashboard de Reviews:** Exibir assignments ativos, próximos reviews e progresso atual
- [ ] **Estatísticas de Progresso:** Visualizar level progressions e review statistics com gráficos
- [ ] **Autenticação:** Login via API key do WaniKani com armazenamento seguro
- [ ] **Sincronização Offline:** Cache de 24h para assignments, 1h para review statistics
- [ ] **Performance:** App inicia em < 2s, tela de dashboard carrega em < 1s (com cache)

#### 2. Qualidade Técnica
- [ ] **Cobertura de Testes:** > 80% de cobertura em todas as camadas (data, domain, presentation)
- [ ] **Zero Linting Errors:** 100% de conformidade com as 80+ regras configuradas
- [ ] **Type Safety:** Uso completo de tipos explícitos e null safety
- [ ] **Error Handling:** Todos os casos de erro tratados com Either monad (dartz)
- [ ] **Code Review:** Toda feature passa por auto-review (IA + manual)

#### 3. User Experience
- [ ] **UI Japonesa:** Tema customizado com paleta japonesa tradicional e fonte Noto Sans JP
- [ ] **Responsividade:** Suporte a múltiplos tamanhos de tela (phones, tablets)
- [ ] **Offline-first:** Funciona completamente offline após primeira sincronização
- [ ] **Feedback Visual:** Loading states, error states, empty states bem definidos

#### 4. Deploy e Distribuição (v2.0 - Futuro)
- [ ] Publicação na Google Play Store
- [ ] Publicação na Apple App Store
- [ ] CI/CD pipeline configurado (opcional)

### Métricas de Sucesso

**Métricas de Desenvolvimento:**
- Lines of code: ~10-15k (estimativa MVP)
- Features implementadas: 3 principais (dashboard, stats, auth)
- Bugs críticos: 0 antes de release
- Technical debt: mantido abaixo de 10% do código total

**Métricas de Qualidade:**
- Code coverage: > 80%
- Linting compliance: 100%
- Build success rate: > 95%
- Hot reload funcional: 100% das alterações

---

## 🔲 Limites do Escopo

### ✅ Escopo DENTRO (In-Scope)

#### Features Incluídas - MVP v1.0
1. **Autenticação e Configuração**
   - Login via WaniKani API key
   - Armazenamento seguro de credenciais
   - Logout e limpeza de cache

2. **Dashboard de Reviews**
   - Listagem de assignments ativos
   - Filtros por tipo (radical, kanji, vocabulary)
   - Indicadores de SRS stage
   - Contador de reviews disponíveis
   - Próximos reviews (timeline)

3. **Estatísticas de Progresso**
   - Level progression atual e histórico
   - Review statistics (accuracy, streaks)
   - Gráficos de progresso temporal
   - Total de items por categoria

4. **Sincronização Offline**
   - Cache automático de dados da API
   - Sincronização inteligente (background)
   - Indicador de status de sincronização
   - TTL configurável por endpoint

5. **Configurações**
   - Gerenciamento de API key
   - Controle de cache (limpar, forçar sync)
   - Preferências de tema (light/dark)
   - Sobre e créditos

#### Tecnologias e Padrões
- Clean Architecture com separação clara de camadas
- BLoC/Cubit para state management
- Drift (SQLite) para persistência local
- go_router para navegação
- GetIt para dependency injection
- Either monad para error handling
- Strict linting (80+ rules)

### ❌ Escopo FORA (Out-of-Scope)

#### Features Explicitamente Excluídas
1. **Funcionalidades de Review/Lessons Interativas**
   - ❌ Realizar reviews no app (apenas visualização)
   - ❌ Fazer lessons no app
   - ❌ Quiz de kanji/vocabulary interativo
   - **Razão:** Escopo muito grande para MVP, WaniKani web já oferece

2. **Features Community/Social**
   - ❌ Fóruns integrados
   - ❌ Chat entre usuários
   - ❌ Compartilhamento em redes sociais
   - ❌ Leaderboards/rankings
   - **Razão:** Foco é acompanhamento individual, não social

3. **Criação/Edição de Conteúdo**
   - ❌ Adicionar custom kanji/vocabulary
   - ❌ Editar mnemonics
   - ❌ Criar decks customizados
   - **Razão:** App apenas consome API WaniKani, não cria conteúdo

4. **Suporte a Outras Plataformas de Estudo**
   - ❌ Integração com Anki
   - ❌ Suporte a Bunpro, KameSame, etc.
   - ❌ Import/export para outros sistemas SRS
   - **Razão:** Foco exclusivo em WaniKani API

5. **Funcionalidades Avançadas (Futuro - v2.0+)**
   - ❌ Notificações push para reviews (v1.0)
   - ❌ Widgets de home screen (v1.0)
   - ❌ Modo completamente offline (sem API) (nunca)
   - ❌ Sincronização multi-device (v1.0)

### 🔄 Escopo Flexível (Pode Mudar)

Features que podem ser adicionadas dependendo do progresso:

- 🤔 **Gráficos avançados:** Heatmaps, projeções de progresso
- 🤔 **Notificações locais:** Lembretes de reviews baseados em cache
- 🤔 **Temas customizáveis:** Múltiplas paletas de cores japonesas
- 🤔 **Export de dados:** Backup local em JSON/CSV

---

## 👥 Stakeholders Principais

### Desenvolvedor/Proprietário
- **Nome:** Samuel (samukazangetsu)
- **Papel:** Desenvolvedor solo, arquiteto, product owner
- **Responsabilidades:**
  - Desenvolvimento completo do app
  - Decisões arquiteturais
  - Roadmap de features
  - Quality assurance
  - Deploy e manutenção

### Usuários Alvo
- **Perfil:** Estudantes de japonês usando WaniKani
- **Nível:** Iniciante a avançado (níveis 1-60 WaniKani)
- **Necessidades:**
  - Acesso rápido a estatísticas
  - Visualização offline de progresso
  - Interface mobile otimizada
  - Performance e confiabilidade

### WaniKani (Tofugu LLC)
- **Papel:** Fornecedor da API
- **Relação:** Este é um cliente não-oficial
- **Restrições:**
  - Respeitar rate limits da API
  - Seguir guidelines de cache (24h para alguns endpoints)
  - Não violar termos de serviço
  - Dar créditos apropriados

### Ferramentas de IA (Desenvolvimento)
- **GitHub Copilot, Claude, Cursor:** Assistentes de desenvolvimento
- **Uso:** Geração de código, refactoring, documentação, troubleshooting
- **Dependência:** Documentação técnica clara e atualizada (este projeto)

---

## 🚧 Restrições Técnicas

### Restrições Não-Negociáveis

#### 1. Arquitetura e Código
- ✅ **Clean Architecture obrigatória:** Separação data/domain/presentation
- ✅ **Linting rigoroso:** 80+ regras ativas, zero warnings permitidos
- ✅ **Type safety total:** Tipos explícitos, null safety, no dynamic
- ✅ **Testes obrigatórios:** Toda feature deve ter testes unitários
- ✅ **Error handling funcional:** Either monad (dartz) para todos os casos

#### 2. Performance e UX
- ✅ **Offline-first:** App deve funcionar sem internet após primeira sync
- ✅ **Cache respeitando TTL:** 24h para assignments/level_progression, 1h para review_statistics
- ✅ **Startup rápido:** < 2s em dispositivos médios
- ✅ **UI responsiva:** Suporte a múltiplos tamanhos de tela

#### 3. Integração com API WaniKani
- ✅ **Autenticação via Bearer Token:** API key do usuário
- ✅ **Respeitar rate limits:** Não sobrecarregar API
- ✅ **Cache inteligente:** Evitar chamadas desnecessárias
- ✅ **Error handling robusto:** Tratar timeout, network errors, API errors

#### 4. Qualidade e Manutenibilidade
- ✅ **Documentação completa:** Código autodocumentado + docs técnicas
- ✅ **Git workflow limpo:** Commits semânticos, branches organizados
- ✅ **Code review (auto):** Revisão via IA antes de commits
- ✅ **Versionamento semântico:** SemVer para releases

### Restrições de Infraestrutura

#### Desenvolvimento
- **Ambiente:** Windows (desenvolvimento local)
- **IDE:** VS Code com extensões Flutter/Dart
- **Build:** Gradle (Android), Xcode (iOS futuro)
- **Testing:** Flutter test framework nativo

#### Deploy (Futuro)
- **Android:** Play Store (minSdk TBD, targetSdk latest)
- **iOS:** App Store (iOS 12+ target)
- **Distribuição:** Lojas oficiais apenas (sem sideload)

### Restrições Temporais

#### Prazos (Estimativas)
- **MVP v1.0:** 2-3 meses de desenvolvimento
- **Beta testing:** 1 mês
- **Launch v1.0:** 4 meses totais
- **Manutenção:** Contínua (2+ anos planejado)

#### Ritmo de Desenvolvimento
- **Solo developer:** 10-15h/semana disponíveis
- **Features/semana:** 1-2 features pequenas
- **Sprints:** Ciclos de 2 semanas

---

## 🔐 Considerações de Segurança

### Armazenamento de Credenciais
- ✅ API key armazenada com flutter_secure_storage
- ✅ Nunca logar API keys em logs
- ✅ Limpeza segura ao fazer logout

### Privacidade de Dados
- ✅ Dados armazenados apenas localmente (SQLite)
- ✅ Nenhum tracking de usuário
- ✅ Nenhuma coleta de analytics (MVP)
- ✅ Dados do usuário nunca enviados para servidores terceiros

### Comunicação com API
- ✅ HTTPS apenas (TLS 1.2+)
- ✅ Certificate pinning (considerar v2.0)
- ✅ Timeout adequados para evitar travamentos

---

## 📋 Dependências Externas

### Dependências Críticas
1. **WaniKani API v2** (https://api.wanikani.com/v2)
   - Disponibilidade: 99.9% SLA (estimado)
   - Versionamento: v2 (stable)
   - Documentação: https://docs.api.wanikani.com
   - **Risco:** Mudanças na API podem quebrar o app

2. **Packages Flutter/Dart:**
   - flutter_bloc, dartz, drift, dio, go_router, get_it
   - **Risco:** Breaking changes em major versions

### Mitigação de Riscos
- ✅ Cache local reduz dependência de API online
- ✅ Versionamento de packages locked (pubspec.lock)
- ✅ Testes de integração detectam breaking changes
- ✅ Monitoramento de deprecations

---

## 📊 Roadmap de Alto Nível

### Fase 1: Setup e Fundação (Semanas 1-2) ✅ EM PROGRESSO
- [x] Setup do projeto Flutter
- [x] Configuração de linting
- [x] Estrutura de Clean Architecture
- [x] Documentação técnica inicial
- [x] Setup de DI (GetIt)
- [x] Configuração de rotas (go_router)

### Fase 2: Integração API (Semanas 3-4)
- [x] Datasource para WaniKani API (Dio + pop_network)
- [x] Models e Entities (Assignment, LevelProgression, ReviewStatistic)
- [ ] Repositories com cache
- [x] Use cases básicos
- [ ] Testes unitários (data layer)
- [ ] Requests condicionais (data layer)

### Fase 3: Cache Offline (Semanas 5-6)
- [ ] Setup Drift (SQLite)
- [ ] DAOs e tabelas
- [ ] Estratégia de TTL
- [ ] Sincronização inteligente
- [ ] Testes de persistência

### Fase 4: UI e State Management (Semanas 7-9)
- [x] Tema japonês customizado
- [x] Dashboard de reviews (UI + BLoC)
- [ ] Tela de estatísticas (UI + BLoC)
- [x] Tela de autenticação
- [x] Loading/error states

### Fase 5: Polimento e Testes (Semanas 10-11)
- [ ] Refactoring e otimizações
- [ ] Correção de bugs
- [ ] Performance profiling
- [ ] Preparação para release

### Fase 6: Beta e Launch (Semana 12+)
- [ ] Beta testing (interno)
- [ ] Ajustes finais
- [ ] Documentação de usuário
- [ ] Preparação para lojas (futuro)

---

## ✅ Aprovações e Sign-off

### Aprovação Inicial
- **Data:** 11/10/2025
- **Aprovado por:** Samuel (samukazangetsu)
- **Status:** Charter aprovado - desenvolvimento pode prosseguir

### Revisões Futuras
Este charter será revisado:
- ✅ Ao final de cada fase do roadmap
- ✅ Quando mudanças de escopo forem propostas
- ✅ Antes de releases major (v2.0, v3.0, etc.)

---

## 📝 Histórico de Mudanças

| Data | Versão | Mudanças | Aprovado Por |
|------|--------|----------|--------------|
| 11/10/2025 | 1.0.0 | Charter inicial criado | Samuel |

---

> **💡 Nota:** Este charter é um documento vivo e pode ser atualizado conforme o projeto evolui. Todas as mudanças devem ser documentadas na seção de histórico.
