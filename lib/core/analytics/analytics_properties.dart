/// Normaliza propriedades de eventos para o PostHog (`Map<String, Object>`).
Map<String, Object> sanitizeAnalyticsProperties(
  Map<String, Object?> properties,
) {
  return {
    for (final entry in properties.entries)
      if (entry.value != null) entry.key: entry.value as Object,
  };
}
