# MILKImageProcessor

A SwiftUI application built for the **MILK Books Swift Developer Challenge**,  
demonstrating structured architecture, Swift Concurrency, and lightweight unit testing.

---

## Overview

This app allows users to select up to **10 photos** from their library,  
then automatically generates resized versions (1024 px and 256 px).  
Each image is processed asynchronously with a maximum of **2 concurrent tasks** using a custom concurrency limiter.

---

## Key Features

- **MVVM architecture** — clean separation between model, logic, and UI  
- **Swift Concurrency (`async/await`)** — modern and efficient asynchronous design  
- **Custom `AsyncLimiter`** — ensures only 2 concurrent jobs at once  
- **File I/O safety** — processed images saved to the temporary directory  
- **Progress tracking** — each image reports independent progress  
- **Robust error handling** — a single failure doesn’t interrupt other jobs  
- **Unit tests** — for all key services and view models  

---

## 🧱 Project Architecture

The project follows a **clean MVVM architecture** to ensure clarity, testability, and scalability.

- **Models** – Define data structures such as `ImageJob` and `ProcessedResult`.
- **ViewModels** – Contain application logic, state management, and async workflows (`ProcessingViewModel`).
- **Services** – Encapsulate reusable logic for image processing, file storage, and concurrency control.
- **Views** – Build the SwiftUI interface for photo selection, progress tracking, and job previews.
- **Tests** – Provide isolated unit tests for each service and the main view model.

This separation allows the processing logic to evolve independently of the UI and makes testing and maintenance easier.

---

## Project Structure

```
MILKImageProcessor/
│
├── Models/
│   ├── ImageJob.swift
│   └── ProcessedResult.swift
│
├── Services/
│   ├── AsyncLimiter.swift
│   ├── FileStorageService.swift
│   └── ImageProcessingService.swift
│
├── ViewModels/
│   └── ProcessingViewModel.swift
│
├── Views/
│   ├── ContentView.swift
│   ├── DeferredPhotosPicker.swift
│   ├── PickerBar.swift
│   ├── JobCard.swift
│   └── SelectedPreviewGrid.swift
│
├── Assets/
│
└── Tests/
    ├── AsyncLimiterTests.swift
    ├── FileStorageServiceTests.swift
    ├── ImageProcessingServiceTests.swift
    └── ProcessingViewModelTests.swift
```

---

## Run Instructions

- **Development Environment:** Xcode **26.0.1 (17A400)**  
- **Minimum Deployment Target:** iOS **17.0**

### Steps

1. Open the project in **Xcode 26.0.1 or later**  
2. Select any iPhone simulator running iOS **17.0** or later  
3. Run → **⌘ R**  
4. Tap **“Select Photos”** and choose up to 10 images  
5. Tap **“Start Processing”** to begin  
6. Processed images are stored in the app’s temporary directory (paths logged in console)

---

## Unit Tests

Run all tests using **⌘ U** in Xcode.

| Test File | Description |
|------------|--------------|
| `AsyncLimiterTests` | Verifies concurrency control (limit = 2) |
| `FileStorageServiceTests` | Checks file creation and writing |
| `ImageProcessingServiceTests` | Validates resizing logic |
| `ProcessingViewModelTests` | Ensures async flow and reset logic |

---

## Developer Notes

This project was completed in one day, focusing on correctness,  
clarity, and maintainable architecture instead of UI complexity.

Main priorities included:
- Using **Swift Concurrency** safely  
- Keeping components modular and testable  
- Demonstrating clear **MVVM** structure  
- Maintaining readable, production-level code quality  

---

## License

Created for the **MILK Books Swift Developer Challenge (2025)**.  
All code is for demonstration and evaluation purposes only.
