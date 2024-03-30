# Forest Guard: Innovative AI-Powered App Monitoring Wood Transportation in Romania

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
The Forest Guard project represents a pioneering approach to combatting illegal deforestation in Romania by harnessing the power of AI and computer vision technologies. It introduces a novel and innovative solution that empowers citizens and law enforcement agencies to monitor and track wood transportation activities effectively.

The application employs advanced algorithms to detect license plate numbers using bounding box detection and OCR text recognition. It also extracts legal documents from the SUMAL 2.0 platform, ensuring compliance with forestry regulations and facilitating real-time monitoring of wood transports.

Additionally, the app includes a state-of-the-art wood log detection feature, which utilizes a custom YOLOv8n model to detect and calculate wood volume accurately. By transforming pixels into centimeters and applying mathematical formulas, the app provides precise measurements, enabling users to verify the legality of wood transports.

## Databases
### European License Plate Dataset
- **Total Images:** 1457
- **Sources:**
  - Roboflow Dataset: Total Images: 923
  - Romanian License Plate Dataset: 534 [GitHub Repo](https://github.com/RobertLucian/license-plate-dataset)
- **Processing:**
  - Merged both datasets
  - Converted to YOLOv8 label format
  - Image Size: 640x640 (for mobile performance)
  - Augmentations: None

### Wood Log Database
- **Total Images:** 2585
- **Sources:**
  - Roboflow Dataset: Total Images: 2464
  - HAWKWood Database: 121 [ArXiv Paper](https://arxiv.org/abs/1410.4393)
- **Processing:**
  - Merged both datasets
  - Converted to YOLOv8 label format
  - Image Size: 640x640 (for mobile performance)
  - Augmentations: None

## Key Features
### License Plate Recognition
[![Demo Video](link_to_demo_video_thumbnail)](https://github.com/patrick25076/forest_guard/assets/113384811/aafae0e6-116e-4580-b281-9d2ff5e4a845)
- **Description:** This feature utilizes a YOLOv8 Nano model for license plate detection and the Google ML Kit Flutter package for OCR text recognition.

### Extracting Legal Documents From Sumal
[![Demo Video](link_to_demo_video_thumbnail)](https://github.com/patrick25076/forest_guard/assets/113384811/8bc0cf04-55f7-4d01-9ebd-cb54b3f8e977)
- **Description:** The app integrates with the SUMAL 2.0 platform to extract legal documents containing crucial information such as legal wood volume and the validity of the electronic legal notice.

### Wood Log Detection
[![Demo Video](link_to_demo_video_thumbnail)](https://github.com/patrick25076/forest_guard/assets/113384811/81989772-d8d6-4caf-86fc-da3076fa9aa1)
- **Description:** The application employs a custom YOLOv8n model for real-time wood log detection. It calculates wood volume by transforming pixels into centimeters and applying mathematical formulas for precise measurements.

### Verified Trucks Section
[![Demo Video](link_to_demo_video_thumbnail)](https://github.com/patrick25076/forest_guard/assets/113384811/1a96d074-d3e7-4f3f-8227-6a8b89a1e9f9)
- **Description:** License plate numbers, validity of electronic legal notice, legal volume, and estimated volume are saved in this section, ensuring accurate tracking and monitoring of wood transportation activities.

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
- Enhance functionality by automating wood length detection.
- Improve app appearance and user experience.
- Develop more accurate AI models for wood log detection and license plate recognition.
- Optimize app size and performance.

## Contribution and Collaboration
I am open to collaboration and improvements. Feel free to reach out if you'd like to contribute or discuss potential enhancements.

- Neicu Patrick
- GitHub: [Profile](https://github.com/yourusername](https://github.com/patrick25076))
- Email: patrickneicu2006@gmail.com
- LinkedIn: [Profile](https://www.linkedin.com/in/patrick-neicu-4bb567263/)

