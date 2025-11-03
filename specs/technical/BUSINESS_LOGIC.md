# Lógica de Negócio - WaniKani App

> **Última Atualização:** 02/11/2025  
> **Versão:** 1.0.0

---

## 🎯 Visão Geral

Este documento descreve a lógica de negócio do WaniKani, incluindo conceitos de domínio, regras de progressão e casos extremos. O WaniKani App é um **cliente read-only** que consome dados da API oficial, sem capacidade de modificar estado (reviews, lessons, progressão).

---

## 📚 Conceitos de Domínio

### Sistema SRS (Spaced Repetition System)

**Definição:**  
SRS (Spaced Repetition System) é um método de aprendizagem baseado em revisões espaçadas temporalmente. O conteúdo é revisado em intervalos progressivos (curto, médio e longo prazo) para otimizar a retenção de memória.

**Como Funciona no WaniKani:**
1. Usuário estuda um novo item (radical, kanji ou vocabulário)
2. Item é revisado em intervalos crescentes baseados em performance
3. Acertos aumentam o intervalo (progresso no SRS)
4. Erros diminuem o intervalo (regressão no SRS)
5. Items eventualmente atingem status "Burned" (permanentemente aprendido)

**Estágios SRS:**

O WaniKani utiliza **10 estágios SRS** (0-9), mas a API não fornece detalhes internos sobre os intervalos exatos. O que sabemos:

| Stage | Nome | Descrição |
|-------|------|-----------|
| 0 | Locked | Item ainda não desbloqueado |
| 1-4 | Apprentice | Aprendizado inicial (revisões frequentes) |
| 5-6 | Guru | Item parcialmente dominado |
| 7 | Master | Item bem consolidado |
| 8 | Enlightened | Item quase permanente |
| 9 | Burned | Item permanentemente aprendido |

**Cores SRS no App:**
- Apprentice (1-4): `#DD0093` (rosa escuro)
- Guru (5-6): `#882D9E` (roxo)
- Master (7): `#294DDB` (azul)
- Enlightened (8): `#0093DD` (azul claro)
- Burned (9): `#434343` (cinza escuro)

---

## 🏗️ Tipos de Conteúdo

### 1. Radicals (Radicais)

**Definição:**  
Pequenas partes ou componentes visuais que, isoladamente, **não possuem significado próprio**, mas quando combinados formam a base de kanjis.

**Características:**
- Blocos de construção fundamentais
- Primeiro tipo a ser aprendido em cada nível
- Servem como mnemônicos para memorizar kanjis
- Cor no app: `#00AAFF` (azul vibrante)

**Exemplo:**
- Radical "⺅" (person radical) + "木" (tree) = "休" (rest)

### 2. Kanji

**Definição:**  
Caracteres japoneses que representam palavras ou conceitos completos. São formados pela combinação de radicais.

**Características:**
- Aprendidos após radicais do mesmo nível
- Possuem múltiplas leituras (on'yomi e kun'yomi)
- Cada kanji tem significado próprio
- Cor no app: `#FF00AA` (rosa/magenta)

**Exemplo:**
- Kanji "休" (descansar) usa os radicais "person" + "tree"

### 3. Vocabulary (Vocabulário)

**Definição:**  
Vocábulos japoneses que transmitem ideias, emoções e subjetividades. Podem ou não ser acompanhados de hiragana.

**Características:**
- Aprendidos após kanjis do mesmo nível
- Podem ser:
  - Kanji puro: 食事 (refeição)
  - Kanji + hiragana: 食べる (comer)
  - Múltiplos kanjis: 日本語 (língua japonesa)
- Reforçam as leituras dos kanjis
- Cor no app: `#9900FF` (roxo)

**Exemplo:**
- Vocabulary "休む" (yasumu - descansar) usa o kanji "休"

---

## 📈 Progressão de Níveis

### Estrutura de Níveis

O WaniKani possui **60 níveis** de progressão, cada um contendo:
- Radicais (aprendidos primeiro)
- Kanjis (desbloqueados após radicais)
- Vocabulário (desbloqueado após kanjis)

### Regras de Progressão

**Um nível é considerado completo quando:**
1. Todos os **radicais** do nível atingiram pelo menos SRS stage 5 (Guru)
2. Todos os **kanjis** do nível atingiram pelo menos SRS stage 5 (Guru)
3. **Vocabulário não bloqueia progressão** (pode ser deixado para trás)

**Desbloqueio do Próximo Nível:**
- Usuário precisa completar os critérios acima
- Próximo nível é automaticamente desbloqueado pela API
- Radicais do novo nível ficam disponíveis para estudo

### Estados de um Nível

Baseado na análise do código (`home_repository.dart`), um nível pode estar em 3 estados:

#### 1. **Nível Atual (Current Level)**
Regras para identificação:
```dart
// Regra 1: Primeiro nível com passed_at == null E unlocked_at != null
if (progression.passedAt == null && progression.unlockedAt != null) {
  currentLevel = progression; // Este é o nível atual
}

// Regra 2: Se não encontrou, procurar item anterior ao unlocked_at == null
if (progressions[i].unlockedAt == null && i > 0) {
  currentLevel = progressions[i - 1];
}

// Regra 3: Último nível com unlocked_at != null
for (var i = progressions.length - 1; i >= 0; i--) {
  if (progressions[i].unlockedAt != null) {
    currentLevel = progressions[i];
    break;
  }
}
```

#### 2. **Níveis Passados**
- `passedAt != null` — Nível foi completado
- `unlockedAt != null` — Nível já foi acessado

#### 3. **Níveis Futuros (Locked)**
- `unlockedAt == null` — Nível ainda não desbloqueado
- Usuário ainda não pode estudar este conteúdo

---

## 🎮 Entidades de Domínio

### AssignmentEntity

Representa um **assignment** (tarefa de estudo) atribuída ao usuário.

**Campos Principais:**
```dart
class AssignmentEntity {
  final int id;                    // ID único do assignment
  final int subjectId;             // ID do subject (radical/kanji/vocab)
  final String subjectType;        // "radical", "kanji", "vocabulary"
  final int srsStage;              // Stage SRS atual (0-9)
  final DateTime? availableAt;     // Quando próxima review está disponível
  final DateTime? passedAt;        // Quando passou para Guru+
  final DateTime? burnedAt;        // Quando foi "burned"
  final DateTime? unlockedAt;      // Quando foi desbloqueado
  final DateTime? startedAt;       // Quando começou a estudar
}
```

**Regras de Negócio:**
- `availableAt == null` → Não há review pendente
- `availableAt <= DateTime.now()` → Review disponível agora
- `availableAt > DateTime.now()` → Review disponível no futuro
- `srsStage == 0` → Item ainda não iniciado
- `srsStage >= 5` → Item passou para Guru (contribui para progressão)
- `srsStage == 9` → Item burned (permanentemente aprendido)

### LevelProgressionEntity

Representa a **progressão em um nível** específico.

**Campos Principais:**
```dart
class LevelProgressionEntity {
  final int id;                    // ID da progressão
  final int level;                 // Número do nível (1-60)
  final DateTime? unlockedAt;      // Quando nível foi desbloqueado
  final DateTime? startedAt;       // Quando começou a estudar
  final DateTime? passedAt;        // Quando completou o nível
  final DateTime? completedAt;     // Quando finalizou 100% (incluindo vocab)
  final DateTime? abandonedAt;     // Quando abandonou (reset de progresso)
}
```

**Regras de Negócio:**
- `unlockedAt != null && passedAt == null` → Nível atual
- `passedAt != null` → Nível completado (passou para próximo)
- `completedAt != null` → 100% do nível concluído (incluindo vocab)
- `abandonedAt != null` → Progresso foi resetado

### ReviewStatsEntity

Representa **estatísticas de reviews**.

**Campos Principais:**
```dart
class ReviewStatsEntity {
  final int availableReviewCount;  // Quantidade de reviews disponíveis agora
  final DateTime? nextReviewAt;    // Quando próximo review estará disponível
}
```

**Regras de Negócio:**
- `availableReviewCount > 0` → Há reviews para fazer
- `availableReviewCount == 0 && nextReviewAt != null` → Próximo review agendado
- `availableReviewCount == 0 && nextReviewAt == null` → Nenhum review pendente

### LessonStatsEntity

Representa **estatísticas de lessons** (novos itens para aprender).

**Campos Principais:**
```dart
class LessonStatsEntity {
  final int availableLessonCount;  // Quantidade de lessons disponíveis
}
```

**Regras de Negócio:**
- `availableLessonCount > 0` → Há novos itens para aprender
- `availableLessonCount == 0` → Nenhum item novo no momento

---

## 🔍 Casos Extremos (Edge Cases)

### 1. Usuário Novo (Primeiro Uso)

**Cenário:**
- Usuário acabou de se cadastrar no WaniKani
- Nenhum progresso ainda

**Estado Esperado:**
- `level == 1`
- `availableReviewCount == 0`
- `availableLessonCount > 0` (radicais do nível 1)
- Nenhum assignment disponível

**Tratamento no App:**
- Exibir mensagem de boas-vindas
- Indicar que há lessons disponíveis
- Não mostrar reviews (não há nada para revisar)

### 2. Usuário no Nível 60 (Máximo)

**Cenário:**
- Usuário atingiu o nível máximo do WaniKani
- Ainda pode ter reviews pendentes

**Estado Esperado:**
- `level == 60`
- `availableReviewCount >= 0`
- `availableLessonCount` pode ser 0 ou > 0 (se ainda não aprendeu todo vocab)

**Tratamento no App:**
- Mostrar indicador de "Nível Máximo Atingido"
- Continuar exibindo reviews normalmente
- Não há próximo nível para desbloquear

### 3. Cache Expirado (Offline por Muito Tempo)

**Cenário:**
- Usuário ficou offline por > 24h (cache de assignments expirado)
- App tenta carregar dados

**Estado Esperado:**
- Cache local está desatualizado
- API pode estar inacessível

**Tratamento Planejado:**
1. Tentar buscar dados da API
2. Se falhar, usar cache expirado (melhor que nada)
3. Exibir indicador de "Dados desatualizados"
4. Permitir refresh manual

**Código de Referência:**
```dart
// Padrão offline-first (a implementar com Drift)
try {
  // 1. Checar cache
  final cached = await _dao.getAssignments();
  if (cached.isNotEmpty && !_isExpired(cached)) {
    return Right(cached);
  }
  
  // 2. Buscar da API
  final response = await _datasource.getAssignments();
  if (response.isSuccessful) {
    await _dao.upsertAssignments(response.data);
    return Right(response.data);
  }
  
  // 3. Fallback para cache expirado
  return cached.isNotEmpty 
    ? Right(cached) 
    : Left(NetworkError());
} catch (e) {
  // Usar cache mesmo expirado
  final cached = await _dao.getAssignments();
  return cached.isNotEmpty 
    ? Right(cached) 
    : Left(InternalError());
}
```

### 4. Token Inválido (401 Unauthorized)

**Cenário:**
- API key foi revogada ou expirou
- API retorna 401

**Estado Esperado:**
- Todas as requisições falham com 401

**Tratamento Atual:**
- ✅ Detectado no login (mostra bottom sheet de erro)
- ❌ **NÃO detectado em áreas logadas** (precisa implementar)

**Tratamento Planejado:**
1. Interceptor global detecta 401
2. Limpa token armazenado
3. Redireciona para tela de login
4. Exibe mensagem "Sessão expirada, faça login novamente"

### 5. Rate Limit (429 Too Many Requests)

**Cenário:**
- App excedeu 60 requisições/minuto
- API retorna 429

**Estado Esperado:**
- Header `Retry-After` indica tempo de espera

**Tratamento Planejado:**
1. Detectar erro 429
2. Ler header `Retry-After`
3. Aguardar tempo especificado
4. Retry automático (com exponential backoff)

**Código de Referência:**
```dart
// Interceptor de retry (a implementar)
if (response.statusCode == 429) {
  final retryAfter = response.headers['Retry-After'];
  final waitSeconds = int.tryParse(retryAfter ?? '60') ?? 60;
  
  await Future.delayed(Duration(seconds: waitSeconds));
  return dio.request(response.requestOptions.path);
}
```

### 6. Nenhum Assignment Disponível

**Cenário:**
- Usuário completou todas reviews
- Próximo review é daqui 4 horas

**Estado Esperado:**
- `availableReviewCount == 0`
- `nextReviewAt` tem data/hora futura

**Tratamento no App:**
- Exibir mensagem "Nenhum review disponível"
- Mostrar countdown até próximo review
- Exibir `nextReviewAt` formatado

### 7. Dados Vazios da API

**Cenário:**
- Endpoint retorna `data: []` (lista vazia)
- Não é erro, apenas sem dados

**Estado Esperado:**
- Response com status 200
- Array vazio em `data`

**Tratamento no App:**
```dart
if (response.isSuccessful) {
  final data = (response.data['data'] as List);
  
  if (data.isEmpty) {
    // Caso específico: sem level progressions
    return Left(InternalErrorEntity('Nenhum progresso encontrado'));
  }
  
  final entities = data.map((json) => Model.fromJson(json)).toList();
  return Right(entities);
}
```

---

## 🚫 Limitações do App

### Operações NÃO Suportadas

O WaniKani App é **read-only** e **não permite**:

❌ **Realizar Reviews:**
- Marcar respostas como corretas/incorretas
- Atualizar SRS stage de items
- Completar reviews

❌ **Fazer Lessons:**
- Estudar novos items
- Marcar lessons como completas
- Adicionar items ao SRS

❌ **Modificar Configurações:**
- Alterar configurações de review/lesson
- Modificar vacation mode
- Resetar progresso

❌ **Editar Conteúdo:**
- Adicionar mnemonics customizados
- Criar sinônimos
- Adicionar notas pessoais

### API Endpoints Utilizados (GET apenas)

✅ **Suportado:**
- `GET /user` — Dados do usuário
- `GET /assignments` — Lista de assignments
- `GET /level_progressions` — Progressão de níveis
- `GET /reviews` — Estatísticas de reviews
- `GET /study_materials` — Estatísticas de lessons

❌ **NÃO Utilizado:**
- `POST /reviews` — Submeter reviews
- `POST /assignments` — Criar assignments
- `PUT /study_materials` — Atualizar study materials
- Qualquer endpoint de escrita

---

## 📊 Métricas e KPIs

### Métricas Exibidas no Dashboard

**Progresso de Nível:**
- Nível atual (1-60)
- Porcentagem de conclusão do nível atual

**Reviews:**
- Quantidade de reviews disponíveis agora
- Próximo review disponível (data/hora)

**Lessons:**
- Quantidade de lessons disponíveis

**Distribuição por SRS Stage:**
- Apprentice items (stage 1-4)
- Guru items (stage 5-6)
- Master items (stage 7)
- Enlightened items (stage 8)
- Burned items (stage 9)

### Cálculos Derivados

**Progresso do Nível Atual:**
```dart
// Baseado em assignments do nível atual
final totalItems = radicals.length + kanjis.length;
final guruItems = assignments.where((a) => a.srsStage >= 5).length;
final progress = (guruItems / totalItems) * 100;
```

**Próximo Review Disponível:**
```dart
// Menor availableAt entre todos assignments
final nextReview = assignments
  .where((a) => a.availableAt != null)
  .map((a) => a.availableAt!)
  .reduce((a, b) => a.isBefore(b) ? a : b);
```

---

## 🔄 Fluxos de Dados

### Fluxo de Carregamento da Home

```
1. HomeCubit.loadDashboardData()
   ↓
2. GetCurrentLevelUseCase() → LevelProgressionEntity
   ↓
3. GetAssignmentsUseCase() → List<AssignmentEntity>
   ↓
4. GetReviewStatsUseCase() → ReviewStatsEntity
   ↓
5. GetLessonStatsUseCase() → LessonStatsEntity
   ↓
6. Emit HomeLoaded(level, assignments, reviews, lessons)
   ↓
7. UI renderiza dashboard
```

### Fluxo de Autenticação

```
1. User insere API key
   ↓
2. LoginCubit.login(apiKey)
   ↓
3. GetUserUseCase() → GET /user
   ↓
4. Se 200 OK:
   - Salvar API key (flutter_secure_storage)
   - Salvar UserEntity localmente (planejado)
   - Navegar para /home
   ↓
5. Se 401:
   - Exibir bottom sheet "Token inválido"
   - Não salvar nada
   - Permanecer no login
```

---

## 📖 Glossário

| Termo | Definição |
|-------|-----------|
| **SRS** | Spaced Repetition System - Sistema de repetição espaçada |
| **Assignment** | Item de estudo atribuído ao usuário |
| **Subject** | Conteúdo de estudo (radical, kanji, vocabulary) |
| **Review** | Revisão de um item já estudado |
| **Lesson** | Estudo de um novo item |
| **Guru** | SRS stage 5-6 (item parcialmente dominado) |
| **Burned** | SRS stage 9 (item permanentemente aprendido) |
| **Level** | Nível de progressão (1-60) |
| **Radical** | Componente visual básico dos kanjis |
| **Kanji** | Caractere japonês |
| **Vocabulary** | Vocábulo japonês |

---

## 🔗 Referências

- [WaniKani API Documentation](https://docs.api.wanikani.com/)
- [WaniKani Knowledge Guide](https://knowledge.wanikani.com/)
- [SRS Explanation](https://en.wikipedia.org/wiki/Spaced_repetition)

---

> **Nota:** Este documento reflete a lógica de negócio do WaniKani conforme entendida pela API v2. Detalhes internos do algoritmo SRS são propriedade da Tofugu LLC.
