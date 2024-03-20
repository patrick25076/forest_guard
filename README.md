# ForestGuard

💡 ForestGuard is a groundbreaking mobile application dedicated to the vital mission of combating illegal deforestation in Romania. Our app combines cutting-edge AI technology with advanced Web Scraper accessing to SUMAL records and direct communication with authorities, empowering individuals to be the rescuers of our precious forests.

## Table of Contents
- [Key Features](#key-features)
  - [License Plate Detection and SUMAL Web Scraper](#license-plate-detection-and-sumal-web-scraper)
  - [Wood Volume Estimation](#wood-volume-estimation)
  - [UI/UX](#uiux)
  - [Technical Implementation](#technical-implementation)
  - [Social Impact](#social-impact)
- [Folder Structure](#folder-structure)
- [How to Contribute](#how-to-contribute)

## Key Features
### License Plate Detection and SUMAL Web Scraper
ForestGuard offers a user-friendly interface for capturing photos of trucks loaded with logs. Using advanced AI algorithms, the app instantly detects and reads license plate numbers from the images.

**Sub-tasks:**
- Access and integrate with the Web Scraper of SUMAL website, a comprehensive repository of wood transportation documents in Romania.
- Retrieve and display document information linked to the detected license plate number.

### Wood Volume Estimation
The app goes beyond license plate recognition by providing an estimate of the wood volume in the truck. This estimate is then compared to the volume declared in the documents.

**Sub-tasks:**
- Log Counting Algorithm: Identify and count the logs in the truck using YOLO-based log diameter detection.
- Measuring Distance AI: Convert pixel-based measurements to centimeters and calculate log dimensions.
- Volume Estimation: Employ a formula that considers log diameter, shape, length, and height to estimate the wood volume.
- Model evaluation, optimization, and fine-tuning for accurate volume estimation.

### UI/UX
**App Features:**
1. **Direct Reporting to Authorities:**
   - **Description:** ForestGuard allows users to take immediate action against illegal deforestation. If a discrepancy is detected between the estimated wood volume and the documents, the app provides a direct contact feature to notify the appropriate authorities and forest conservation organizations.
2. **Trucks Verified Section:**
   - **Description:** Keep track of all verified trucks and their wood transportation information in a dedicated section. This feature ensures transparency and accountability.
   - **Sub-tasks:**
     - Display the license plate numbers, estimated wood volumes, photos taken, and declared volumes from documents.
3. **Main Camera Feature:**
   - **Description:** Measure wood volume from trucks with our intuitive main camera feature. Simply point your camera at the loaded wood, and our smart technology will instantly analyze and provide accurate volume measurements.
   - **Sub-tasks:**
     1. **API Integration:**
        - Connect to external API for wood volume estimation.
     2. **Data Processing:**
        - Extract relevant info from API results.
     3. **User Confirmation:**
        - Confirm results with user feedback.

### Technical Implementation
**Description:**
- ForestGuard integrates seamlessly with an API for license plate recognition, ensuring efficient and accurate detection.
- The Log Counting Algorithm utilizes YOLO-based log diameter detection, while the Measuring Distance AI leverages engineering techniques for precise measurements.
- Comprehensive model evaluation, testing, and optimization are carried out to ensure reliable wood volume estimation.
- The application offers a user-friendly interface for seamless access to all features.

### Social Impact
ForestGuard is more than an app; it's a social impact project aimed at protecting Romania's invaluable forests. By empowering citizens to be vigilant against illegal deforestation, the app contributes to preserving the natural heritage and biodiversity of Romania. It ensures transparency in the wood transportation industry and supports legal compliance, making a significant positive difference in our fight against deforestation.

**ForestGuard: Protecting Romania's Forests, One Truck at a Time.**

## Folder Structure

- **backend:**
  - **experiments**
  - **src:**
    - **data_collection**
    - **data_preprocessing**
    - **models**
    - **optimization**
    - **deployment**
    - **utils**
- **docs:**
  - *Documentation files.*
- **data:**
  - *Data files.*
- **frontend:**
  - *Frontend files.*
- **paths:**
  - **path_1_ui_ux:**
    - *UI/UX files for each task in this path.*
  - **path_2_volume_estimation:**
    - *Jupyter notebooks for each task in this path.*
  - **path_3_engineering:**
    - *Jupyter notebooks for each task in this path.*

## How to Contribute

### Step 1: Clone the Repository
```bash
git clone https://dagshub.com/Omdena/RomaniaChapter_IllegalDeforestation.git
cd RomaniaChapter_IllegalDeforestation
```
### Step 2: Create a New Branch
```bash
git checkout -b feature/your-feature-name
```

### Step 3: Make and Commit your Changes
```bash
git add .
git commit -m "Add a brief commit message describing your changes"
```

### Step 5: Push Your Changes
```bash
git push origin feature/your-feature-name
```

### Step 6: Create a Pull Request
* Go to the [repository on Dagshub](https://dagshub.com/Omdena/RomaniaChapter_IllegalDeforestation)
* Click on the "Pull Requests" tab
* Click "New Pull Request"
* Select your branch and provide a brief description of your changes

### Step 7: Review and Merge
Once your pull request is submitted, we will review your changes. If everything looks good, your changes will be merged into the main branch.

Thank you for contributing to the RomaniaChapter_IllegalDeforestation project! 🌳🌲