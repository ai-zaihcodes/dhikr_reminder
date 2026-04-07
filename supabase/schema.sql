-- Dhikr Reminder Database Schema
-- Run this in your Supabase SQL Editor

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- PROFILES TABLE (User Settings)
-- =====================================================
CREATE TABLE IF NOT EXISTS public.profiles (
    user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    frequency_type TEXT NOT NULL DEFAULT 'everyUnlock',
    daily_limit INTEGER,
    selected_categories TEXT[] DEFAULT ARRAY[]::TEXT[],
    show_translation BOOLEAN DEFAULT true,
    is_enabled BOOLEAN DEFAULT true,
    last_reminder_time TIMESTAMPTZ,
    reminders_shown_today INTEGER DEFAULT 0,
    last_reset_date TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT valid_frequency_type CHECK (frequency_type IN ('everyUnlock', 'limitedPerDay'))
);

-- Add updated_at trigger
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER profiles_updated_at
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- =====================================================
-- QUOTES TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS public.quotes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    text TEXT NOT NULL,
    translation TEXT,
    category TEXT NOT NULL DEFAULT 'general',
    source TEXT,
    is_global BOOLEAN DEFAULT false,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT valid_category CHECK (category IN (
        'morning', 'evening', 'general', 'forgiveness', 'gratitude', 'protection', 'custom'
    ))
);

CREATE TRIGGER quotes_updated_at
    BEFORE UPDATE ON public.quotes
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- Index for faster queries
CREATE INDEX IF NOT EXISTS idx_quotes_user_id ON public.quotes(user_id);
CREATE INDEX IF NOT EXISTS idx_quotes_category ON public.quotes(category);
CREATE INDEX IF NOT EXISTS idx_quotes_is_global ON public.quotes(is_global);

-- =====================================================
-- ROW LEVEL SECURITY (RLS)
-- =====================================================

-- Enable RLS on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.quotes ENABLE ROW LEVEL SECURITY;

-- Profiles RLS Policies
CREATE POLICY "Users can view own profile" 
    ON public.profiles FOR SELECT 
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own profile" 
    ON public.profiles FOR INSERT 
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own profile" 
    ON public.profiles FOR UPDATE 
    USING (auth.uid() = user_id);

-- Quotes RLS Policies
CREATE POLICY "Users can view global quotes" 
    ON public.quotes FOR SELECT 
    USING (is_global = true);

CREATE POLICY "Users can view own quotes" 
    ON public.quotes FOR SELECT 
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own quotes" 
    ON public.quotes FOR INSERT 
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own quotes" 
    ON public.quotes FOR UPDATE 
    USING (auth.uid() = user_id AND is_global = false);

CREATE POLICY "Users can delete own quotes" 
    ON public.quotes FOR DELETE 
    USING (auth.uid() = user_id AND is_global = false);

-- =====================================================
-- FUNCTIONS
-- =====================================================

-- Function to reset daily counters (run via cron job)
CREATE OR REPLACE FUNCTION public.reset_daily_counters()
RETURNS void AS $$
BEGIN
    UPDATE public.profiles
    SET reminders_shown_today = 0,
        last_reset_date = CURRENT_TIMESTAMP
    WHERE last_reset_date < CURRENT_DATE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to handle new user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (user_id, frequency_type, is_enabled)
    VALUES (NEW.id, 'everyUnlock', true);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to create profile on signup
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

-- =====================================================
-- SEED DATA (Default Dhikr Quotes)
-- =====================================================

INSERT INTO public.quotes (text, translation, category, source, is_global, user_id) VALUES
    -- Morning Adhkar
    ('اللَّهُمَّ بِكَ أَصْبَحْنَا، وَبِكَ أَمْسَيْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ، وَإِلَيْكَ النُّشُورُ', 
     'O Allah, by You we enter the morning and by You we enter the evening, by You we live and by You we die, and to You is the resurrection.', 
     'morning', 'Sunan At-Tirmidhi', true, NULL),
    
    ('سُبْحَانَ اللَّهِ وَبِحَمْدِهِ: عَدَدَ خَلْقِهِ، وَرِضَا نَفْسِهِ، وَزِنَةَ عَرْشِهِ، وَمِدَادَ كَلِمَاتِهِ', 
     'Glory is to Allah and praise is to Him, by the multitude of His creation, by His Pleasure, by the weight of His Throne, and by the extent of His Words.', 
     'morning', 'Sahih Muslim', true, NULL),
    
    -- Evening Adhkar
    ('اللَّهُمَّ بِكَ أَمْسَيْنَا، وَبِكَ أَصْبَحْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ، وَإِلَيْكَ الْمَصِيرُ', 
     'O Allah, by You we enter the evening and by You we enter the morning, by You we live and by You we die, and to You is the return.', 
     'evening', 'Sunan At-Tirmidhi', true, NULL),
    
    ('أَعُوذُ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّجِيمِ', 
     'I seek refuge in Allah from the accursed Satan.', 
     'evening', 'Quran', true, NULL),
    
    -- General
    ('لاَ إِلَهَ إِلاَّ اللَّهُ وَحْدَهُ لاَ شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ، وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ', 
     'There is no god but Allah, alone, without any partner. The Kingdom and praise belong to Him and He has power over everything.', 
     'general', 'Sahih Muslim', true, NULL),
    
    ('سُبْحَانَ اللَّهِ وَبِحَمْدِهِ، سُبْحَانَ اللَّهِ الْعَظِيمِ', 
     'Glory is to Allah and all praise is to Him, glory is to Allah the Magnificent.', 
     'general', 'Sahih Muslim', true, NULL),
    
    -- Forgiveness
    ('أَسْتَغْفِرُ اللَّهَ الْعَظِيمَ الَّذِي لاَ إِلَهَ إِلاَّ هُوَ الْحَيُّ الْقَيُّومُ وَأَتُوبُ إِلَيْهِ', 
     'I seek forgiveness from Allah, the Magnificent, besides whom there is no deity, the Living, the Eternal, and I repent to Him.', 
     'forgiveness', 'Sunan At-Tirmidhi', true, NULL),
    
    ('رَبِّ اغْفِرْ لِي وَتُبْ عَلَيَّ إِنَّكَ أَنْتَ التَّوَّابُ الرَّحِيمُ', 
     'My Lord, forgive me and accept my repentance, indeed You are the Accepting of repentance, the Merciful.', 
     'forgiveness', 'Sahih Muslim', true, NULL),
    
    -- Gratitude
    ('الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ', 
     'All praise is due to Allah, Lord of the Worlds.', 
     'gratitude', 'Quran (Al-Fatiha)', true, NULL),
    
    ('اللَّهُمَّ أَعِنِّي عَلَى ذِكْرِكَ وَشُكْرِكَ وَحُسْنِ عِبَادَتِكَ', 
     'O Allah, help me to remember You, to give thanks to You, and to worship You in the best manner.', 
     'gratitude', 'Sunan Abi Dawud', true, NULL),
    
    -- Protection
    ('بِسْمِ اللَّهِ الَّذِي لاَ يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الأَرْضِ وَلاَ فِي السَّمَاءِ', 
     'In the name of Allah, with whose name nothing can harm on earth or in the heavens.', 
     'protection', 'Sunan At-Tirmidhi', true, NULL),
    
    ('أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ', 
     'I seek refuge in the perfect words of Allah from the evil of what He has created.', 
     'protection', 'Sahih Muslim', true, NULL),
    
    ('أَعُوذُ بِاللَّهِ مِنَ الْهَمِّ وَالْحَزَنِ، وَالْعَجْزِ وَالْكَسَلِ، وَالْبُخْلِ وَالْجُبْنِ، وَضَلَعِ الدَّيْنِ وَغَلَبَةِ الرِّجَالِ', 
     'I seek refuge in Allah from worry and grief, from incapacity and laziness, from cowardice and miserliness, from being heavily in debt and from being overpowered by men.', 
     'protection', 'Sahih Al-Bukhari', true, NULL);

-- =====================================================
-- REALTIME SUBSCRIPTIONS (for live updates)
-- =====================================================

-- Enable realtime for both tables
ALTER TABLE public.profiles REPLICA IDENTITY FULL;
ALTER TABLE public.quotes REPLICA IDENTITY FULL;

-- Add tables to realtime publication
BEGIN;
  DROP PUBLICATION IF EXISTS supabase_realtime;
  CREATE PUBLICATION supabase_realtime;
COMMIT;

ALTER PUBLICATION supabase_realtime ADD TABLE public.profiles;
ALTER PUBLICATION supabase_realtime ADD TABLE public.quotes;