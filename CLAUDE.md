# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Starting Development Server
```bash
# Rails + Vite integrated development (recommended)
bin/rails server
# Access at http://localhost:3000 (local) or http://localhost:4000 (Docker)

# Alternative: Manual parallel processes
bin/vite dev & bin/rails s
```

### Building and Deployment
```bash
# Rails + Vite integration handles build automatically
bin/rails server
# For manual build (if needed):
yarn build
```

### Package Management
```bash
# Install Ruby dependencies
bundle install
# Install Node.js dependencies
yarn install
```

### Docker Development
```bash
# Start with Docker Compose
docker-compose up --build
# Access at http://localhost:4000
```

## Architecture Overview

This is a **Vite + Rails integrated application** that serves both frontend and API from a single Rails server:

### Frontend Architecture
- **Vue.js 2.7.16** with Vite build system and Composition API support
- **Unified frontend structure** in `app/frontend/`:
  - `App.vue` - Main Vue application component
  - `main.js` - Unified entry point for Vue application
  - `vite.config.js` - Vite configuration
  - `entrypoints/application.js` - Rails-integrated entry point (imports main.js)
- **Build process**: Vite builds directly to `public/` directory for Rails to serve

### Backend Architecture
- **Rails 7.0** in API mode with frontend serving capability
- **File-based persistence**: Uses JSON files in `data/todos.json` instead of database
- **Custom model**: `Todo` model uses `ActiveModel` mixins without ActiveRecord
- **API-first design**: REST API at `/api/v1/todos` with Rails serving frontend for non-API routes

### Key Configuration Files
- `vite.config.mjs` - Root Vite config with Ruby plugin
- `frontend/vite.config.js` - Frontend-specific Vite config
- `config/vite.json` - ViteRails gem configuration
- `Procfile.dev` - Development process management

### Routing Strategy
Rails handles routing with a catch-all for non-API routes:
- API routes: `/api/v1/*` → API controllers
- All other routes → `frontend#index` (SPA routing)

### Data Layer
- **No database**: Uses `data/todos.json` for persistence
- **Todo model** (`app/models/todo.rb`): File-based CRUD with ActiveModel validations
- **JSON serialization**: Custom `to_hash` method for API responses

### Development Workflow
1. **Integrated development** (recommended): `bin/rails server`
   - Vite + Rails unified experience
   - Hot reload via vite_rails gem
   - Access at http://localhost:3000 (local) or http://localhost:4000 (Docker)
2. **Standalone frontend**: `cd app/frontend && yarn dev`
   - Pure Vue.js development
   - Faster hot reload for frontend-only changes
3. **Manual parallel**: `bin/vite dev & bin/rails s`

### File Structure Notes
- `app/frontend/App.vue` - Main Vue.js application component (single source of truth)
- `app/frontend/main.js` - Unified entry point for Vue application
- `app/frontend/vite.config.js` - Vite configuration (builds to public/)
- `app/frontend/entrypoints/application.js` - Rails-integrated entry point
- `public/vite-dev/` - Development assets served by vite_rails
- `data/todos.json` - Persistent data storage