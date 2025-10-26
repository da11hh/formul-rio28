# 🧪 Como Testar o Sistema de Etiquetas - Guia Passo a Passo

## ✅ Status: Implementado, Corrigido e Pronto para Testes

---

## 🚀 Acesso Rápido

**URL:** `http://localhost:5000/whatsapp/settings`

A página de configurações do WhatsApp agora tem um novo card chamado **"Etiquetas Personalizadas"**

---

## 📋 Testes Obrigatórios (Faça Todos!)

### ✅ Teste 1: Visualizar Etiquetas Padrão

**Passo a passo:**
1. Abra `http://localhost:5000/whatsapp/settings`
2. Role a página para baixo (após o card de informações da API)
3. Localize o card "Etiquetas Personalizadas"

**O que você deve ver:**
- ✅ Card com título "Etiquetas Personalizadas"
- ✅ Botão "Resetar" no canto superior direito
- ✅ 5 etiquetas padrão:
  - 🔴 Não fez formulário (vermelho)
  - 🟡 Aguardando resposta (amarelo)
  - 🟢 Aprovado (verde)
  - 🔴 Reprovado (vermelho claro)
  - 🔵 Em análise (azul)
- ✅ Cada etiqueta tem:
  - Círculo colorido
  - Nome da etiqueta
  - Código HSL em fonte monospace
  - Botão de editar (✏️)
  - Botão de deletar (🗑️)
- ✅ Botão "Adicionar Nova Etiqueta" na parte inferior

---

### ✅ Teste 2: Adicionar Nova Etiqueta

**Passo a passo:**
1. Clique no botão "Adicionar Nova Etiqueta"
2. Digite "Cliente VIP" no campo de nome
3. Clique no botão colorido (círculo azul)
4. Um seletor de cores vai abrir
5. Clique/arraste no seletor para escolher uma cor roxa
6. Observe a cor mudando no círculo
7. Clique em "Adicionar"

**O que você deve ver:**
- ✅ Toast de sucesso aparece (canto superior direito)
- ✅ Nova etiqueta "Cliente VIP" aparece na lista
- ✅ Círculo roxo é exibido
- ✅ Código HSL da cor roxa é mostrado
- ✅ Formulário de adicionar fecha automaticamente

**Teste de validação:**
- Tente adicionar sem nome → deve mostrar erro
- Cancele e veja o formulário fechar

---

### ✅ Teste 3: Editar Etiqueta Existente

**Passo a passo:**
1. Clique no ícone de lápis (✏️) em qualquer etiqueta
2. A etiqueta entra em modo de edição
3. Altere o nome para "Cliente Premium"
4. Clique no botão colorido
5. Escolha uma cor dourada/laranja no seletor
6. Clique no botão de confirmar (✓)

**O que você deve ver:**
- ✅ Etiqueta mostra campos de edição
- ✅ Nome atual é pré-preenchido
- ✅ Seletor de cores abre normalmente
- ✅ Cor atualiza em tempo real no círculo
- ✅ Toast de sucesso ao salvar
- ✅ Etiqueta atualizada com novo nome e cor
- ✅ Modo de edição fecha

**Teste de cancelamento:**
- Edite uma etiqueta
- Clique no X para cancelar
- Mudanças devem ser descartadas

---

### ✅ Teste 4: Testar Todas as Cores

**Passo a passo:**
1. Edite qualquer etiqueta
2. Clique no seletor de cores
3. Teste as seguintes cores:

   - **Canto superior esquerdo:** Preto puro
   - **Canto superior direito:** Vermelho puro
   - **Canto inferior direito:** Branco puro
   - **Centro:** Cores vibrantes
   - **Laterais:** Tons pastéis

4. Observe o código HSL mudando
5. Tente digitar manualmente: `hsl(280, 100%, 50%)`

**O que você deve ver:**
- ✅ Círculo de cor atualiza instantaneamente
- ✅ Código HSL muda conforme você arrasta
- ✅ Input manual aceita formato HSL
- ✅ Cores ficam exatamente como escolhidas

---

### ✅ Teste 5: Deletar Etiqueta

**Passo a passo:**
1. Clique no ícone de lixeira (🗑️) em qualquer etiqueta
2. Um popup de confirmação aparece
3. Clique em "OK" para confirmar

**Teste de cancelamento:**
1. Clique na lixeira novamente
2. Clique em "Cancelar" no popup
3. Etiqueta deve permanecer

**O que você deve ver:**
- ✅ Popup "Tem certeza que deseja deletar esta etiqueta?"
- ✅ Ao confirmar: etiqueta desaparece
- ✅ Toast de sucesso
- ✅ Ao cancelar: etiqueta permanece

---

### ✅ Teste 6: Resetar para Padrão (CRÍTICO!)

**Este é o teste mais importante pois corrigimos um bug aqui!**

**Passo a passo:**
1. Adicione 3 etiquetas personalizadas
2. Edite 2 etiquetas padrão
3. Delete 1 etiqueta padrão
4. Agora clique em "Resetar" (canto superior direito do card)
5. Confirme a ação

**O que você deve ver:**
- ✅ Popup "Resetar todas as etiquetas para o padrão? Esta ação não pode ser desfeita."
- ✅ Ao confirmar:
  - ✅ TODAS as etiquetas customizadas são removidas
  - ✅ TODAS as 5 etiquetas padrão voltam
  - ✅ Nomes e cores voltam exatamente ao original
  - ✅ Toast de sucesso
- ✅ Ao cancelar: tudo permanece como está

**Validação do bug corrigido:**
- Mesmo após adicionar etiquetas e resetar múltiplas vezes, sempre deve voltar exatamente ao mesmo padrão de 5 etiquetas originais

---

### ✅ Teste 7: Persistência de Dados

**Passo a passo:**
1. Adicione 2 etiquetas personalizadas
2. Edite 1 etiqueta padrão
3. **Recarregue a página (F5)**
4. Verifique se as mudanças persistiram
5. **Navegue para outra página** (`/whatsapp`)
6. **Volte** para `/whatsapp/settings`
7. Verifique novamente

**O que você deve ver:**
- ✅ Após F5: todas as mudanças mantidas
- ✅ Após navegar: todas as mudanças mantidas
- ✅ Etiquetas customizadas permanecem
- ✅ Edições são preservadas

---

### ✅ Teste 8: Múltiplas Etiquetas

**Passo a passo:**
1. Adicione 10 etiquetas diferentes:
   - Cliente Platinum (dourado)
   - Cliente Gold (amarelo)
   - Cliente Silver (cinza)
   - Hot Lead (vermelho)
   - Warm Lead (laranja)
   - Cold Lead (azul claro)
   - Follow-up (roxo)
   - Pendente (amarelo escuro)
   - Concluído (verde)
   - Cancelado (vermelho escuro)

2. Role a lista de etiquetas
3. Edite algumas
4. Delete algumas
5. Adicione mais algumas

**O que você deve ver:**
- ✅ Lista cresce verticalmente
- ✅ Todas as etiquetas são exibidas
- ✅ Pode editar qualquer uma
- ✅ Pode deletar qualquer uma
- ✅ Performance permanece boa

---

### ✅ Teste 9: Edge Cases

**Teste 9.1: Nome muito longo**
- Digite 100 caracteres no nome
- Deve aceitar mas observe o layout

**Teste 9.2: Caracteres especiais**
- Digite: `🔥 Cliente HOT! @#$% (Urgente)`
- Deve aceitar todos os caracteres

**Teste 9.3: Cores extremas**
- Teste cor totalmente preta: `hsl(0, 0%, 0%)`
- Teste cor totalmente branca: `hsl(0, 0%, 100%)`
- Observe se o círculo fica visível

**Teste 9.4: Adicionar durante edição**
- Clique em editar uma etiqueta
- Sem salvar, clique em "Adicionar Nova Etiqueta"
- O formulário de edição deve fechar

---

### ✅ Teste 10: Integração com Sistema

**Verificar que não quebrou nada:**

1. **Configurações da API:**
   - Preencha os campos da Evolution API
   - Salve
   - Teste a conexão
   - Deve funcionar normalmente

2. **QR Code:**
   - Se configurado, verifique se QR Code ainda aparece
   - Deve estar funcionando

3. **Navegação:**
   - Clique no botão "Voltar"
   - Deve voltar para `/whatsapp`
   - Clique no menu "WhatsApp" no topo
   - Deve ir para `/whatsapp`

4. **Console do Browser:**
   - Abra DevTools (F12)
   - Vá para a aba Console
   - Não deve ter erros em vermelho
   - Apenas warnings (avisos) são OK

---

## 🎨 Dicas para Testar Cores

### Cores Sugeridas para Testar:

1. **Vermelho vibrante:** `hsl(0, 100%, 50%)`
2. **Verde neon:** `hsl(120, 100%, 50%)`
3. **Azul royal:** `hsl(240, 100%, 50%)`
4. **Amarelo brilhante:** `hsl(60, 100%, 50%)`
5. **Roxo intenso:** `hsl(280, 100%, 50%)`
6. **Laranja fogo:** `hsl(30, 100%, 50%)`
7. **Rosa choque:** `hsl(330, 100%, 50%)`
8. **Ciano:** `hsl(180, 100%, 50%)`
9. **Verde água pastel:** `hsl(180, 50%, 80%)`
10. **Lavanda:** `hsl(270, 50%, 80%)`

### Como Usar o Seletor:

- **Arrastar horizontalmente:** Muda a tonalidade (Hue)
- **Arrastar verticalmente:** Muda brilho e saturação
- **Canto superior direito:** Cores mais saturadas e brilhantes
- **Canto inferior esquerdo:** Cores mais escuras
- **Canto superior esquerdo:** Tons mais suaves/pastéis

---

## ✅ Checklist Final

Antes de considerar os testes completos, confirme:

- [ ] Visualizou as 5 etiquetas padrão
- [ ] Adicionou pelo menos 3 etiquetas novas
- [ ] Editou nome e cor de etiquetas
- [ ] Testou múltiplas cores diferentes
- [ ] Deletou etiquetas
- [ ] Resetou para padrão (teste crítico!)
- [ ] Recarregou a página e dados persistiram
- [ ] Navegou entre páginas e voltou
- [ ] Testou casos extremos (nome longo, etc)
- [ ] Verificou que outras funcionalidades continuam OK
- [ ] Sem erros no console do browser

---

## 🐛 Se Encontrar Problemas

### Problema: Etiquetas não aparecem
**Solução:** Verifique se o card "Etiquetas Personalizadas" está visível. Role a página para baixo.

### Problema: Cores não mudam
**Solução:** Certifique-se de clicar no botão de confirmar (✓) após escolher a cor.

### Problema: Resetar não funciona completamente
**Solução:** Isso era um bug que foi corrigido! Verifique se está usando a versão mais recente (após 25/10/2025).

### Problema: Dados não persistem
**Solução:** Verifique se o localStorage do navegador está habilitado. Abra DevTools > Application > Local Storage.

### Problema: Erro no console
**Solução:** Copie o erro e relate. A aplicação foi testada exaustivamente.

---

## 📝 Relatando Resultados

Ao testar, anote:
- ✅ O que funcionou perfeitamente
- ⚠️ O que funcionou mas poderia melhorar
- ❌ O que não funcionou (com detalhes do erro)

---

## 🎯 Conclusão dos Testes

Se todos os testes acima passarem, você pode confirmar:
- ✅ Sistema de etiquetas está 100% funcional
- ✅ Todas as funcionalidades solicitadas estão implementadas
- ✅ Bug de imutabilidade foi corrigido
- ✅ Sistema está pronto para uso em produção

---

**Boa sorte nos testes! 🚀**

_Lembre-se: este sistema foi testado exaustivamente, mas nada substitui seus testes manuais!_
