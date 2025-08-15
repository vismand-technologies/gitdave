# GitHub Profile Manager Desktop App - Project Structure

## 🏗️ Project Architecture

```
github-profile-manager/
├── 📁 app/                          # Electron main application
│   ├── 📁 main/                     # Main process (Node.js/Electron)
│   │   ├── main.ts                  # Electron main entry point
│   │   ├── preload.ts               # Preload script for security
│   │   ├── menu.ts                  # Application menu
│   │   ├── 📁 services/             # Backend services
│   │   │   ├── profile-service.ts   # Profile management logic
│   │   │   ├── ssh-service.ts       # SSH key operations
│   │   │   ├── git-service.ts       # Git configuration
│   │   │   ├── github-service.ts    # GitHub API integration
│   │   │   └── file-service.ts      # File system operations
│   │   └── 📁 utils/                # Utility functions
│   │       ├── shell-executor.ts    # Execute shell scripts
│   │       ├── config-manager.ts    # App configuration
│   │       └── logger.ts            # Logging system
│   └── 📁 renderer/                 # Renderer process (React UI)
│       ├── index.html               # HTML entry point
│       ├── index.tsx                # React entry point
│       ├── App.tsx                  # Main App component
│       ├── 📁 components/           # React components
│       │   ├── 📁 layout/           # Layout components
│       │   │   ├── Header.tsx       # App header
│       │   │   ├── Sidebar.tsx      # Navigation sidebar
│       │   │   └── StatusBar.tsx    # Status bar
│       │   ├── 📁 profile/          # Profile management
│       │   │   ├── ProfileList.tsx  # List all profiles
│       │   │   ├── ProfileForm.tsx  # Create/edit profile
│       │   │   ├── ProfileCard.tsx  # Profile display card
│       │   │   └── ProfileSwitcher.tsx # Quick profile switch
│       │   ├── 📁 ssh/              # SSH key management
│       │   │   ├── SSHKeyList.tsx   # List SSH keys
│       │   │   ├── SSHKeyForm.tsx   # Generate/import keys
│       │   │   └── SSHKeyViewer.tsx # View public key
│       │   ├── 📁 repository/       # Repository operations
│       │   │   ├── RepoCloner.tsx   # Clone repositories
│       │   │   ├── RepoList.tsx     # List repositories
│       │   │   └── WorkspaceSetup.tsx # Windsurf workspace
│       │   ├── 📁 settings/         # Application settings
│       │   │   ├── Settings.tsx     # Settings panel
│       │   │   ├── ThemeSelector.tsx # Theme selection
│       │   │   └── Preferences.tsx  # User preferences
│       │   └── 📁 common/           # Shared components
│       │       ├── Button.tsx       # Custom button
│       │       ├── Input.tsx        # Custom input
│       │       ├── Modal.tsx        # Modal dialog
│       │       ├── Toast.tsx        # Notifications
│       │       └── Loading.tsx      # Loading spinner
│       ├── 📁 hooks/                # Custom React hooks
│       │   ├── useProfiles.ts       # Profile management hook
│       │   ├── useSSHKeys.ts        # SSH key hook
│       │   ├── useGitConfig.ts      # Git config hook
│       │   └── useTheme.ts          # Theme management hook
│       ├── 📁 store/                # State management
│       │   ├── index.ts             # Store configuration
│       │   ├── profileSlice.ts      # Profile state
│       │   ├── sshSlice.ts          # SSH key state
│       │   ├── settingsSlice.ts     # Settings state
│       │   └── uiSlice.ts           # UI state
│       ├── 📁 types/                # TypeScript types
│       │   ├── profile.ts           # Profile interfaces
│       │   ├── ssh.ts               # SSH key interfaces
│       │   ├── git.ts               # Git config interfaces
│       │   └── api.ts               # API response types
│       ├── 📁 styles/               # Styling
│       │   ├── globals.css          # Global styles
│       │   ├── components.css       # Component styles
│       │   └── themes.css           # Theme definitions
│       └── 📁 utils/                # Frontend utilities
│           ├── api.ts               # IPC communication
│           ├── validators.ts        # Form validation
│           └── formatters.ts        # Data formatting
├── 📁 scripts/                      # Legacy shell/Python scripts
│   ├── github-profile-manager.sh    # Original shell script
│   ├── github-profile-helper.py     # Original Python script
│   └── create-test-profile.sh       # Test script
├── 📁 assets/                       # Static assets
│   ├── 📁 icons/                    # Application icons
│   │   ├── icon.png                 # Main app icon
│   │   ├── icon.ico                 # Windows icon
│   │   └── icon.icns                # macOS icon
│   ├── 📁 images/                   # UI images
│   └── 📁 fonts/                    # Custom fonts
├── 📁 build/                        # Build configuration
│   ├── webpack.main.config.js       # Main process webpack
│   ├── webpack.renderer.config.js   # Renderer webpack
│   └── notarize.js                  # macOS notarization
├── 📁 dist/                         # Built application
├── 📁 release/                      # Release packages
├── 📁 docs/                         # Documentation
│   ├── API.md                       # API documentation
│   ├── ARCHITECTURE.md              # Architecture guide
│   ├── CONTRIBUTING.md              # Contribution guide
│   ├── DEPLOYMENT.md                # Deployment guide
│   └── USER_GUIDE.md                # User manual
├── 📁 tests/                        # Test files
│   ├── 📁 unit/                     # Unit tests
│   ├── 📁 integration/              # Integration tests
│   └── 📁 e2e/                      # End-to-end tests
├── package.json                     # Node.js dependencies
├── package-lock.json               # Lock file
├── tsconfig.json                    # TypeScript config
├── tsconfig.main.json               # Main process TS config
├── tsconfig.renderer.json           # Renderer TS config
├── electron-builder.json            # Build configuration
├── .eslintrc.js                     # ESLint configuration
├── .prettierrc                      # Prettier configuration
├── .gitignore                       # Git ignore rules
├── README.md                        # Project overview
├── PROJECT_STRUCTURE.md             # This file
├── FEATURES.md                      # Feature specifications
└── ROADMAP.md                       # Development roadmap
```

## 🎯 Core Components

### **Main Process (Backend)**
- **Profile Service**: CRUD operations for GitHub profiles
- **SSH Service**: Generate, manage, and validate SSH keys
- **Git Service**: Configure Git settings per profile
- **GitHub Service**: GitHub API integration and authentication
- **File Service**: File system operations and workspace management

### **Renderer Process (Frontend)**
- **Profile Management**: Create, edit, delete, and switch profiles
- **SSH Key Management**: Generate keys, view public keys, test connections
- **Repository Operations**: Clone repos with correct profiles
- **Settings Panel**: App preferences and theme selection
- **Workspace Integration**: Windsurf IDE configuration

## 🔧 Technology Stack

| Layer | Technology | Purpose |
|-------|------------|---------|
| **Desktop Framework** | Electron 28+ | Cross-platform desktop app |
| **Frontend** | React 18 + TypeScript | Modern UI framework |
| **State Management** | Redux Toolkit | Predictable state container |
| **Styling** | Tailwind CSS | Utility-first CSS framework |
| **Build Tool** | Webpack 5 | Module bundler |
| **Testing** | Jest + Testing Library | Unit and integration testing |
| **E2E Testing** | Playwright | End-to-end testing |
| **Linting** | ESLint + Prettier | Code quality and formatting |
| **Git Operations** | simple-git | Git command abstraction |
| **SSH Operations** | node-ssh | SSH key management |
| **File Operations** | fs-extra | Enhanced file system |

## 🚀 Key Features

### **Profile Management**
- ✅ Create multiple GitHub profiles (personal, work, client)
- ✅ Store profile metadata (name, email, username, directories)
- ✅ Quick profile switching with environment variables
- ✅ Profile validation and health checks
- ✅ Import/export profile configurations

### **SSH Key Management**
- ✅ Generate ED25519 SSH key pairs
- ✅ Automatic SSH config updates
- ✅ Test SSH connections to GitHub
- ✅ Display public keys for GitHub setup
- ✅ Key rotation and management

### **Git Configuration**
- ✅ Conditional Git includes per directory
- ✅ Profile-specific Git user settings
- ✅ Automatic Git config generation
- ✅ SSH command configuration per profile

### **Repository Operations**
- ✅ Clone repositories with correct profile
- ✅ Batch repository cloning
- ✅ Repository URL conversion (HTTPS ↔ SSH)
- ✅ Workspace directory management

### **Windsurf IDE Integration**
- ✅ Generate workspace-specific settings
- ✅ Profile-aware environment variables
- ✅ Automatic workspace configuration
- ✅ VS Code settings integration

### **Advanced Features**
- ✅ GitHub CLI integration
- ✅ Profile backup and restore
- ✅ Dark/light theme support
- ✅ System tray integration
- ✅ Auto-updater support

## 🎨 UI/UX Design Principles

### **Design Language**
- **Modern & Clean**: GitHub Desktop-inspired interface
- **Intuitive Navigation**: Clear sidebar with feature sections
- **Consistent Components**: Reusable UI component library
- **Responsive Layout**: Adaptive to different window sizes
- **Accessibility**: WCAG 2.1 compliant interface

### **Color Scheme**
```css
/* Light Theme */
--primary: #0969da;
--secondary: #656d76;
--success: #1a7f37;
--warning: #9a6700;
--error: #cf222e;
--background: #ffffff;
--surface: #f6f8fa;

/* Dark Theme */
--primary: #58a6ff;
--secondary: #8b949e;
--success: #3fb950;
--warning: #d29922;
--error: #f85149;
--background: #0d1117;
--surface: #161b22;
```

## 🔄 Development Workflow

### **Getting Started**
```bash
# Clone repository
git clone <repo-url>
cd github-profile-manager

# Install dependencies
npm install

# Start development
npm run dev

# Run tests
npm test

# Build for production
npm run build

# Package for distribution
npm run dist
```

### **Scripts**
- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run dist` - Create distribution packages
- `npm test` - Run unit tests
- `npm run test:e2e` - Run end-to-end tests
- `npm run lint` - Run ESLint
- `npm run format` - Format code with Prettier

## 📦 Distribution

### **Supported Platforms**
- **Windows**: Windows 10+ (x64, arm64)
- **macOS**: macOS 10.15+ (Intel, Apple Silicon)
- **Linux**: Ubuntu 18.04+, Fedora 32+, Debian 10+

### **Package Formats**
- **Windows**: `.exe` installer, `.msi` package, portable `.zip`
- **macOS**: `.dmg` installer, `.zip` archive
- **Linux**: `.AppImage`, `.deb`, `.rpm`, `.tar.gz`

## 🔐 Security Considerations

- **Secure SSH Key Storage**: Keys stored in standard SSH directory
- **No Hardcoded Secrets**: All sensitive data user-provided
- **Sandboxed Execution**: Electron security best practices
- **Code Signing**: Signed packages for all platforms
- **Auto-Update Security**: Secure update mechanism

## 📊 Performance Targets

- **Startup Time**: < 3 seconds cold start
- **Memory Usage**: < 150MB idle, < 300MB active
- **Bundle Size**: < 100MB packaged application
- **SSH Operations**: < 2 seconds key generation
- **Git Operations**: < 1 second config updates
