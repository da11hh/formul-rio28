# 📋💬 Plataforma Dual: Formulários Premium + WhatsApp Dashboard

## Overview

This project is a comprehensive "Dual Platform" offering premium form creation and a WhatsApp management dashboard. It aims to provide businesses with a robust tool for lead qualification, customer interaction, and data analysis. The form builder features a drag-and-drop interface, scoring system, and custom completion pages. The integrated WhatsApp dashboard allows for direct communication, media sharing, and lead status visualization. The platform is designed for seamless lead tracking from initial contact to conversion, offering automatic qualification based on form responses. It is built for scalability and easy deployment across various cloud providers.

## User Preferences

I prefer concise and direct answers. Focus on the most impactful solutions and avoid overly verbose explanations. I appreciate an iterative development approach where features are built and reviewed incrementally. Please ask for confirmation before making significant changes to the core architecture or introducing new external dependencies. I prefer to use `npm` as the package manager. For styling, I prefer Tailwind CSS and shadcn/ui components.

## System Architecture

The system is a full-stack application built with a React frontend and an Express.js backend.

### UI/UX Decisions
- **Design System:** Utilizes shadcn/ui components for a consistent and modern look.
- **Styling:** Tailwind CSS is used for utility-first styling.
- **Visuals:** Features a luxurious color palette (deep purple + gold), glassmorphism effects, sophisticated shadows, and smooth animations (fadeIn, slideUp, scaleIn, glow).
- **Responsiveness:** Designed with a mobile-first approach.
- **Form Builder:** Drag-and-drop interface for intuitive form creation and question ordering.
- **WhatsApp Interface:** Chat interface with visual badges for lead status and quick actions.

### Technical Implementations
- **Frontend:**
    - **Framework:** React 18.3.1 with TypeScript 5.8.3.
    - **Build Tool:** Vite 5.4.19 (configured with `allowedHosts: true` for dynamic Replit domains and `@vitejs/plugin-react` to avoid bus errors).
    - **Routing:** Wouter 3.7.1.
    - **State Management:** React Query 5.83.0.
    - **Form Handling:** React Hook Form 7.61.1 with Zod 3.25.76 for validation.
    - **Drag-and-Drop:** @dnd-kit 6.3.1.
- **Backend:**
    - **Runtime:** Node.js 20.19.3.
    - **Framework:** Express 5.1.0.
    - **Database ORM:** Drizzle ORM 0.44.6.
    - **File Upload:** Multer 2.0.2.
    - **Real-time Communication:** `ws` 8.18.3 for WebSocket functionality.
- **Database:**
    - **Primary Database:** PostgreSQL.
    - **Schema:** Managed by Drizzle ORM with 6 core tables (`forms`, `form_submissions`, `completion_pages`, `form_templates`, `app_settings`, `configurations_whatsapp`).
    - **Lead Qualification System:** Introduces 4 new tables (`leads`, `lead_historico`, `formulario_links`, and updates to `form_submissions`) to track, score, and qualify leads automatically. This includes features like unique trackable links, lead scoring (Hot/Warm/Cold), and historical auditing of interactions.
- **API:**
    - **Type:** REST API with 23 documented routes covering Forms, Submissions, Templates, Completion Pages, Settings, Upload, and WhatsApp functionalities.

### Feature Specifications
- **Form Platform:**
    - Drag-and-drop form editor.
    - Scoring and qualification system for form responses.
    - 4 pre-built templates.
    - Visual design editor.
    - Customizable completion pages.
    - Analytics dashboard.
    - Shareable public links.
- **WhatsApp Platform:**
    - Conversation list and chat interface.
    - Support for sending text, images, audio, and video.
    - Audio recording and drag-and-drop media upload.
    - Demonstration mode for testing.
    - Persistent configuration stored in PostgreSQL.
    - Integration with Evolution API for core WhatsApp functionalities.
- **Lead Qualification:**
    - Comprehensive lead tracking from first WhatsApp contact to conversion.
    - Automatic lead scoring and status (approved/rejected/pending) based on form submissions.
    - Generation of unique, trackable form links for each lead.
    - Visual lead status badges directly within the WhatsApp chat interface.
    - Dashboards for consolidated lead data, KPIs, conversion rates, and average scores.

## External Dependencies

- **Database:** PostgreSQL
- **WhatsApp Integration:** Evolution API (configured via `/whatsapp/settings`)
- **Optional Dual Database:** Supabase (configured via `/configuracoes`)
- **Package Manager:** NPM (with `--legacy-peer-deps` for dependency conflict resolution)