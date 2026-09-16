# QS App — Flutter Prototype

A Flutter-based Quality Management prototype for color measurement data visualization, filtering and analysis.

## Overview

The QS App is a prototype application designed to simplify the analysis and visualization of quality-management measurement data.

The project started from a real-world Quality Management use case and was developed as a Flutter application with a focus on usability, structured data handling, data analysis and AI-assisted interaction.

The application currently works with a fictional dataset containing 1,000 color measurements.

## Current Features

- Measurement data overview
- Filtering and searching of measurement data
- Filtering by BA-Nr., article, user, date and result
- Detailed measurement views
- Reference values and tolerance visualization
- Color measurement data visualization
- CIELAB measurement values (L*, a*, b*)
- ΔE* analysis
- Graph-based measurement analysis
- Tolerance visualization for L*, a* and b*
- Comparison of different BA-Nr.
- Time-based development analysis
- Structured navigation between different QS areas
- Responsive Flutter-based user interface

### Frag AI

The application includes a local AI-assisted analysis interface called **Frag AI**.

Users can ask questions about the measurement data using natural language.

Examples:

> "Wie viele Messungen haben wir insgesamt?"

> "Welche Artikel haben die meisten Abweichungen?"

> "Wie hat sich BA 1001 im Jahr 2025 entwickelt?"

> "Welcher BA ist besser, 1001 oder 1002?"

The current prototype uses a local deterministic analysis engine to interpret questions and calculate results directly from the measurement dataset.

The analysis engine can identify relevant filters and topics such as:

- BA-Nr.
- Article numbers
- Measurement dimensions
- Years and time periods
- Tolerance deviations
- Comparisons between BA-Nr.
- Development and trends over time

The current implementation does not use an external LLM or cloud AI service.

A future version could extend Frag AI with an LLM for more advanced natural-language interpretation while keeping the underlying data calculations and validation within the application or backend.

## Technology Stack

- Flutter
- Dart
- fl_chart
- CSV
- Material Design
- Git / GitHub

## Data

The current prototype uses fictional measurement data for development and demonstration purposes.

The dataset contains 1,000 measurements covering the period from January 2025 to September 2026.

The reference data and measurement tolerances are also included in the fictional dataset.

No confidential company data or real production measurement data is included in this repository.

## Project Structure

```text
lib/
├── main.dart
├── pages/
│   ├── analyse_page.dart
│   ├── frag_ai_page.dart
│   ├── messungen_page.dart
│   └── messungsdetails_page.dart
├── services/
│   └── ai_analyzer.dart
└── widgets/
    └── sidebar.dart

```

## Architecture

The current prototype follows a simple Flutter application structure:

```text
Measurement Data
       │
       ▼
    Flutter
       │
       ├── Dashboard
       │
       ├── Messungen
       │       │
       │       └── Messungsdetails
       │
       ├── Analyse
       │
       └── Frag AI
               │
               ▼
        Local Analysis Engine
```

The local analysis engine processes the measurement data and provides structured results for natural-language queries.

A future version could extend the architecture with a backend and optional LLM integration:

```text
Data Source
    │
    ▼
Backend / Data Layer
    │
    ├───────────────┐
    ▼               ▼
Flutter App    Analysis / AI Layer
    │               │
    └───────┬───────┘
            ▼
         QS User
```

## Development

The application was developed incrementally from an initial Flutter prototype into a functional QS analysis application.

Development focused on:

- Building the Flutter application structure
- Working with structured measurement data
- Creating reusable UI components
- Implementing filtering and navigation
- Visualizing measurement data
- Implementing tolerance and deviation analysis
- Developing comparison and time-based analysis
- Building a natural-language query interface
- Testing the application with the complete fictional dataset

Git is used for version control and to document the development history of the project.

## AI-Assisted Development

AI tools were used as development assistance, particularly for:

- Code generation
- Debugging
- Troubleshooting
- Exploring possible implementation approaches
- Reviewing implementation ideas

The application concept, requirements, implementation decisions, integration, testing and validation are carried out as part of the development process.

AI assistance was used as a development tool; the resulting application architecture, functionality and implementation were integrated and validated within the project.

## Roadmap

- [x] Initial Flutter project
- [x] Measurement data prototype
- [x] Measurement overview
- [x] Measurement details
- [x] Analysis functionality
- [x] Measurement trend analysis
- [x] BA-Nr. comparison
- [x] Tolerance analysis
- [x] Frag AI interface
- [x] Local natural-language analysis engine
- [ ] Extend natural-language interpretation
- [ ] Evaluate LLM integration
- [ ] Evaluate backend/data-source integration
- [ ] Evaluate possible integration with existing QS data systems
- [ ] Evaluate real-time measurement data integration

## Project Status

**Status: Functional Prototype**

The application is currently a functional prototype for demonstration and portfolio purposes.

It is not intended to represent a production-ready enterprise application.

## Author

**Francisco de Castro Rodrigues**

Flutter / Dart development, application concept, implementation, testing and project development.
