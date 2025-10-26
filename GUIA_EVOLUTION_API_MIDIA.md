# Guia Completo - Evolution API: Áudio, Imagem e Vídeo

## Índice
1. [Visão Geral](#visão-geral)
2. [Enviar Áudio](#enviar-áudio)
3. [Receber Áudio](#receber-áudio)
4. [Enviar Imagem](#enviar-imagem)
5. [Receber Imagem](#receber-imagem)
6. [Enviar Vídeo](#enviar-vídeo)
7. [Receber Vídeo](#receber-vídeo)
8. [Enviar Documento](#enviar-documento)
9. [Receber Documento](#receber-documento)
10. [Problemas Comuns](#problemas-comuns)
11. [Checklist de Diagnóstico](#checklist-de-diagnóstico)

---

## Visão Geral

A Evolution API usa o protocolo Baileys (WhatsApp Web) para enviar e receber mensagens. Para mídia, existem endpoints específicos e estruturas de dados diferentes.

### Endpoints Principais
```
Base URL: http://103.199.187.145:8080

- Enviar Áudio: POST /message/sendWhatsAppAudio/{instance}
- Enviar Imagem: POST /message/sendMedia/{instance}
- Enviar Vídeo: POST /message/sendMedia/{instance}
- Enviar Documento: POST /message/sendMedia/{instance}
- Buscar Mensagens: GET /chat/findMessages/{instance}
```

### Headers Necessários
```json
{
  "apikey": "SUA_API_KEY",
  "Content-Type": "application/json"
}
```

---

## Enviar Áudio

### 1. Endpoint
```
POST /message/sendWhatsAppAudio/{instance}
```

### 2. Formato Aceito
- **Codec**: Opus (audio/webm;codecs=opus)
- **Formato de envio**: Base64
- **Taxa de amostragem**: Qualquer (WhatsApp converte automaticamente)

### 3. Estrutura do Payload

#### Payload CORRETO ✅
```json
{
  "number": "553192267220",
  "audio": "base64_encoded_audio_data_here"
}
```

#### Payload INCORRETO ❌
```json
{
  "number": "553192267220@s.whatsapp.net",  // ❌ NÃO incluir @s.whatsapp.net
  "audioBase64": "...",                      // ❌ Campo errado
  "options": {}                              // ❌ Não necessário
}
```

### 4. Código de Exemplo - Frontend

```typescript
// 1. Gravar áudio usando MediaRecorder
const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
const mediaRecorder = new MediaRecorder(stream, {
  mimeType: 'audio/webm;codecs=opus'
});

const chunks: Blob[] = [];

mediaRecorder.ondataavailable = (event) => {
  if (event.data.size > 0) {
    chunks.push(event.data);
  }
};

mediaRecorder.onstop = async () => {
  const audioBlob = new Blob(chunks, { type: 'audio/webm;codecs=opus' });
  
  // 2. Converter para base64
  const arrayBuffer = await audioBlob.arrayBuffer();
  const uint8Array = new Uint8Array(arrayBuffer);
  const binaryString = uint8Array.reduce((acc, byte) => acc + String.fromCharCode(byte), '');
  const audioBase64 = btoa(binaryString);
  
  // 3. Enviar para edge function
  await supabase.functions.invoke('evolution-send-audio', {
    body: {
      apiUrl: 'http://103.199.187.145:8080/',
      apiKey: 'sua-api-key',
      instance: 'nexus intelligence',
      number: '553192267220',  // SEM @s.whatsapp.net
      audioBase64: audioBase64
    }
  });
};

mediaRecorder.start();
// ... depois
mediaRecorder.stop();
```

### 5. Código de Exemplo - Edge Function

```typescript
// supabase/functions/evolution-send-audio/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    const { apiUrl, apiKey, instance, number, audioBase64 } = await req.json();

    // Limpar número (remover @s.whatsapp.net se existir)
    const cleanNumber = number.includes('@') ? number.split('@')[0] : number;

    const baseUrl = apiUrl.replace(/\/$/, '');
    const encodedInstance = encodeURIComponent(instance);
    const url = `${baseUrl}/message/sendWhatsAppAudio/${encodedInstance}`;

    console.log('🎵 Enviando áudio:', {
      url,
      number: cleanNumber,
      audioSize: audioBase64.length
    });

    const response = await fetch(url, {
      method: 'POST',
      headers: {
        'apikey': apiKey,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        number: cleanNumber,
        audio: audioBase64,
      }),
    });

    const responseText = await response.text();
    console.log('📡 Evolution API response:', {
      status: response.status,
      ok: response.ok,
      body: responseText
    });

    if (!response.ok) {
      return new Response(
        JSON.stringify({
          success: false,
          error: `API returned status ${response.status}`,
          details: responseText,
        }),
        {
          status: 200,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      );
    }

    let responseData;
    try {
      responseData = JSON.parse(responseText);
    } catch {
      responseData = { raw: responseText };
    }

    return new Response(
      JSON.stringify({
        success: true,
        data: responseData,
      }),
      {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    );
  } catch (error) {
    console.error('💥 Error:', error);
    return new Response(
      JSON.stringify({
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error',
      }),
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    );
  }
});
```

---

## Receber Áudio

### 1. Endpoint para Buscar Mensagens
```
GET /chat/findMessages/{instance}?remoteJid={remoteJid}&limit=50
```

### 2. Estrutura da Mensagem de Áudio

```json
{
  "key": {
    "id": "3EB0C21234567890ABCDEF",
    "remoteJid": "553192267220@s.whatsapp.net",
    "fromMe": false
  },
  "message": {
    "audioMessage": {
      "url": "https://mmg.whatsapp.net/o1/v/...",
      "mimetype": "audio/ogg; codecs=opus",
      "seconds": 5,
      "ptt": true,  // Push-to-talk (áudio de voz)
      "fileLength": "12345",
      "mediaKey": "base64_key...",
      "fileSha256": "base64_hash...",
      "fileEncSha256": "base64_hash..."
    }
  },
  "messageTimestamp": 1698765432,
  "pushName": "Nome do Contato"
}
```

### 3. Como Processar Áudio Recebido

```typescript
// Detectar se é áudio
if (message.message?.audioMessage) {
  const audioMessage = message.message.audioMessage;
  
  // URL do áudio (já descriptografado pela Evolution API)
  const audioUrl = audioMessage.url;
  
  // Informações do áudio
  const duration = audioMessage.seconds;
  const isPTT = audioMessage.ptt; // true = mensagem de voz
  const mimeType = audioMessage.mimetype;
  
  console.log('🎵 Áudio recebido:', {
    url: audioUrl,
    duration: `${duration}s`,
    type: isPTT ? 'Mensagem de voz' : 'Arquivo de áudio',
    mimeType
  });
}
```

### 4. Renderizar Áudio no Frontend

```tsx
// AudioPlayer.tsx
import { useState, useRef, useEffect } from "react";
import { Play, Pause, Download } from "lucide-react";
import { Button } from "@/components/ui/button";

interface AudioPlayerProps {
  audioUrl: string;
  isReceived?: boolean;
}

export function AudioPlayer({ audioUrl, isReceived = false }: AudioPlayerProps) {
  const [isPlaying, setIsPlaying] = useState(false);
  const [currentTime, setCurrentTime] = useState(0);
  const [duration, setDuration] = useState(0);
  const audioRef = useRef<HTMLAudioElement>(null);

  useEffect(() => {
    const audio = audioRef.current;
    if (!audio) return;

    const updateTime = () => setCurrentTime(audio.currentTime);
    const updateDuration = () => setDuration(audio.duration);
    const handleEnded = () => setIsPlaying(false);

    audio.addEventListener('timeupdate', updateTime);
    audio.addEventListener('loadedmetadata', updateDuration);
    audio.addEventListener('ended', handleEnded);

    return () => {
      audio.removeEventListener('timeupdate', updateTime);
      audio.removeEventListener('loadedmetadata', updateDuration);
      audio.removeEventListener('ended', handleEnded);
    };
  }, [audioUrl]);

  const togglePlayPause = async () => {
    const audio = audioRef.current;
    if (!audio) return;

    if (isPlaying) {
      audio.pause();
    } else {
      await audio.play();
    }
    setIsPlaying(!isPlaying);
  };

  const formatTime = (seconds: number) => {
    if (!seconds || isNaN(seconds)) return "0:00";
    const mins = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
    return `${mins}:${secs.toString().padStart(2, '0')}`;
  };

  const progress = duration > 0 ? (currentTime / duration) * 100 : 0;

  return (
    <div className="flex items-center gap-3 min-w-[240px]">
      <audio ref={audioRef} src={audioUrl} preload="metadata" />
      
      <Button variant="ghost" size="icon" onClick={togglePlayPause}>
        {isPlaying ? <Pause className="h-5 w-5" /> : <Play className="h-5 w-5" />}
      </Button>

      <div className="flex-1">
        <div className="h-1 bg-muted rounded-full overflow-hidden">
          <div 
            className="h-full bg-primary transition-all"
            style={{ width: `${progress}%` }}
          />
        </div>
        <div className="text-xs mt-1 text-muted-foreground">
          {formatTime(currentTime)} / {formatTime(duration)}
        </div>
      </div>

      <Button variant="ghost" size="icon" asChild>
        <a href={audioUrl} download>
          <Download className="h-4 w-4" />
        </a>
      </Button>
    </div>
  );
}
```

---

## Enviar Imagem

### 1. Endpoint
```
POST /message/sendMedia/{instance}
```

### 2. Estrutura do Payload

```json
{
  "number": "553192267220",
  "mediatype": "image",
  "mimetype": "image/jpeg",
  "caption": "Legenda da imagem (opcional)",
  "media": "data:image/jpeg;base64,/9j/4AAQSkZJRg..." 
}
```

### 3. Formatos Aceitos
- JPEG: `image/jpeg`
- PNG: `image/png`
- GIF: `image/gif`
- WEBP: `image/webp`

### 4. Código de Exemplo - Enviar Imagem

```typescript
// Frontend - Selecionar e enviar imagem
async function sendImage(file: File, number: string, caption?: string) {
  // 1. Converter arquivo para base64 com data URL
  const reader = new FileReader();
  
  const base64 = await new Promise<string>((resolve, reject) => {
    reader.onload = () => resolve(reader.result as string);
    reader.onerror = reject;
    reader.readAsDataURL(file);
  });

  // 2. Enviar para edge function
  const { data, error } = await supabase.functions.invoke('evolution-send-media', {
    body: {
      apiUrl: 'http://103.199.187.145:8080/',
      apiKey: 'sua-api-key',
      instance: 'nexus intelligence',
      number: number,
      mediatype: 'image',
      mimetype: file.type,
      caption: caption,
      media: base64  // data:image/jpeg;base64,...
    }
  });

  if (error) throw error;
  return data;
}
```

### 5. Edge Function - Enviar Mídia

```typescript
// supabase/functions/evolution-send-media/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    const { apiUrl, apiKey, instance, number, mediatype, mimetype, caption, media } = await req.json();

    const cleanNumber = number.includes('@') ? number.split('@')[0] : number;
    const baseUrl = apiUrl.replace(/\/$/, '');
    const encodedInstance = encodeURIComponent(instance);
    const url = `${baseUrl}/message/sendMedia/${encodedInstance}`;

    console.log('📸 Enviando mídia:', {
      url,
      number: cleanNumber,
      mediatype,
      mimetype,
      hasCaption: !!caption,
      mediaSize: media?.length
    });

    const response = await fetch(url, {
      method: 'POST',
      headers: {
        'apikey': apiKey,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        number: cleanNumber,
        mediatype: mediatype,
        mimetype: mimetype,
        caption: caption || '',
        media: media,
      }),
    });

    const responseText = await response.text();
    console.log('📡 Response:', {
      status: response.status,
      ok: response.ok,
      body: responseText
    });

    if (!response.ok) {
      return new Response(
        JSON.stringify({
          success: false,
          error: `API returned status ${response.status}`,
          details: responseText,
        }),
        {
          status: 200,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      );
    }

    let responseData;
    try {
      responseData = JSON.parse(responseText);
    } catch {
      responseData = { raw: responseText };
    }

    return new Response(
      JSON.stringify({
        success: true,
        data: responseData,
      }),
      {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    );
  } catch (error) {
    console.error('💥 Error:', error);
    return new Response(
      JSON.stringify({
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error',
      }),
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    );
  }
});
```

---

## Receber Imagem

### 1. Estrutura da Mensagem com Imagem

```json
{
  "key": {
    "id": "3EB0C21234567890ABCDEF",
    "remoteJid": "553192267220@s.whatsapp.net",
    "fromMe": false
  },
  "message": {
    "imageMessage": {
      "url": "https://mmg.whatsapp.net/o1/v/...",
      "mimetype": "image/jpeg",
      "caption": "Legenda da imagem",
      "fileSha256": "base64_hash...",
      "fileLength": "123456",
      "height": 1080,
      "width": 1920,
      "mediaKey": "base64_key...",
      "fileEncSha256": "base64_hash...",
      "jpegThumbnail": "base64_thumbnail..."
    }
  },
  "messageTimestamp": 1698765432,
  "pushName": "Nome do Contato"
}
```

### 2. Processar Imagem Recebida

```typescript
if (message.message?.imageMessage) {
  const imageMessage = message.message.imageMessage;
  
  const imageUrl = imageMessage.url;
  const caption = imageMessage.caption;
  const dimensions = {
    width: imageMessage.width,
    height: imageMessage.height
  };
  
  console.log('📸 Imagem recebida:', {
    url: imageUrl,
    caption,
    dimensions,
    mimeType: imageMessage.mimetype
  });
}
```

### 3. Renderizar Imagem

```tsx
// MessageBubble.tsx
{message.mediaType === "image" && message.mediaUrl && (
  <div className="mb-2">
    <img 
      src={message.mediaUrl} 
      alt={message.caption || "Imagem"} 
      className="rounded-lg max-w-full h-auto max-h-[300px] object-cover"
      onError={(e) => {
        console.error('Erro ao carregar imagem:', message.mediaUrl);
        e.currentTarget.src = '/placeholder.svg';
      }}
    />
    {message.caption && (
      <p className="text-sm mt-2">{message.caption}</p>
    )}
  </div>
)}
```

---

## Enviar Vídeo

### 1. Endpoint
```
POST /message/sendMedia/{instance}
```

### 2. Estrutura do Payload

```json
{
  "number": "553192267220",
  "mediatype": "video",
  "mimetype": "video/mp4",
  "caption": "Legenda do vídeo (opcional)",
  "media": "data:video/mp4;base64,AAAAIGZ0eXBpc29t..."
}
```

### 3. Formatos Aceitos
- MP4: `video/mp4`
- 3GP: `video/3gp`
- AVI: `video/avi`
- MOV: `video/quicktime`

### 4. Limitações
- Tamanho máximo: ~16MB (recomendado)
- Duração recomendada: até 3 minutos
- Codecs: H.264 para vídeo, AAC para áudio

### 5. Código de Exemplo

```typescript
async function sendVideo(file: File, number: string, caption?: string) {
  // Validar tamanho
  if (file.size > 16 * 1024 * 1024) {
    throw new Error('Vídeo muito grande. Máximo 16MB.');
  }

  // Converter para base64
  const reader = new FileReader();
  const base64 = await new Promise<string>((resolve, reject) => {
    reader.onload = () => resolve(reader.result as string);
    reader.onerror = reject;
    reader.readAsDataURL(file);
  });

  // Enviar
  const { data, error } = await supabase.functions.invoke('evolution-send-media', {
    body: {
      apiUrl: 'http://103.199.187.145:8080/',
      apiKey: 'sua-api-key',
      instance: 'nexus intelligence',
      number: number,
      mediatype: 'video',
      mimetype: file.type,
      caption: caption,
      media: base64
    }
  });

  if (error) throw error;
  return data;
}
```

---

## Receber Vídeo

### 1. Estrutura da Mensagem com Vídeo

```json
{
  "key": {
    "id": "3EB0C21234567890ABCDEF",
    "remoteJid": "553192267220@s.whatsapp.net",
    "fromMe": false
  },
  "message": {
    "videoMessage": {
      "url": "https://mmg.whatsapp.net/o1/v/...",
      "mimetype": "video/mp4",
      "caption": "Legenda do vídeo",
      "fileSha256": "base64_hash...",
      "fileLength": "1234567",
      "seconds": 15,
      "height": 720,
      "width": 1280,
      "mediaKey": "base64_key...",
      "fileEncSha256": "base64_hash...",
      "jpegThumbnail": "base64_thumbnail..."
    }
  },
  "messageTimestamp": 1698765432,
  "pushName": "Nome do Contato"
}
```

### 2. Processar Vídeo Recebido

```typescript
if (message.message?.videoMessage) {
  const videoMessage = message.message.videoMessage;
  
  const videoUrl = videoMessage.url;
  const caption = videoMessage.caption;
  const duration = videoMessage.seconds;
  const dimensions = {
    width: videoMessage.width,
    height: videoMessage.height
  };
  
  console.log('🎥 Vídeo recebido:', {
    url: videoUrl,
    caption,
    duration: `${duration}s`,
    dimensions,
    mimeType: videoMessage.mimetype
  });
}
```

### 3. Renderizar Vídeo

```tsx
{message.mediaType === "video" && message.mediaUrl && (
  <div className="mb-2">
    <video 
      src={message.mediaUrl} 
      controls 
      className="rounded-lg max-w-full h-auto max-h-[300px]"
      onError={(e) => {
        console.error('Erro ao carregar vídeo:', message.mediaUrl);
      }}
    >
      Seu navegador não suporta vídeo.
    </video>
    {message.caption && (
      <p className="text-sm mt-2">{message.caption}</p>
    )}
  </div>
)}
```

---

## Enviar Documento

### 1. Payload

```json
{
  "number": "553192267220",
  "mediatype": "document",
  "mimetype": "application/pdf",
  "fileName": "documento.pdf",
  "caption": "Descrição do documento",
  "media": "data:application/pdf;base64,JVBERi0xLjQK..."
}
```

### 2. Tipos de Documento Aceitos
- PDF: `application/pdf`
- Word: `application/vnd.openxmlformats-officedocument.wordprocessingml.document`
- Excel: `application/vnd.openxmlformats-officedocument.spreadsheetml.sheet`
- TXT: `text/plain`
- ZIP: `application/zip`

---

## Receber Documento

### 1. Estrutura da Mensagem

```json
{
  "key": {
    "id": "3EB0C21234567890ABCDEF",
    "remoteJid": "553192267220@s.whatsapp.net",
    "fromMe": false
  },
  "message": {
    "documentMessage": {
      "url": "https://mmg.whatsapp.net/o1/v/...",
      "mimetype": "application/pdf",
      "title": "documento.pdf",
      "fileName": "documento.pdf",
      "fileSha256": "base64_hash...",
      "fileLength": "123456",
      "pageCount": 10,
      "mediaKey": "base64_key...",
      "fileEncSha256": "base64_hash...",
      "caption": "Descrição do documento"
    }
  },
  "messageTimestamp": 1698765432,
  "pushName": "Nome do Contato"
}
```

---

## Problemas Comuns

### Problema 1: Áudio não envia

**Sintomas:**
- Edge function retorna erro 400 ou 500
- Logs mostram "invalid audio format"

**Causas:**
1. Formato de áudio incorreto (não é Opus)
2. Base64 mal formatado
3. Número com @s.whatsapp.net incluído

**Solução:**
```typescript
// ✅ CORRETO
const mediaRecorder = new MediaRecorder(stream, {
  mimeType: 'audio/webm;codecs=opus'  // Especificar Opus
});

// Limpar número
const cleanNumber = number.replace('@s.whatsapp.net', '');

// Payload correto
{
  "number": cleanNumber,  // SEM @s.whatsapp.net
  "audio": audioBase64    // Campo 'audio', não 'audioBase64'
}
```

### Problema 2: Áudio não reproduz

**Sintomas:**
- AudioPlayer não carrega
- Erro no console sobre CORS
- URL do áudio retorna 403

**Causas:**
1. URL do áudio expirada (WhatsApp URLs expiram)
2. CORS bloqueando acesso
3. Formato de áudio não suportado pelo navegador

**Solução:**
```tsx
// Adicionar crossOrigin no audio element
<audio 
  ref={audioRef} 
  src={audioUrl} 
  preload="metadata" 
  crossOrigin="anonymous"  // Importante para CORS
  onError={(e) => {
    console.error('Erro ao carregar áudio:', e);
    // Tentar recarregar ou mostrar erro para usuário
  }}
/>
```

### Problema 3: Imagem não aparece

**Sintomas:**
- Componente de imagem quebrado
- URL retorna erro

**Causas:**
1. URL da imagem expirada
2. Formato não suportado
3. Tamanho muito grande

**Solução:**
```tsx
<img 
  src={imageUrl} 
  alt="Imagem" 
  onError={(e) => {
    console.error('Erro ao carregar imagem');
    e.currentTarget.src = '/placeholder.svg';  // Fallback
  }}
  loading="lazy"  // Lazy loading para performance
/>
```

### Problema 4: Vídeo não carrega

**Sintomas:**
- Player de vídeo fica carregando infinitamente
- Erro de codec

**Causas:**
1. Codec não suportado
2. Arquivo muito grande
3. URL expirada

**Solução:**
```tsx
<video 
  src={videoUrl} 
  controls
  preload="metadata"  // Carregar apenas metadados primeiro
  onError={(e) => {
    console.error('Erro ao carregar vídeo');
    // Mostrar mensagem de erro
  }}
>
  <source src={videoUrl} type="video/mp4" />
  Seu navegador não suporta vídeo.
</video>
```

### Problema 5: Mensagens não aparecem em tempo real

**Sintomas:**
- Precisa recarregar página para ver novas mensagens
- Polling não funciona

**Solução:**
```typescript
// Implementar polling ou webhook
const pollMessages = async (chatId: string) => {
  try {
    const messages = await evolutionApi.fetchMessages(chatId);
    
    // Filtrar apenas mensagens novas
    const newMessages = messages.filter(msg => 
      msg.messageTimestamp > lastTimestamp
    );
    
    if (newMessages.length > 0) {
      // Atualizar UI
      setMessages(prev => [...prev, ...processMessages(newMessages)]);
      lastTimestamp = newMessages[newMessages.length - 1].messageTimestamp;
    }
  } catch (error) {
    console.error('Erro ao buscar mensagens:', error);
  }
};

// Polling a cada 3 segundos
useEffect(() => {
  const interval = setInterval(() => pollMessages(selectedChat), 3000);
  return () => clearInterval(interval);
}, [selectedChat]);
```

---

## Checklist de Diagnóstico

### Antes de Enviar Mídia

- [ ] Evolution API está conectada (state: "open")
- [ ] API Key está correta
- [ ] Instance name está correto (com encoding se tiver espaços)
- [ ] Número está limpo (sem @s.whatsapp.net)
- [ ] Formato do arquivo é suportado
- [ ] Tamanho do arquivo está dentro do limite (16MB)

### Logs para Verificar

```typescript
// No edge function
console.log('📦 Payload enviado:', {
  url: url,
  number: cleanNumber,
  mediatype: mediatype,
  mimetype: mimetype,
  mediaSize: media.length,
  hasCaption: !!caption
});

console.log('📡 Resposta da API:', {
  status: response.status,
  ok: response.ok,
  headers: Object.fromEntries(response.headers.entries()),
  body: responseText.substring(0, 200) // Primeiros 200 chars
});
```

### No Frontend

```typescript
// Ao receber mensagem
console.log('📥 Mensagem recebida:', {
  id: message.key.id,
  from: message.key.remoteJid,
  fromMe: message.key.fromMe,
  hasAudio: !!message.message?.audioMessage,
  hasImage: !!message.message?.imageMessage,
  hasVideo: !!message.message?.videoMessage,
  hasDocument: !!message.message?.documentMessage,
  timestamp: new Date(message.messageTimestamp * 1000).toISOString()
});

// Se tiver mídia
if (message.message?.audioMessage) {
  console.log('🎵 Áudio detectado:', {
    url: message.message.audioMessage.url,
    duration: message.message.audioMessage.seconds,
    isPTT: message.message.audioMessage.ptt,
    mimetype: message.message.audioMessage.mimetype
  });
}
```

### Teste de Conexão

```typescript
// Testar antes de enviar mídia
const testConnection = async () => {
  try {
    const { data } = await supabase.functions.invoke('evolution-proxy', {
      body: {
        apiUrl: config.apiUrl,
        apiKey: config.apiKey,
        instance: config.instance,
        method: 'GET',
        endpoint: undefined
      }
    });
    
    console.log('🔌 Estado da conexão:', {
      connected: data?.data?.instance?.state === 'open',
      state: data?.data?.instance?.state,
      instanceName: data?.data?.instance?.instanceName
    });
    
    return data?.data?.instance?.state === 'open';
  } catch (error) {
    console.error('❌ Erro ao verificar conexão:', error);
    return false;
  }
};

// Usar antes de enviar
const connected = await testConnection();
if (!connected) {
  throw new Error('WhatsApp não está conectado');
}
```

---

## Resumo de Campos Importantes

### Enviar Áudio
```json
{
  "number": "553192267220",          // SEM @s.whatsapp.net
  "audio": "base64_encoded_audio"    // Base64 do áudio Opus
}
```

### Enviar Imagem/Vídeo/Documento
```json
{
  "number": "553192267220",
  "mediatype": "image|video|document",
  "mimetype": "image/jpeg|video/mp4|application/pdf",
  "caption": "Legenda opcional",
  "fileName": "nome.ext",            // Apenas para documento
  "media": "data:mime;base64,..."    // Data URL completo
}
```

### Estrutura de Mensagem Recebida
```json
{
  "key": {
    "id": "message_id",
    "remoteJid": "number@s.whatsapp.net",
    "fromMe": false
  },
  "message": {
    "audioMessage": { "url": "...", "seconds": 5 },
    "imageMessage": { "url": "...", "caption": "..." },
    "videoMessage": { "url": "...", "caption": "..." },
    "documentMessage": { "url": "...", "fileName": "..." }
  },
  "messageTimestamp": 1698765432
}
```

---

## Próximos Passos

1. ✅ Salve este documento
2. ✅ Teste cada tipo de mídia separadamente
3. ✅ Verifique os logs em cada etapa
4. ✅ Use o checklist de diagnóstico
5. ✅ Envie para o Claude com logs específicos dos erros

**Boa sorte! 🚀**
