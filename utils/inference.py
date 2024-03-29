import os
import re
from ultralytics import YOLO
import cv2
from roboflow import Roboflow
from transformers import pipeline
from dotenv import load_dotenv
from PIL import Image
from datetime import datetime
import requests
from bs4 import BeautifulSoup

def load_model(model_path):
    model=YOLO(model_path)
    return model

def get_date(val):
  timestamp = val / 1000  + 7200 # converting milliseconds to seconds
  date = datetime.utcfromtimestamp(timestamp)
  return date.strftime('%d/%m/%Y %H:%M:%S')


class Inference:
    def __init__(self, rf_bb_model: str, ocr_model: str):
        
        self.BB_MODEL = load_model(rf_bb_model)
        self.ocr_pipeline = pipeline("image-to-text", model=ocr_model)


    def bounding_box_prediction(self, image_path: str):
        """
        Predict the bounding box coords of a license plate for the given input image
        Args:
            img_path: Path to the image

        Returns: Coordinates of the bounding box of the license plate

        """

        image=cv2.imread(image_path)
        results =self.BB_MODEL.predict(image,imgsz=640,conf=0.4,iou=0.45)
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

        return x, y, width, height

    def ocr_prediction(self, image):
        """
        Predicts text on the license plate
        Args:
            image: License plate image

        Returns: Text of the license plate

        """
        prediction = self.ocr_pipeline(image)[0]['generated_text']
        license_plate = re.sub(r'[^a-zA-Z0-9]', '', prediction).upper()

        return license_plate

    def scrape(self, license_plate_number):
        base_url = 'https://inspectorulpadurii.ro/api/aviz'

        mock_number="BV20XKR" ## to modify with license_plate_number

        print(license_plate_number)

        response = requests.get(f'{base_url}/locations?nr={license_plate_number}').json()
        codes = response['codAviz']
        if not codes:
            print("Legal Notice not found")
        for code in codes:
            resp_2 = requests.get(f'{base_url}/{code}').json()
            # getting volume
            volume = resp_2['volum']['total']

            # getting valdity
            valid_from = get_date(resp_2['valabilitate']['emitere'])
            valid_to = get_date(resp_2['valabilitate']['finalizare'])
            print({'Code': code, 'Volume': volume, 'Validity': f'{valid_from} - {valid_to}'})
        

    def predict(self, image_path: str):
        """
        Predicts text on the license plate from the given image of a car
        Args:
            image_path: Path to the image of the car

        Returns: Text of the license plate

        """
        x, y, width, height = self.bounding_box_prediction(image_path)

        left = int(x - (width / 2))
        right = int(x + (width / 2))
        top = int(y - (height / 2))
        bottom = int(y + (height / 2))

        im = Image.open(image_path)
        im_cropped = im.crop((left, top, right, bottom))

        result = self.ocr_prediction(im_cropped)

        return result
    
    def inference(self, image_path: str):
        license_plate_number=self.predict(image_path)
        legal_document=self.scrape(license_plate_number)


if __name__ == '__main__':
    image_dir = r"RomaniaChapter_IllegalDeforestation\backend\src\evaluation\License Plate Evaluation System Data\test\images"
    image_path = os.path.join(image_dir, "002.jpg")
    inf = Inference(rf_bb_model=r'RomaniaChapter_IllegalDeforestation\backend\src\license_plate_detection\final_model\best_float32.tflite', ocr_model='microsoft/trocr-base-printed')

    res = inf.inference(r"RomaniaChapter_IllegalDeforestation\backend\src\inference_image.jpeg")
