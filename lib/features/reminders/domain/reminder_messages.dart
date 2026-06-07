/// Mensagens gentis e variadas para lembretes (sem culpa).
abstract class ReminderMessages {
  static const messages = [
    'Sem pressão — que tal um passo pequeno agora?',
    'Só 2 minutos de foco já contam. Topa?',
    'Seu cérebro pediu uma pausa? Tudo bem. Um micro-passo?',
    'Você não precisa fazer tudo. Só começar.',
    'Dia difícil? Um passo minúsculo ainda é vitória.',
    'Lembrete gentil: você consegue começar pequeno.',
    'O toDoin está aqui quando você quiser tentar.',
  ];

  static String forDay(DateTime date) {
    final index = date.day % messages.length;
    return messages[index];
  }
}
