class SupabaseConfig {
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://szjcriybaioyzsyelrfo.supabase.co',
  );

  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_vOB3q-8_v5DPR9ZSFCdeAg_MzpHaE22',
  );
}
