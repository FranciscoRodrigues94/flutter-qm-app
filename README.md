# QS App — Flutter Prototype

A Flutter-based Quality Management prototype for color measurement data visualization, filtering and analysis.

## Overview

The QS App is a prototype application designed to simplify the analysis and visualization of quality-management measurement data.

The project started from a real-world Quality Management use case and is being developed as a Flutter application with a focus on usability, structured data handling and future AI-assisted analysis.

## Current Features

- Measurement data overview
- Filtering and searching of measurement data
- Detailed measurement views
- Color measurement data visualization
- Analysis of measurement data
- Structured navigation between different QS areas
- Responsive Flutter-based user interface

## Planned Features

### Analyse

Further development of the analysis page, including:

- Improved measurement trend visualization
- Comparison of measurements over time
- Identification of relevant deviations
- Improved filtering and analysis options

### Frag AI

An AI-assisted analysis interface is planned for the application.

The goal is to allow users to ask questions about the available measurement data using natural language.

**Example:**

> "Analysiere die Farbentwicklung von BA Nr. 123456 im letzten Jahr."

Potential use cases include:

- Analysis of measurement trends
- Comparison of different time periods
- Identification of unusual measurements
- Analysis of color and gloss development
- Natural-language questions about measurement data

The AI functionality is currently a prototype concept and is not yet fully implemented.

## Technology Stack

- Flutter
- Dart
- CSV-based measurement data
- Git / GitHub

## Data

The current prototype uses fictional measurement data for development and demonstration purposes.

No confidential company data or real production measurement data is included in this repository.

## Project Structure

```text
lib/
├── main.dart
├── pages/
│   ├── analyse_page.dart
│   ├── messungen_page.dart
│   └── messungsdetails_page.dart
└── widgets/
    └── sidebar.dart

assets/
└── QS_FakeDaten_mit_Bezug.csv
```

## Architecture

The current prototype follows a simple Flutter application structure:

```text
Measurement Data
       │
       ▼
    Flutter
       │
       ├── Messungen
       │
       ├── Messungsdetails
       │
       └── Analyse
```

A future version could extend the architecture with a backend and AI integration:

```text
Data Source
    │
    ▼
Backend / Data Layer
    │
    ├───────────────┐
    ▼               ▼
Flutter App       AI Analysis
    │               │
    └───────┬───────┘
            ▼
         QS User
```

## Development

This project is currently under active development.

The application is being developed incrementally, with new functionality being added and tested throughout the development process.

Git is used for version control and to document the development history of the project.

## AI-Assisted Development

AI tools are used as development assistance, particularly for:

- Code generation
- Debugging
- Troubleshooting
- Exploring possible implementation approaches

The application concept, requirements, implementation decisions, integration, testing and validation are carried out as part of the development process.

## Roadmap

- [x] Initial Flutter project
- [x] Measurement data prototype
- [x] Measurement overview
- [x] Measurement details
- [x] Initial analysis functionality
- [ ] Improve Analyse page
- [ ] Add advanced trend analysis
- [ ] Develop Frag AI prototype
- [ ] Add AI-assisted data analysis
- [ ] Evaluate backend/data-source integration
- [ ] Evaluate possible integration with existing QS data systems

## Project Status

**Status: Prototype / Active Development**

This project is currently a functional prototype and is not intended to represent a production-ready enterprise application.

## Author

**Francisco Rodrigues**

Flutter / Dart development, application concept, implementation, testing and project development.