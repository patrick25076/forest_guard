"""
Script for evaluating license plate detection and OCR text recognition models.
"""

import os
from dotenv import load_dotenv
from roboflow import Roboflow
import time
import dagshub
import mlflow
import re
from ultralytics import YOLO
import matplotlib.patches as patches
import cv2
import matplotlib.pyplot as plt
from transformers import pipeline

dagshub.init(repo_owner='Omdena', repo_name='RomaniaChapter_IllegalDeforestation', mlflow=True)

load_dotenv()

# List of models and corresponding links
LICENSE_MODELS = [
    "spz-trcrj",
    "licens-plate-4fobp",
    "license-plate-nmu02",
    "anpr-ublyc",
    "number-plates-9gzii",
    "license_plate_dataset"
]

LICENSE_LINKS = [
    "https://universe.roboflow.com/arcanus-mazikeen-pt3bj/spz-trcrj",
    "https://universe.roboflow.com/kerb/licens-plate-4fobp",
    "https://universe.roboflow.com/swakshwar-ghosh-fjvq8/license-plate-nmu02/model/1",
    "https://universe.roboflow.com/anpr-hqruj/anpr-ublyc/model/1",
    "https://universe.roboflow.com/pm-lb22v/number-plates-9gzii",
    'https://universe.roboflow.com/wood-guard/license_plate_dataset/model/1'
]

OCR_MODELS = [
    'microsoft/trocr-base-printed',
    'microsoft/trocr-large-printed',
    'microsoft/trocr-small-printed'
]

OCR_LINKS = [
    'https://huggingface.co/microsoft/trocr-base-printed',
    'https://huggingface.co/microsoft/trocr-large-printed',
    'https://huggingface.co/microsoft/trocr-small-printed'
]

# Roboflow initialization
roboflow_api_key = os.getenv("ROBOFLOW_API_KEY")
rf = Roboflow(api_key=roboflow_api_key)  # Add Roboflow API key

def load_model(model_path):
    model=YOLO(model_path)
    return model
# Directories
IMG_DIRECTORY = r'RomaniaChapter_IllegalDeforestation\backend\src\evaluation\License Plate Evaluation System Data\test\images'
LABELS_DIRECTORY = r'RomaniaChapter_IllegalDeforestation\backend\src\evaluation\License Plate Evaluation System Data\test\labels'
OCR_CROPPED_DIRECTORY = r'RomaniaChapter_IllegalDeforestation\backend\src\evaluation\License Plate Evaluation System Data\cropped_ocr'


def clean_license_plate(license_plate):
    """
    Remove non-alphanumeric characters and convert to uppercase.

    Parameters:
        license_plate (str): Input license plate.

    Returns:
        str: Cleaned license plate.
    """
    cleaned_plate = re.sub(r'[^a-zA-Z0-9]', '', license_plate).upper()
    return cleaned_plate


def read_label_file(label_file_path):
    """
    Read a YOLO format label file and extract bounding box coordinates.

    Parameters:
        label_file_path (str): Path to the YOLO format label file.

    Returns:
        tuple: Tuple containing a list of bounding box coordinates and license plate number.
    """
    with open(label_file_path, 'r') as file:
        lines = file.readlines()

    # Extract bounding box coordinates from the first line
    if lines:
        line = lines[0].strip().split()
        x, y, w, h = map(float, line[1:])
        x = int(x * 640)
        y = int(y * 640)
        w = int(w * 640)
        h = int(h * 640)
        return [(x, y, w, h)], lines[1]

    return []


def process_ground_truth_labels(labels_directory):
    """
    Process ground truth labels for all files in the given directory.

    Parameters:
        labels_directory (str): Path to the directory containing label files.

    Returns:
        tuple: Tuple containing dictionaries of bounding box coordinates and license plate numbers.
    """
    bounding_boxes_dict = {}
    license_number_dict = {}
    i = 0
    for filename in os.listdir(labels_directory):
        if filename.endswith('.txt'):
            label_file_path = os.path.join(labels_directory, filename)
            image_filename, _ = os.path.splitext(filename)

            # Read label file and extract bounding box coordinates
            bounding_boxes, license_plate_number = read_label_file(label_file_path)
            # Store bounding boxes in the dictionary
            bounding_boxes_dict[i] = bounding_boxes
            license_number_dict[filename] = clean_license_plate(license_plate_number.strip())
            i += 1

    return bounding_boxes_dict, license_number_dict


def calculate_iou(box1, box2):
    """
    Calculate IoU between two bounding boxes.

    Parameters:
        box1 (tuple): (x1, y1, x2, y2) coordinates of the first bounding box.
        box2 (tuple): (x1, y1, x2, y2) coordinates of the second bounding box.

    Returns:
        float: Intersection over Union (IoU) score.
    """
    x1, y1, w1, h1 = box1
    x2, y2, w2, h2 = box2

    # Calculate intersection coordinates
    x_intersection = max(x1, x2)
    y_intersection = max(y1, y2)
    w_intersection = max(0, min(x1 + w1, x2 + w2) - x_intersection)
    h_intersection = max(0, min(y1 + h1, y2 + h2) - y_intersection)

    # Calculate area of intersection and union
    area_intersection = w_intersection * h_intersection
    area_union = w1 * h1 + w2 * h2 - area_intersection

    # Calculate IoU
    iou = area_intersection / (area_union + 1e-6)  # Adding a small epsilon to avoid division by zero

    return iou

def visualize_bounding_boxes(image, bbox1, bbox2):
    fig, ax = plt.subplots(1)
    ax.imshow(cv2.cvtColor(image, cv2.COLOR_BGR2RGB))

    # Create rectangles for bbox1 and bbox2
    rect1 = patches.Rectangle((bbox1[0]-bbox1[2]//2, bbox1[1]-bbox1[3]//2), bbox1[2], bbox1[3], linewidth=2, edgecolor='r', facecolor='none', label='Predicted')
    rect2 = patches.Rectangle((bbox2[0]-bbox2[2]//2, bbox2[1]-bbox2[3]//2), bbox2[2], bbox2[3], linewidth=2, edgecolor='g', facecolor='none', label='Ground Truth')

    # Add rectangles to the plot
    ax.add_patch(rect1)
    ax.add_patch(rect2)

    # Set axis labels and legend
    ax.set_xlabel('X')
    ax.set_ylabel('Y')
    plt.legend()

    plt.show()

def license_plate_bbox_evaluation(directory, ground_truth_data, models, mode):
    """
    Evaluate license plate detection performance for multiple models.

    Parameters:
        directory (str): Path to the directory containing test images.
        ground_truth_data (dict): Dictionary with ground truth bounding box coordinates.
        models (list): List of Roboflow model names.

    Returns:
        list: List of tuples containing model evaluation results.
    """
    if mode=='Roboflow':
        stop = len(models)
        k = 0
        performance = []
        while k < stop:
            i = 0
            iou_list = []
            project = rf.workspace().project(models[k])
            model = project.version(1).model

            start_time = time.time()

            for filename in os.listdir(directory):
                if filename.endswith('.jpg'):
                    img_path = os.path.join(directory, filename)

                    # Perform prediction
                    json = model.predict(img_path, confidence=50, overlap=50).json()

                    # Check if predictions are present
                    if len(json['predictions']) > 0:
                        # Extract bounding box coordinates
                        x = int(json['predictions'][0]['x'])
                        y = int(json['predictions'][0]['y'])
                        width = int(json['predictions'][0]['width'])
                        height = int(json['predictions'][0]['height'])

                    bbox1 = (x, y, width, height)
                    bbox2 = ground_truth_data[i][0]

                    i += 1

                    iou = calculate_iou(bbox1, bbox2)

                    iou_list.append(iou)

            end_time = time.time()

            total_time = end_time - start_time
            mean_iou = sum(iou_list) / len(iou_list)
            zero_indices = [index + 1 for index, value in enumerate(iou_list) if value == 0]
            nr_detected = len(iou_list) - len(zero_indices)

            model_evaluation = (models[k], mean_iou, nr_detected, total_time, LICENSE_LINKS[k])

            performance.append(model_evaluation)
            k += 1

        return performance
    if mode =='Custom':

        performance = []
        iou_list = []
        start_time = time.time()
        model_path = r"RomaniaChapter_IllegalDeforestation\backend\src\license_plate_detection\final_model\best_float32.tflite"
        model = load_model(model_path)

        for filename in os.listdir(directory):
            if filename.endswith('.jpg'):
                img_path = os.path.join(directory, filename)
                image=cv2.imread(img_path)
                results = model.predict(image,imgsz=640,conf=0.4,iou=0.45)
                results = results[0]  

                for i in range(len(results.boxes)):
                    box = results.boxes[i]
                    tensor = box.xyxy[0]
                    x1 = int(tensor[0].item())
                    y1 = int(tensor[1].item())
                    x2 = int(tensor[2].item())
                    y2 = int(tensor[3].item())
                    width=x2-x1
                    height=y2-y1
                    x=x1+width//2
                    y=y1+height//2

                bbox1 = (x, y, width, height)
                bbox2 = ground_truth_data[i][0]

                visualize_bounding_boxes(image , bbox1 , bbox2)

                i += 1

                iou = calculate_iou(bbox1, bbox2)

                iou_list.append(iou)

        end_time = time.time()

        total_time = end_time - start_time
        mean_iou = sum(iou_list) / len(iou_list)
        zero_indices = [index + 1 for index, value in enumerate(iou_list) if value == 0]
        nr_detected = len(iou_list) - len(zero_indices)

        model_evaluation = ("License Plate Custom", mean_iou, nr_detected, total_time)

        performance.append(model_evaluation)
       

        return performance



def ocr_evaluation(evaluation_directory, ground_truth_dict, models):
    """
    Evaluate OCR performance for multiple models.

    Parameters:
        evaluation_directory (str): Path to the directory containing OCR evaluation images.
        ground_truth_dict (dict): Dictionary with ground truth license plate numbers.
        models (list): List of OCR model names.

    Returns:
        list: List of tuples containing OCR model evaluation results.
    """
    k = 0
    stop = len(models)
    performance = []

    while k < stop:
        correct_predictions = 0
        total_predictions = 0
        full_correct = 0
        ocr_pipeline = pipeline("image-to-text", model=models[k])

        start_time = time.time()

        for filename in os.listdir(evaluation_directory):
            if filename.endswith('.jpg'):  # Adjust the file extension if needed
                image_path = os.path.join(evaluation_directory, filename)

                # Modify the path to point to the ground truth label
                gt_filename = f"{filename.split('.')[0].zfill(3)}.txt"  # Adjust if needed

                prediction = ocr_pipeline(image_path)[0]['generated_text']

                cleaned_prediction = clean_license_plate(prediction)

                # Get the corresponding ground truth
                ground_truth = ground_truth_dict[gt_filename]

                # Compare predictions with ground truth
                total_predictions += len(ground_truth)
                if cleaned_prediction == ground_truth:
                    full_correct = full_correct + 1

                for pred_char, gt_char in zip(cleaned_prediction, ground_truth):
                    if pred_char == gt_char:
                        correct_predictions += 1

        end_time = time.time()
        total_time = end_time - start_time
        accuracy = correct_predictions / total_predictions if total_predictions > 0 else 0

        current_performance = [models[k], OCR_LINKS[k], accuracy, full_correct, total_time]

        performance.append(current_performance)

        k += 1

    return performance


def run(evaluation_type):
    if evaluation_type == 'license_plate':
        bounding_box_dict, _ = process_ground_truth_labels(LABELS_DIRECTORY)
        performance = license_plate_bbox_evaluation(IMG_DIRECTORY, bounding_box_dict, "A" ,"Custom")

        for evaluation in performance:
            print(f"Model Name: {evaluation[0]} | Link: ")
            print(f"IoU performance: {evaluation[1]}")
            print(f"Detected {evaluation[2]}\{len(bounding_box_dict)}")
            print(f"Time: {evaluation[3]}")

            with mlflow.start_run():
                mlflow.log_param('Project Name', evaluation[0])
                mlflow.log_metric('IoU performance', evaluation[1])
                mlflow.log_metric('Number of Detected', evaluation[2])
                mlflow.log_metric('Time', evaluation[3])

    if evaluation_type == 'ocr':
        _, license_plate_numbers_dict = process_ground_truth_labels(LABELS_DIRECTORY)
        performance = ocr_evaluation(OCR_CROPPED_DIRECTORY, license_plate_numbers_dict, OCR_MODELS)

        for evaluation in performance:
            print(f"Model Name: {evaluation[0]} | Link: {evaluation[1]}")
            print(f"Accuracy: {evaluation[2]}")
            print(f"Fully Detected {evaluation[3]}\{len(license_plate_numbers_dict)}")
            print(f"Time: {evaluation[4]}")

            with mlflow.start_run():
                mlflow.log_param('Project Name', evaluation[0])
                mlflow.log_param('Link', evaluation[1])
                mlflow.log_metric('Accuracy', evaluation[2])
                mlflow.log_metric('Number of Fully-Detected', evaluation[3])
                mlflow.log_metric('Time', evaluation[4])


if __name__ == '__main__':
    run('license_plate')
    #run('ocr')
