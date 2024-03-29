# Forest Guard: AI-Powered App Monitoring Wood Transportation in Romania

[![Demo Video](link_to_demo_video_thumbnail)](https://github.com/patrick25076/forest_guard/assets/113384811/bd54e397-9fe4-4598-99fa-c04c561c0b57)

## Table of Contents
- [Project Overview](#project-overview)
- [Databases](#databases)
- [Key Features](#key-features)
  - [License Plate Recognition](#license-plate-recognition)
  - [Extracting Legal Documents From Sumal](#extracting-legal-documents-from-sumal)
  - [Wood Log Detection](#wood-log-detection)
  - [Verified Trucks Section](#verified-trucks-section)
- [Usage](#usage)
- [License](#license)
- [Room For Improvement](#room-for-improvement)
- [Contribution and Collaboration](#contribution-and-collaboration)

## Project Overview
The Forest Guard project is aimed at combating illegal deforestation in Romania through the application of AI and computer vision technologies. It involves detecting license plate numbers using bounding box detection and OCR text recognition, extracting legal documents from the SUMAL platform, and detecting wood volume with YOLOv8n.

## Databases
### European License Plate Dataset
- **Total Images:** 1457
- **Sources:**
  - Roboflow Dataset: Total Images: 923
  - Romanian License Plate Dataset: Total Images: 534
- **Processing:**
  - Merged both datasets
  - Converted to YOLOv8 label format
  - Image Size: 640x640 (for mobile performance)
  - Augmentations: None

### Wood Log Database
- **Total Images:** 2585
- **Sources:**
  - Roboflow Dataset: Total Images: 2464
  - HAWKWood Database: Total Images: 121
- **Processing:**
  - Merged both datasets
  - Converted to YOLOv8 label format
  - Image Size: 640x640 (for mobile performance)
  - Augmentations: None

## Key Features
### License Plate Recognition
[![Demo Video](link_to_demo_video_thumbnail)](https://github.com/patrick25076/forest_guard/assets/113384811/aafae0e6-116e-4580-b281-9d2ff5e4a845)
- **Description:** This feature uses bounding box detection and OCR text recognition to accurately identify license plate numbers.

### Extracting Legal Documents From Sumal
[![Demo Video](link_to_demo_video_thumbnail)](https://github.com/patrick25076/forest_guard/assets/113384811/8bc0cf04-55f7-4d01-9ebd-cb54b3f8e977)
- **Description:** This feature extracts legal documents related to timber transports and forestry regulations from the SUMAL platform in real-time.

### Wood Log Detection
[![Demo Video](link_to_demo_video_thumbnail)](https://github.com/patrick25076/forest_guard/assets/113384811/81989772-d8d6-4caf-86fc-da3076fa9aa1)
- **Description:** The app includes real-time detection of wood bounding boxes and calculates wood volume using YOLOv8n.

### Verified Trucks Section
[![Demo Video](link_to_demo_video_thumbnail)](https://github.com/patrick25076/forest_guard/assets/113384811/1a96d074-d3e7-4f3f-8227-6a8b89a1e9f9)
- **Description:** Users can review and manage verified trucks in this section, ensuring accurate tracking of wood transportation activities.

## Usage
To test the app, clone the repository and navigate to the `forest_guard` directory. Run the following command:
```
cd forest_guard
flutter run
```
Ensure you are connected to an emulator or a real device. Contact me for the APK file if needed.

## License
Shield: [![CC BY-NC-SA 4.0][cc-by-nc-sa-shield]][cc-by-nc-sa]

This work is licensed under a
[Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License][cc-by-nc-sa].

[![CC BY-NC-SA 4.0][cc-by-nc-sa-image]][cc-by-nc-sa]

[cc-by-nc-sa]: http://creativecommons.org/licenses/by-nc-sa/4.0/
[cc-by-nc-sa-image]: https://licensebuttons.net/l/by-nc-sa/4.0/88x31.png
[cc-by-nc-sa-shield]: https://img.shields.io/badge/License-CC%20BY--NC--SA%204.0-lightgrey.svg

## Room For Improvement
- Enhance functionality by finding solutions for wood length without manual input.
- Improve app appearance and user experience.
- Develop more accurate AI models for wood log detection and license plate recognition.
- Optimize app size and performance.

## Contribution and Collaboration
I am open to collaboration and improvements. Feel free to reach out if you'd like to contribute or discuss potential enhancements.

