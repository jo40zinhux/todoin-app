// Supabase Edge Function — subtarefas Pro (OpenAI no servidor)
// Deploy: supabase functions deploy suggest-subtasks  (JWT verification ativo)
// Cliente deve enviar apikey + Authorization (Bearer SUPABASE_ANON_KEY)
// Secrets: supabase secrets set OPENAI_API_KEY=sk-...

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';

const MAX_TITLE = 200;

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const apiKey = Deno.env.get('OPENAI_API_KEY');
    if (!apiKey) {
      return new Response(JSON.stringify({ error: 'OPENAI_API_KEY not configured' }), {
        status: 503,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const { taskTitle, taskType } = await req.json();
    const title = String(taskTitle ?? '').trim().slice(0, MAX_TITLE);
    const type = String(taskType ?? 'general').slice(0, 32);

    if (!title) {
      return new Response(JSON.stringify({ error: 'taskTitle required' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const safeTitle = title.replaceAll('"', "'").replaceAll('\n', ' ');

    const openAiRes = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${apiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: Deno.env.get('OPENAI_MODEL') ?? 'gpt-4o-mini',
        temperature: 0.4,
        response_format: { type: 'json_object' },
        messages: [
          {
            role: 'system',
            content:
              'Você ajuda pessoas com TDAH a dividir tarefas em 3 micro-passos pequenos, concretos e sem julgamento. Responda APENAS JSON: {"subtasks":["passo1","passo2","passo3"]}. Máximo 60 caracteres por passo.',
          },
          {
            role: 'user',
            content: `Tarefa: "${safeTitle}" (tipo: ${type}). Gere 3 micro-passos em português.`,
          },
        ],
      }),
    });

    if (!openAiRes.ok) {
      return new Response(JSON.stringify({ error: 'OpenAI request failed' }), {
        status: 502,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const data = await openAiRes.json();
    const content = data?.choices?.[0]?.message?.content ?? '{}';
    const parsed = JSON.parse(content);
    const subtasks = (parsed.subtasks ?? [])
      .map((s: unknown) => String(s).trim())
      .filter((s: string) => s.length > 0)
      .slice(0, 3);

    return new Response(JSON.stringify({ subtasks }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  } catch (e) {
    return new Response(JSON.stringify({ error: String(e) }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});
