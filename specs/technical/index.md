# Documentação Técnica - WaniKani App

> **Última atualização:** 11 de Outubro de 2025  
> **Versão:** 1.0.0  
> **Status:** Desenvolvimento Inicial

---

## � Resumo do Projeto

**Features Implementadas:** 2/7 (29%)
- ✅ **Login** - Autenticação WaniKani (API token + secure storage)
- ✅ **Home** - Dashboard com métricas de estudo (4 use cases funcionais)
- ⏳ Reviews, Lessons, Subjects, Statistics, Settings (planejadas)

**Documentação Completa:** 8/8 (100%)
- ✅ Todos os documentos técnicos criados/atualizados
- ✅ CLAUDE.meta.md com padrão DioException mandatório
- ✅ BUSINESS_LOGIC.md com sistema SRS completo
- ✅ TROUBLESHOOTING.md com problemas reais e soluções

**Prioridades Técnicas:**
1. **HIGH:** AuthInterceptor global para 401 errors
2. **HIGH:** Standardize DioException handling em HomeRepository
3. **MEDIUM:** Fix SplashCubit emit after close (linha 48)
4. **MEDIUM:** Implement Drift offline cache (TTL 24h)

---

## �📋 Perfil de Contexto do Projeto

### Informações Básicas do Projeto

**Nome do Projeto:** WaniKani App

**Tipo do Projeto:** 
- ✅ Aplicação Mobile (Flutter)
- 🎯 Cliente alternativo para API WaniKani
- 🎌 Foco em acompanhamento de progresso de aprendizado de japonês

**Stack Tecnológico:**
- **Linguagem Principal:** Dart ^3.8.0
- **Framework:** Flutter (multiplataforma - Android, iOS)
- **Arquitetura:** Clean Architecture + BLoC (Cubit)
- **Banco de Dados:** Drift (SQLite) com cache offline-first
- **Networking:** Dio + pop_network com interceptors
- **Navegação:** go_router (navegação declarativa)
- **Dependency Injection:** GetIt (service locator)
- **Functional Programming:** Dartz (Either monad para error handling)
- **UI/Theme:** Material Design customizado com tema japonês (Noto Sans JP)

**Dependências Principais:**
```yaml
flutter_bloc: ^9.1.1        # State management
dartz: ^0.10.1              # Functional programming
pop_network: ^1.2.1         # HTTP client com interceptors
dio: ^5.4.0                 # Cliente HTTP robusto
drift: ^2.14.0              # SQLite type-safe
go_router: ^13.0.0          # Navegação
get_it: ^7.6.0              # Dependency injection
google_fonts: ^6.1.0        # Typography (Noto Sans JP)
equatable: ^2.0.5           # Value equality
```

**Estrutura da Equipe:**
- **Tamanho da Equipe:** 1 desenvolvedor (solo)
- **Nível de Experiência:** Sênior
- **Uso de Ferramentas IA:**
  - ✅ GitHub Copilot
  - ✅ Claude para desenvolvimento e arquitetura
  - ✅ Cursor/Windsurf

**Restrições de Desenvolvimento:**
- ✅ Foco em prototipagem rápida/MVP
- ✅ Manutenção de longo prazo (2+ anos planejado)
- ✅ Strict code quality (80+ linting rules)
- ✅ Offline-first architecture (cache 24h)
- ✅ Publicação futura em Play Store e App Store

---

## 🏗️ Arquitetura de Contexto Multi-Arquivo

Esta documentação segue uma abordagem modular com arquivos separados por camada de contexto.

### Camada 1: Contexto Central do Projeto

Fundamentos e decisões arquiteturais que guiam todo o desenvolvimento.

- 📜 [Charter do Projeto](project_charter.md) - Visão, escopo e objetivos
- 🏛️ [Registros de Decisões Arquiteturais (ADRs)](adr/)
  - [ADR-001: Clean Architecture por Features](adr/001-clean-architecture.md)
  - [ADR-002: BLoC/Cubit para State Management](adr/002-bloc-state-management.md)
  - [ADR-003: Drift para Cache Offline-First](adr/003-offline-first-drift.md)
  - [ADR-004: go_router para Navegação](adr/004-go-router-navigation.md)
  - [ADR-005: Design System com Tema Japonês](adr/005-japanese-theme-design.md)

### Camada 2: Arquivos de Contexto Otimizados para IA

Documentação específica para desenvolvimento assistido por IA.

- 🤖 [Guia de Desenvolvimento com IA](CLAUDE.meta.md) - Padrões de código, testes e pegadinhas ✅
- 🗺️ [Guia de Navegação da Base de Código](CODEBASE_GUIDE.md) - Estrutura e organização ✅

### Camada 3: Contexto Específico do Domínio

Conhecimento de domínio e integrações externas.

- 🌐 [Especificações da API WaniKani v2](API_SPECIFICATION.md) - Endpoints, autenticação, erro handling e cache ✅
- 📊 [Lógica de Negócio](BUSINESS_LOGIC.md) - Conceitos de SRS e progressão ✅
- 🎨 [Design System](../design/DESIGN_SYSTEM.md) - Cores, tipografia, componentes e tema dark ✅

### Camada 4: Contexto do Fluxo de Desenvolvimento

Processos e workflows para contribuição e manutenção.

- 🔧 [Guia de Fluxo de Desenvolvimento](CONTRIBUTING.md) - Setup, testes e convenções ✅
- 🐛 [Guia de Solução de Problemas](TROUBLESHOOTING.md) - Debug e problemas comuns ✅
- 🎯 [Desafios Arquiteturais](ARCHITECTURE_CHALLENGES.md) - Melhorias futuras e tech debt ✅

---

## 📊 Estratégia de Manutenção de Contexto

### Propriedade e Responsabilidade

| Documento | Proprietário | Frequência de Atualização |
|-----------|--------------|---------------------------|
| Project Charter | Arquiteto/Dev Lead | Mudanças de escopo major |
| ADRs | Arquiteto/Dev Lead | Nova decisão arquitetural |
| CLAUDE.meta.md | Desenvolvedores | Evolução de padrões |
| CODEBASE_GUIDE.md | Desenvolvedores | Mudanças estruturais |
| API_SPECIFICATION.md | Backend/Integração | Mudanças de API |
| DESIGN_SYSTEM.md | UI/UX Designer/Dev | Mudanças visuais e de componentes |
| CONTRIBUTING.md | Dev Lead | Mudanças de processo |
| TROUBLESHOOTING.md | Time todo | Novos problemas identificados |

### Gatilhos de Atualização

Atualizar documentação quando:
- ✅ Novas features são adicionadas
- ✅ Decisões arquiteturais são tomadas
- ✅ Stack tecnológica muda
- ✅ Padrões de código evoluem
- ✅ Problemas recorrentes são identificados
- ✅ API WaniKani é atualizada

### Processo de Garantia de Qualidade

**Checklist de Revisão da Documentação:**
- [ ] Informação está atual e precisa
- [ ] Exemplos de código funcionam e foram testados
- [ ] Linguagem clara e sem ambiguidade
- [ ] IA consegue entender e usar a informação
- [ ] Desenvolvedores acham útil
- [ ] Links e referências são válidos

---

## 🤖 Diretrizes de Integração com IA

### Estrutura de Arquivos para Consumo pela IA

```
specs/
├── technical/                      # Documentação técnica principal
│   ├── index.md                   # Este arquivo - índice navegável
│   ├── project_charter.md         # Visão e escopo do projeto
│   ├── adr/                       # Decisões arquiteturais
│   │   ├── 001-clean-architecture.md
│   │   ├── 002-bloc-state-management.md
│   │   ├── 003-offline-first-drift.md
│   │   ├── 004-go-router-navigation.md
│   │   └── 005-japanese-theme-design.md
│   ├── CLAUDE.meta.md             # Guia de desenvolvimento IA
│   ├── CODEBASE_GUIDE.md          # Navegação de código
│   ├── API_SPECIFICATION.md       # Documentação API externa
│   ├── BUSINESS_LOGIC.md          # Lógica de domínio (TO DO)
│   ├── CONTRIBUTING.md            # Workflow de desenvolvimento
│   ├── TROUBLESHOOTING.md         # Solução de problemas
│   └── ARCHITECTURE_CHALLENGES.md # Desafios e melhorias
└── design/                        # Documentação de design
    └── DESIGN_SYSTEM.md           # Design system completo ✅
```

### Configuração de Ferramentas IA

**Para GitHub Copilot:**
- Contexto carregado automaticamente dos arquivos .md no repositório
- Padrões de código definidos em `CLAUDE.meta.md`
- Linting rules em `analysis_options.yaml`

**Para Claude/ChatGPT:**
- Incluir `index.md` para visão geral do projeto
- Referenciar ADRs específicos para contexto de decisões
- Usar `CODEBASE_GUIDE.md` para navegação

**Para Cursor/Windsurf:**
- Configurar `.cursorrules` referenciando `CLAUDE.meta.md`
- Manter workspace context atualizado com estrutura de pastas

---

## 📈 Métricas de Sucesso

### Indicadores Quantitativos

**Documentação:**
- ✅ 100% dos documentos core completos (8/8)
- ✅ 5 ADRs documentados (decisões arquiteturais)
- ✅ DioException pattern documentado em 2 arquivos (CLAUDE.meta.md, API_SPECIFICATION.md)
- ✅ BUSINESS_LOGIC.md criado (~400 linhas, sistema SRS completo)

**Eficiência de Desenvolvimento:**
- ⏱️ Time to first contribution: < 2 horas (objetivo alcançado)
- 🔄 Code review cycle time: Solo dev - N/A
- 🐛 Bug resolution time: 3 issues documentados em TROUBLESHOOTING.md
- 🚀 Feature development velocity: 2 features completas (login + home)

**Cobertura de Código:**
- 🎯 Test coverage target: > 80%
- ⏳ Test coverage atual: Em implementação
- ✅ Core error handling testado (IError, ApiErrorEntity, InternalErrorEntity)
- ✅ Mixin DecodeModelMixin testado

### Indicadores Qualitativos

**Satisfação do Desenvolvedor:**
- ✅ IA fornece sugestões relevantes e contextuais
- ✅ Menos tempo explicando contexto do projeto
- ✅ Redução de frustração com limitações de ferramentas IA
- ✅ Documentação permanece atual sem esforço heroico

**Qualidade do Contexto:**
- ✅ Documentação é autoexplicativa
- ✅ Exemplos de código funcionam out-of-the-box
- ✅ Decisões arquiteturais são claras e justificadas
- ✅ Troubleshooting cobre casos reais encontrados

---

## ✅ Checklist de Implementação

### Fase 1: Fundação ✅ COMPLETA
- [x] Completar Perfil de Contexto do Projeto
- [x] Criar PROJECT_CHARTER.md
- [x] Configurar estrutura de ADRs
- [x] Atribuir propriedade da documentação

### Fase 2: Otimização para IA ✅ COMPLETA
- [x] Criar CLAUDE.meta.md
- [x] Criar CODEBASE_GUIDE.md
- [x] Criar API_SPECIFICATION.md
- [x] Adicionar padrão DioException mandatório em CLAUDE.meta.md e API_SPECIFICATION.md
- [x] Testar efetividade da IA com novo contexto

### Fase 3: Contexto de Domínio ✅ COMPLETA
- [x] Documentar Design System (cores, tipografia, componentes)
- [x] Documentar lógica de negócio (SRS, progressão, entidades)
- [x] Documentar BUSINESS_LOGIC.md (sistema SRS completo)
- [x] Documentar casos extremos conhecidos em TROUBLESHOOTING.md

### Fase 4: Manutenção 🔄 CONTÍNUO
- [ ] Estabelecer gatilhos de atualização
- [ ] Criar procedimentos de quality assurance
- [ ] Monitorar métricas de sucesso
- [ ] Iterar baseado em feedback

---

## 🔍 Navegação Rápida

### Para Novos Desenvolvedores
1. Comece com [Project Charter](project_charter.md) para entender a visão
2. Leia [CODEBASE_GUIDE.md](CODEBASE_GUIDE.md) para navegar o código
3. Configure ambiente usando [CONTRIBUTING.md](CONTRIBUTING.md)
4. Consulte [CLAUDE.meta.md](CLAUDE.meta.md) para padrões de código
5. Revise [Design System](../design/DESIGN_SYSTEM.md) para UI/UX guidelines

### Para IA/Copilot
1. Carregue este `index.md` para contexto geral
2. Referencie [CLAUDE.meta.md](CLAUDE.meta.md) para padrões de código
3. Consulte ADRs específicos em `adr/` para decisões arquiteturais
4. Use [API_SPECIFICATION.md](API_SPECIFICATION.md) para integrações
5. Siga [Design System](../design/DESIGN_SYSTEM.md) para implementação de UI

### Para Troubleshooting
1. Consulte [TROUBLESHOOTING.md](TROUBLESHOOTING.md) primeiro
2. Verifique issues no GitHub
3. Revise ADRs relacionados para contexto de decisões

---

## 📝 Notas de Versão

### v1.0.0 - 11/10/2025
- ✅ Estrutura inicial de documentação criada
- ✅ Project Charter definido
- ✅ ADRs principais documentados (5 decisões)
- ✅ Stack tecnológica selecionada
- ✅ Features iniciais implementadas (login + home)
- ✅ Documentação técnica completa (8/8 arquivos):
  - CLAUDE.meta.md - Guia IA com padrão DioException mandatório
  - CODEBASE_GUIDE.md - Estrutura atualizada com features reais
  - API_SPECIFICATION.md - Error handling e retry strategy completos
  - BUSINESS_LOGIC.md - Sistema SRS WaniKani documentado
  - CONTRIBUTING.md - Workflow de desenvolvimento completo
  - TROUBLESHOOTING.md - 3 problemas reais com soluções
  - ARCHITECTURE_CHALLENGES.md - 10 desafios priorizados
  - index.md - Este arquivo atualizado com progresso real

---

> **💡 Dica:** Esta documentação é viva e deve evoluir com o projeto. Contribua mantendo-a atualizada!
