#!/bin/bash

# 🧪 Script de Teste Automatizado - Evolution API
# Testa todos os endpoints de envio de mensagens

set -e

# ========================================
# CONFIGURAÇÃO
# ========================================

# Substitua com suas credenciais
SUPABASE_URL="https://SEU_PROJETO.supabase.co"
SUPABASE_ANON_KEY="SEU_ANON_KEY_AQUI"

API_URL="http://103.199.187.145:8080/"
API_KEY="10414D921BD3-4EC3-A745-AC2EBB189044"
INSTANCE="nexus intelligence"
TEST_NUMBER="553192267220"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# ========================================
# FUNÇÕES AUXILIARES
# ========================================

log_info() {
    echo -e "${YELLOW}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# ========================================
# TESTE 0: Verificar Conexão da Instância
# ========================================

test_connection() {
    log_info "Verificando conexão da instância..."
    
    RESPONSE=$(curl -s -X GET \
        "${API_URL}instance/connectionState/${INSTANCE// /%20}" \
        -H "apikey: ${API_KEY}")
    
    STATE=$(echo "$RESPONSE" | jq -r '.instance.state' 2>/dev/null || echo "error")
    
    if [ "$STATE" == "open" ]; then
        log_success "Instância conectada! Estado: $STATE"
        return 0
    else
        log_error "Instância desconectada! Estado: $STATE"
        log_error "Resposta completa: $RESPONSE"
        return 1
    fi
}

# ========================================
# TESTE 1: Enviar Mensagem de Texto
# ========================================

test_text_message() {
    log_info "Testando envio de mensagem de texto..."
    
    RESPONSE=$(curl -s -X POST \
        "${SUPABASE_URL}/functions/v1/evolution-send-message" \
        -H "Authorization: Bearer ${SUPABASE_ANON_KEY}" \
        -H "Content-Type: application/json" \
        -d "{
            \"apiUrl\": \"${API_URL}\",
            \"apiKey\": \"${API_KEY}\",
            \"instance\": \"${INSTANCE}\",
            \"number\": \"${TEST_NUMBER}\",
            \"text\": \"🧪 Teste automatizado - Mensagem de texto - $(date '+%H:%M:%S')\"
        }")
    
    SUCCESS=$(echo "$RESPONSE" | jq -r '.success' 2>/dev/null || echo "false")
    
    if [ "$SUCCESS" == "true" ]; then
        log_success "Mensagem de texto enviada!"
        echo "   Resposta: $(echo "$RESPONSE" | jq -c '.')"
        return 0
    else
        log_error "Falha ao enviar mensagem de texto"
        echo "   Resposta: $RESPONSE"
        return 1
    fi
}

# ========================================
# TESTE 2: Enviar Áudio
# ========================================

test_audio_message() {
    log_info "Testando envio de áudio..."
    
    # Gerar um áudio base64 de teste (silêncio de 1 segundo)
    # Este é um arquivo WebM Opus válido mínimo (silêncio)
    AUDIO_BASE64="GkXfo59ChoEBQveBAULygQRC84EIQoKEd2VibUKHgQRChYECGFOAZwH/////////FUmpZpkq17GDD0JATYCGQ2hyb21lV0GGQ2hyb2xlV0GGQ2hyb21lV0GGQ2hyb21lV0GGQ2hyb21lV0GGQ2hyb21lV0GGQ2hyb21lV0GGQ2hyb21lV0GGQ2hyb21lV0GGQ2hyb21lV0GG"
    
    RESPONSE=$(curl -s -X POST \
        "${SUPABASE_URL}/functions/v1/evolution-send-audio" \
        -H "Authorization: Bearer ${SUPABASE_ANON_KEY}" \
        -H "Content-Type: application/json" \
        -d "{
            \"apiUrl\": \"${API_URL}\",
            \"apiKey\": \"${API_KEY}\",
            \"instance\": \"${INSTANCE}\",
            \"number\": \"${TEST_NUMBER}\",
            \"audioBase64\": \"${AUDIO_BASE64}\"
        }")
    
    SUCCESS=$(echo "$RESPONSE" | jq -r '.success' 2>/dev/null || echo "false")
    
    if [ "$SUCCESS" == "true" ]; then
        log_success "Áudio enviado!"
        echo "   Resposta: $(echo "$RESPONSE" | jq -c '.')"
        return 0
    else
        log_error "Falha ao enviar áudio"
        echo "   Resposta: $RESPONSE"
        return 1
    fi
}

# ========================================
# TESTE 3: Enviar Imagem
# ========================================

test_image_message() {
    log_info "Testando envio de imagem..."
    
    # Imagem PNG mínima válida (1x1 pixel vermelho) em base64
    IMAGE_BASE64="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8/5+hHgAHggJ/PchI7wAAAABJRU5ErkJggg=="
    
    RESPONSE=$(curl -s -X POST \
        "${SUPABASE_URL}/functions/v1/evolution-send-media" \
        -H "Authorization: Bearer ${SUPABASE_ANON_KEY}" \
        -H "Content-Type: application/json" \
        -d "{
            \"apiUrl\": \"${API_URL}\",
            \"apiKey\": \"${API_KEY}\",
            \"instance\": \"${INSTANCE}\",
            \"number\": \"${TEST_NUMBER}\",
            \"mediatype\": \"image\",
            \"mimetype\": \"image/png\",
            \"caption\": \"🧪 Teste automatizado - Imagem\",
            \"media\": \"${IMAGE_BASE64}\"
        }")
    
    SUCCESS=$(echo "$RESPONSE" | jq -r '.success' 2>/dev/null || echo "false")
    
    if [ "$SUCCESS" == "true" ]; then
        log_success "Imagem enviada!"
        echo "   Resposta: $(echo "$RESPONSE" | jq -c '.')"
        return 0
    else
        log_error "Falha ao enviar imagem"
        echo "   Resposta: $RESPONSE"
        return 1
    fi
}

# ========================================
# TESTE 4: Buscar Mensagens
# ========================================

test_fetch_messages() {
    log_info "Testando busca de mensagens..."
    
    RESPONSE=$(curl -s -X POST \
        "${SUPABASE_URL}/functions/v1/evolution-fetch-messages" \
        -H "Authorization: Bearer ${SUPABASE_ANON_KEY}" \
        -H "Content-Type: application/json" \
        -d "{
            \"apiUrl\": \"${API_URL}\",
            \"apiKey\": \"${API_KEY}\",
            \"instance\": \"${INSTANCE}\",
            \"remoteJid\": \"${TEST_NUMBER}@s.whatsapp.net\",
            \"limit\": 10
        }")
    
    SUCCESS=$(echo "$RESPONSE" | jq -r '.success' 2>/dev/null || echo "false")
    
    if [ "$SUCCESS" == "true" ]; then
        MESSAGE_COUNT=$(echo "$RESPONSE" | jq -r '.data | length' 2>/dev/null || echo "0")
        log_success "Mensagens recuperadas! Total: $MESSAGE_COUNT"
        return 0
    else
        log_error "Falha ao buscar mensagens"
        echo "   Resposta: $RESPONSE"
        return 1
    fi
}

# ========================================
# EXECUTAR TODOS OS TESTES
# ========================================

echo "================================================"
echo "🧪 INICIANDO TESTES DA EVOLUTION API"
echo "================================================"
echo ""

TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

run_test() {
    local test_name=$1
    local test_function=$2
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo ""
    echo "================================================"
    echo "Teste $TOTAL_TESTS: $test_name"
    echo "================================================"
    
    if $test_function; then
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
    
    sleep 2  # Delay entre testes
}

# Executar testes
run_test "Verificar Conexão" test_connection
run_test "Enviar Texto" test_text_message
run_test "Enviar Áudio" test_audio_message
run_test "Enviar Imagem" test_image_message
run_test "Buscar Mensagens" test_fetch_messages

# ========================================
# RESULTADO FINAL
# ========================================

echo ""
echo "================================================"
echo "📊 RESULTADO DOS TESTES"
echo "================================================"
echo "Total de testes: $TOTAL_TESTS"
echo -e "${GREEN}Testes passados: $PASSED_TESTS${NC}"
echo -e "${RED}Testes falhados: $FAILED_TESTS${NC}"
echo ""

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}🎉 TODOS OS TESTES PASSARAM!${NC}"
    exit 0
else
    echo -e "${RED}⚠️  ALGUNS TESTES FALHARAM${NC}"
    exit 1
fi