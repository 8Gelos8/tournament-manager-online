export type GlobalRole = 'SYSTEM_ADMIN' | 'USER';
export type AccountType = 'COACH' | 'ORGANIZATION_REP' | 'JUDGE' | 'OTHER';
export type TournamentRole = 'TOURNAMENT_ADMIN' | 'JUDGE' | 'COACH' | 'VIEWER';

export interface User {
  id: string;
  name: string;
  email: string;
  password?: string;
  globalRole: GlobalRole;
}

export interface TournamentApproval {
  id: string;
  userId: string;
  tournamentId: string;
  status: 'PENDING' | 'APPROVED' | 'REJECTED';
  approvedAt?: string;
  approvedBy?: string;
  licenseGranted: boolean; // Чи надана ліцензія на цей турнір
}

export interface UserProfile {
  userId: string;
  fullName: string;
  accountType: AccountType;
  customAccountType?: string;
  clubName?: string;
  logoUrl?: string;
}

export interface Athlete {
  id: string;
  ownerUserId: string;
  name: string;
  club: string;
  birthDate: string; // Формат YYYY-MM-DD
  age: number; // Обчислений вік
  weight: number;
  gender: 'M' | 'F';
  rank?: string;
  addedAt: string;
}

export interface ParticipationRequest {
  id: string;
  tournamentId: string;
  userId: string;
  athleteIds: string[];
  athleteSnapshots: Participant[];
  status: 'PENDING' | 'APPROVED' | 'REJECTED';
  submittedAt: string;
}

export interface TournamentCreateRequest {
  id: string;
  userId: string;
  userName: string;
  tournamentName: string;
  description: string;
  status: 'PENDING' | 'APPROVED' | 'REJECTED';
  submittedAt: string;
}

export interface TournamentUserRole {
  userId: string;
  tournamentId: string;
  role: TournamentRole;
  tatamiId?: string;
}

export interface Tournament {
  id: string;
  name: string;
  date: string;
  endDate: string;
  startTime?: string;
  endTime?: string;
  location: string;
  description: string;
  tatamiCount: number;
  maxParticipantsPerBracket?: number;
  bracketType: BracketType;
  status: 'PLANNED' | 'PENDING_APPROVAL' | 'LIVE' | 'COMPLETED';
  participantsCount: number;
  image: string;
  logo: string;
  creatorId: string;
}

export interface Participant {
  id: string;
  name: string;
  club: string;
  clubLogo?: string;
  coach?: string;
  weight: number;
  age: number;
  birthDate?: string;
  gender: 'M' | 'F';
  rank?: string;
  originalAthleteId?: string;
}

export type BracketType = 'SINGLE_ELIMINATION' | 'ROUND_ROBIN';
export type UserRole = 'ADMIN' | 'Татамі 1' | 'Татамі 2' | 'Татамі 3' | 'Татамі 4' | 'Татамі 5' | 'Татамі 6';

export interface Match {
  id: string;
  nextMatchId: string | null;
  loserMatchId?: string | null;
  player1: Participant | null;
  player2: Participant | null;
  winner: Participant | null;
  roundIndex: number;
  label?: string;
  fightNumber?: number;
}

export interface MatchRound {
  roundName: string;
  matches: Match[];
}

export interface Category {
  id: string;
  title: string;
  gender: 'M' | 'F';
  minAge: number;
  maxAge: number;
  minWeight: number;
  maxWeight: number;
  participants: Participant[];
  bracketType?: BracketType;
  rounds?: MatchRound[];
  status?: 'PENDING' | 'COMPLETED';
  podium?: { place: number; participant: Participant }[];
  tatami?: string;
}

export enum AppView {
  AUTH = 'AUTH',
  TOURNAMENT_LIST = 'TOURNAMENT_LIST',
  USER_DASHBOARD = 'USER_DASHBOARD',
  USER_PROFILE = 'USER_PROFILE',
  ATHLETES_MANAGER = 'ATHLETES_MANAGER',
  PARTICIPATION_APPLY = 'PARTICIPATION_APPLY',
  COACH_APPLICATIONS = 'COACH_APPLICATIONS',
  CREATE_TOURNAMENT = 'CREATE_TOURNAMENT',
  TOURNAMENT_ADMIN_DASHBOARD = 'TOURNAMENT_ADMIN_DASHBOARD',
  TOURNAMENT_REQUEST_FORM = 'TOURNAMENT_REQUEST_FORM',
  STAFF_MANAGEMENT = 'STAFF_MANAGEMENT',
  SYSTEM_ADMIN_PANEL = 'SYSTEM_ADMIN_PANEL',
  ROLE_SELECTION = 'ROLE_SELECTION',
  ADMIN_SETUP = 'ADMIN_SETUP',
  PARTICIPANTS = 'PARTICIPANTS',
  CATEGORIES = 'CATEGORIES',
  BRACKET = 'BRACKET',
  GLOBAL_BRACKETS = 'GLOBAL_BRACKETS',
  FIGHTS = 'FIGHTS',
  RESULTS = 'RESULTS',
  DASHBOARD = 'DASHBOARD',
  DIAGNOSTICS = 'DIAGNOSTICS',
  SETTINGS = 'SETTINGS',
  EXPLANATION = 'EXPLANATION'
}

export interface ThemeConfig {
  primaryColor: string;
  secondaryColor: string;
  accentColor: string;
  backgroundColor: string;
  surfaceColor: string;
  headerColor: string;
  borderRadius: string;
  isDark: boolean;
  fontFamily: string;
  backgroundImage?: string;
  bgOpacity?: number;
}

export interface AppState {
  version: string;
  view: AppView;
  isDevModeActive: boolean;
  devOverride: {
    role: 'GUEST' | 'TRAINER' | 'OWNER' | 'JUDGE' | 'SYS_ADMIN' | null;
  };
  currentUser: User | null;
  users: User[];
  userProfiles: UserProfile[];
  athletes: Athlete[];
  archivedAthletes: Athlete[];
  participationRequests: ParticipationRequest[];
  tournamentAssignments: TournamentUserRole[];
  createRequests: TournamentCreateRequest[];
  tournamentApprovals: TournamentApproval[];
  activeTournamentId: string | null;
  tournaments: Tournament[];
  archivedTournaments: Tournament[];
  userRole: UserRole | null;
  occupiedRoles: UserRole[];
  participants: Participant[];
  archivedParticipants: Participant[];
  categories: Category[];
  stopwatchResetTrigger: number;
  settings: {
    language: 'UA' | 'EN';
    labels: Record<string, string>;
    tatamiCount: number;
    maxParticipants: number;
    adminTatami: UserRole | null;
    theme: ThemeConfig;
    tournament: {
      name: string;
      logo?: string;
      date?: string;
      time?: string;
      description?: string;
      locationName?: string;
      locationAddress?: string;
      locationUri?: string;
    };
    fights: {
      defaultDuration: number;
      restPeriod: number;
      autoNext: boolean;
      soundEnabled: boolean;
    };
    ui: {
      compactMode: boolean;
      animationsEnabled: boolean;
      showCoach: boolean;
    };
  };
}