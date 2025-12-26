-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create custom types
CREATE TYPE global_role AS ENUM ('SYSTEM_ADMIN', 'USER');
CREATE TYPE account_type AS ENUM ('COACH', 'ORGANIZATION_REP', 'JUDGE', 'OTHER');
CREATE TYPE tournament_role AS ENUM ('TOURNAMENT_ADMIN', 'JUDGE', 'COACH', 'VIEWER');
CREATE TYPE bracket_type AS ENUM ('SINGLE_ELIMINATION', 'ROUND_ROBIN');
CREATE TYPE user_role AS ENUM ('ADMIN', 'Татамі 1', 'Татамі 2', 'Татамі 3', 'Татамі 4', 'Татамі 5', 'Татамі 6');

-- Create users table (extends Supabase auth.users)
CREATE TABLE users (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  global_role global_role DEFAULT 'USER',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create user_profiles table
CREATE TABLE user_profiles (
  user_id UUID REFERENCES users(id) ON DELETE CASCADE PRIMARY KEY,
  full_name TEXT NOT NULL,
  account_type account_type NOT NULL,
  custom_account_type TEXT,
  club_name TEXT,
  logo_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create tournaments table
CREATE TABLE tournaments (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  name TEXT NOT NULL,
  date DATE NOT NULL,
  end_date DATE NOT NULL,
  start_time TIME,
  end_time TIME,
  location TEXT NOT NULL,
  description TEXT,
  tatami_count INTEGER DEFAULT 1,
  max_participants_per_bracket INTEGER,
  bracket_type bracket_type DEFAULT 'SINGLE_ELIMINATION',
  status TEXT DEFAULT 'PLANNED' CHECK (status IN ('PLANNED', 'PENDING_APPROVAL', 'LIVE', 'COMPLETED')),
  participants_count INTEGER DEFAULT 0,
  image TEXT,
  logo TEXT,
  creator_id UUID REFERENCES users(id) ON DELETE SET NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create athletes table
CREATE TABLE athletes (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  owner_user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  club TEXT NOT NULL,
  birth_date DATE NOT NULL,
  age INTEGER NOT NULL,
  weight DECIMAL(5,2) NOT NULL,
  gender CHAR(1) CHECK (gender IN ('M', 'F')),
  rank TEXT,
  added_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create participants table
CREATE TABLE participants (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  tournament_id UUID REFERENCES tournaments(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  club TEXT NOT NULL,
  club_logo TEXT,
  coach TEXT,
  weight DECIMAL(5,2) NOT NULL,
  age INTEGER NOT NULL,
  birth_date DATE,
  gender CHAR(1) CHECK (gender IN ('M', 'F')),
  rank TEXT,
  original_athlete_id UUID REFERENCES athletes(id) ON DELETE SET NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create categories table
CREATE TABLE categories (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  tournament_id UUID REFERENCES tournaments(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  gender CHAR(1) CHECK (gender IN ('M', 'F')),
  min_age INTEGER NOT NULL,
  max_age INTEGER NOT NULL,
  min_weight DECIMAL(5,2) NOT NULL,
  max_weight DECIMAL(5,2) NOT NULL,
  bracket_type bracket_type DEFAULT 'SINGLE_ELIMINATION',
  status TEXT DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'COMPLETED')),
  tatami TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create category_participants junction table
CREATE TABLE category_participants (
  category_id UUID REFERENCES categories(id) ON DELETE CASCADE,
  participant_id UUID REFERENCES participants(id) ON DELETE CASCADE,
  PRIMARY KEY (category_id, participant_id)
);

-- Create matches table
CREATE TABLE matches (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  category_id UUID REFERENCES categories(id) ON DELETE CASCADE NOT NULL,
  next_match_id UUID REFERENCES matches(id) ON DELETE SET NULL,
  loser_match_id UUID REFERENCES matches(id) ON DELETE SET NULL,
  player1_id UUID REFERENCES participants(id) ON DELETE SET NULL,
  player2_id UUID REFERENCES participants(id) ON DELETE SET NULL,
  winner_id UUID REFERENCES participants(id) ON DELETE SET NULL,
  round_index INTEGER NOT NULL,
  label TEXT,
  fight_number INTEGER,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create tournament_user_roles table
CREATE TABLE tournament_user_roles (
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  tournament_id UUID REFERENCES tournaments(id) ON DELETE CASCADE,
  role tournament_role DEFAULT 'VIEWER',
  tatami_id TEXT,
  assigned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  PRIMARY KEY (user_id, tournament_id)
);

-- Create participation_requests table
CREATE TABLE participation_requests (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  tournament_id UUID REFERENCES tournaments(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  athlete_ids UUID[] NOT NULL,
  status TEXT DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'APPROVED', 'REJECTED')),
  submitted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  reviewed_at TIMESTAMP WITH TIME ZONE,
  reviewed_by UUID REFERENCES users(id) ON DELETE SET NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create tournament_create_requests table
CREATE TABLE tournament_create_requests (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  user_name TEXT NOT NULL,
  tournament_name TEXT NOT NULL,
  description TEXT,
  status TEXT DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'APPROVED', 'REJECTED')),
  submitted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  reviewed_at TIMESTAMP WITH TIME ZONE,
  reviewed_by UUID REFERENCES users(id) ON DELETE SET NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create tournament_approvals table
CREATE TABLE tournament_approvals (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  tournament_id UUID REFERENCES tournaments(id) ON DELETE CASCADE NOT NULL,
  status TEXT DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'APPROVED', 'REJECTED')),
  approved_at TIMESTAMP WITH TIME ZONE,
  approved_by UUID REFERENCES users(id) ON DELETE SET NULL,
  license_granted BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX idx_tournaments_creator_id ON tournaments(creator_id);
CREATE INDEX idx_tournaments_status ON tournaments(status);
CREATE INDEX idx_tournaments_date ON tournaments(date);
CREATE INDEX idx_athletes_owner_user_id ON athletes(owner_user_id);
CREATE INDEX idx_participants_tournament_id ON participants(tournament_id);
CREATE INDEX idx_categories_tournament_id ON categories(tournament_id);
CREATE INDEX idx_matches_category_id ON matches(category_id);
CREATE INDEX idx_participation_requests_tournament_id ON participation_requests(tournament_id);
CREATE INDEX idx_participation_requests_user_id ON participation_requests(user_id);
CREATE INDEX idx_tournament_user_roles_tournament_id ON tournament_user_roles(tournament_id);

-- Enable Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE tournaments ENABLE ROW LEVEL SECURITY;
ALTER TABLE athletes ENABLE ROW LEVEL SECURITY;
ALTER TABLE participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE matches ENABLE ROW LEVEL SECURITY;
ALTER TABLE tournament_user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE participation_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE tournament_create_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE tournament_approvals ENABLE ROW LEVEL SECURITY;

-- RLS Policies

-- Users policies
CREATE POLICY "Users can view their own profile" ON users
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile" ON users
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "System admins can view all users" ON users
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid() AND global_role = 'SYSTEM_ADMIN'
    )
  );

-- User profiles policies
CREATE POLICY "Users can view their own profile" ON user_profiles
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own profile" ON user_profiles
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own profile" ON user_profiles
  FOR UPDATE USING (auth.uid() = user_id);

-- Tournaments policies
CREATE POLICY "Anyone can view tournaments" ON tournaments
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "Authenticated users can create tournaments" ON tournaments
  FOR INSERT TO authenticated WITH CHECK (auth.uid() = creator_id);

CREATE POLICY "Tournament creators and admins can update" ON tournaments
  FOR UPDATE USING (
    auth.uid() = creator_id OR
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid() AND global_role = 'SYSTEM_ADMIN'
    )
  );

-- Athletes policies
CREATE POLICY "Users can view their own athletes" ON athletes
  FOR SELECT USING (auth.uid() = owner_user_id);

CREATE POLICY "Users can insert their own athletes" ON athletes
  FOR INSERT WITH CHECK (auth.uid() = owner_user_id);

CREATE POLICY "Users can update their own athletes" ON athletes
  FOR UPDATE USING (auth.uid() = owner_user_id);

CREATE POLICY "Users can delete their own athletes" ON athletes
  FOR DELETE USING (auth.uid() = owner_user_id);

-- Participants policies
CREATE POLICY "Tournament staff can view participants" ON participants
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM tournament_user_roles tur
      WHERE tur.tournament_id = participants.tournament_id
      AND tur.user_id = auth.uid()
    ) OR
    EXISTS (
      SELECT 1 FROM tournaments t
      WHERE t.id = participants.tournament_id
      AND t.creator_id = auth.uid()
    )
  );

CREATE POLICY "Tournament admins can manage participants" ON participants
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM tournaments t
      WHERE t.id = participants.tournament_id
      AND t.creator_id = auth.uid()
    )
  );

-- Categories policies
CREATE POLICY "Tournament staff can view categories" ON categories
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM tournament_user_roles tur
      WHERE tur.tournament_id = categories.tournament_id
      AND tur.user_id = auth.uid()
    ) OR
    EXISTS (
      SELECT 1 FROM tournaments t
      WHERE t.id = categories.tournament_id
      AND t.creator_id = auth.uid()
    )
  );

CREATE POLICY "Tournament admins can manage categories" ON categories
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM tournaments t
      WHERE t.id = categories.tournament_id
      AND t.creator_id = auth.uid()
    )
  );

-- Matches policies
CREATE POLICY "Tournament staff can view matches" ON matches
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM categories c
      JOIN tournament_user_roles tur ON tur.tournament_id = c.tournament_id
      WHERE c.id = matches.category_id
      AND tur.user_id = auth.uid()
    ) OR
    EXISTS (
      SELECT 1 FROM categories c
      JOIN tournaments t ON t.id = c.tournament_id
      WHERE c.id = matches.category_id
      AND t.creator_id = auth.uid()
    )
  );

CREATE POLICY "Tournament admins can manage matches" ON matches
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM categories c
      JOIN tournaments t ON t.id = c.tournament_id
      WHERE c.id = matches.category_id
      AND t.creator_id = auth.uid()
    )
  );

-- Participation requests policies
CREATE POLICY "Users can view their own requests" ON participation_requests
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own requests" ON participation_requests
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Tournament admins can view and update requests" ON participation_requests
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM tournaments t
      WHERE t.id = participation_requests.tournament_id
      AND t.creator_id = auth.uid()
    )
  );

-- Tournament create requests policies
CREATE POLICY "Users can view their own requests" ON tournament_create_requests
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create requests" ON tournament_create_requests
  FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);

CREATE POLICY "System admins can manage requests" ON tournament_create_requests
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid() AND global_role = 'SYSTEM_ADMIN'
    )
  );

-- Tournament approvals policies
CREATE POLICY "Users can view their own approvals" ON tournament_approvals
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Tournament admins can manage approvals" ON tournament_approvals
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM tournaments t
      WHERE t.id = tournament_approvals.tournament_id
      AND t.creator_id = auth.uid()
    )
  );

-- Functions for updating timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_profiles_updated_at BEFORE UPDATE ON user_profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_tournaments_updated_at BEFORE UPDATE ON tournaments
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_athletes_updated_at BEFORE UPDATE ON athletes
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_participants_updated_at BEFORE UPDATE ON participants
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_categories_updated_at BEFORE UPDATE ON categories
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_matches_updated_at BEFORE UPDATE ON matches
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_participation_requests_updated_at BEFORE UPDATE ON participation_requests
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_tournament_create_requests_updated_at BEFORE UPDATE ON tournament_create_requests
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_tournament_approvals_updated_at BEFORE UPDATE ON tournament_approvals
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();