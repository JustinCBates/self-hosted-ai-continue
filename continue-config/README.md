# Continue Configuration Guide

This directory contains configuration files for the Continue VS Code extension to work with your self-hosted AI backend.

## Setup Instructions

1. **Install Continue Extension**
   - Open VS Code
   - Go to Extensions (Ctrl+Shift+X)
   - Search for "Continue" and install it

2. **Configure Continue**
   - Copy `config.json` to your Continue config directory:
     - **Windows**: `%USERPROFILE%\.continue\config.json`
     - **macOS**: `~/.continue/config.json`
     - **Linux**: `~/.continue/config.json`

3. **Update Configuration**
   - Edit the copied `config.json` file
   - Replace `your-api-key-here` with your actual API key (if authentication is enabled)
   - Update the `apiBase` URL if your backend runs on a different host/port

## Configuration Options

### Models
The configuration includes a model that points to your self-hosted backend:
- `apiBase`: URL of your FastAPI backend
- `model`: Model name (should match what's available in your backend)
- `apiKey`: API key for authentication (optional)

### Context Providers
Enabled context providers include:
- **code**: Selected code snippets
- **docs**: Documentation context
- **diff**: Git diff context
- **terminal**: Terminal output
- **problems**: VS Code problems/errors
- **folder**: Folder structure
- **codebase**: Full codebase context

### Custom Commands
Pre-configured commands for common development tasks:
- `/test`: Generate comprehensive tests
- `/optimize`: Analyze and optimize code
- `/security`: Security vulnerability analysis
- `/refactor`: Code refactoring suggestions

## Usage

Once configured, you can:
1. Use Ctrl+I (or Cmd+I on Mac) to open the Continue chat
2. Select code and ask questions about it
3. Use slash commands like `/edit`, `/comment`, `/test`
4. Get autocomplete suggestions as you type

## Troubleshooting

- Ensure your AI backend is running on `http://localhost:8000`
- Check that the `/v1/chat/completions` endpoint is accessible
- Verify API key configuration if authentication is enabled
- Check VS Code developer console for any error messages