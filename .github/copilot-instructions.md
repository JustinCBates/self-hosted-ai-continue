# Copilot Instructions for Self-Hosted AI Continue Project

This project is a self-hosted AI backend designed to work with the Continue VS Code extension for AI-powered code assistance.

## Project Overview
- **Backend**: Python FastAPI server for serving AI models
- **Frontend**: Continue VS Code extension configuration
- **AI Models**: Support for various open-source LLMs
- **Deployment**: Docker containerization for easy deployment

## Development Guidelines

### Code Style
- Follow PEP 8 for Python code
- Use type hints for all function parameters and returns
- Implement proper error handling and logging
- Use async/await patterns for API endpoints

### Architecture Patterns
- RESTful API design for backend services
- Model abstraction layer for easy model swapping
- Configuration-driven setup for different deployment environments
- Proper separation of concerns between API, model serving, and configuration

### Dependencies
- Use virtual environments for Python development
- Pin dependency versions in requirements.txt
- Minimize Docker image size with multi-stage builds
- Use environment variables for configuration

### Testing
- Write unit tests for API endpoints
- Include integration tests for model serving
- Test Continue extension configuration
- Validate Docker deployment

### Documentation
- Keep README.md updated with setup instructions
- Document API endpoints with proper schemas
- Include examples of Continue configuration
- Maintain deployment guides for different environments